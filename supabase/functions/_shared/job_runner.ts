// ═══════════════════════════════════════════════════════════════════════════
// _shared/job_runner.ts
//
// Reusable Job Runner — wraps every background worker with:
//   • Idempotency guard (skip duplicate executions)
//   • Per-job distributed lock via Firestore (prevents concurrent runs)
//   • Configurable timeout with AbortController
//   • Exponential backoff retry on transient errors
//   • cron_monitor.ts integration (start / complete / fail / skip)
//   • Dead Letter Queue routing on maxRetries exceeded
//   • Structured result envelope
// ═══════════════════════════════════════════════════════════════════════════

import { db } from "./firebase.ts";
import { markJobStart, markJobComplete, markJobFailed, markJobSkipped } from "./cron_monitor.ts";

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

export interface JobResult {
  processedItems: number;
  skippedItems?: number;
  failedItems?: number;
  message?: string;
  metadata?: Record<string, unknown>;
}

export interface JobDef {
  /** Unique job name — must match cron_health_summary document ID */
  name: string;
  /** If provided, skip execution if this key was already processed successfully */
  idempotencyKey?: string;
  /** Max total retries on transient errors before routing to DLQ */
  maxRetries?: number;
  /** Execution timeout in milliseconds. Default: 50_000ms (50s) */
  timeoutMs?: number;
  /** Acquire a distributed lock to prevent concurrent runs. Default: true */
  useLock?: boolean;
  /** The actual job logic */
  execute: (signal: AbortSignal) => Promise<JobResult>;
}

export interface RunJobOptions {
  /** Skip auth — already verified upstream */
  skipAuth?: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const LOCKS_COLLECTION = "job_execution_locks";
const DLQ_COLLECTION = "job_dead_letter_queue";
const LOCK_TTL_MS = 60_000; // 60s lock expiry

// ─────────────────────────────────────────────────────────────────────────────
// Main Runner
// ─────────────────────────────────────────────────────────────────────────────

export async function runJob(job: JobDef): Promise<Response> {
  const {
    name,
    idempotencyKey,
    maxRetries = 3,
    timeoutMs = 50_000,
    useLock = true,
    execute,
  } = job;

  const tStart = Date.now();
  const logId = await markJobStart(name);

  try {
    // ── 1. IDEMPOTENCY CHECK ─────────────────────────────────────────────────
    if (idempotencyKey) {
      const lockRef = db.collection("job_idempotency_log").doc(idempotencyKey);
      const lockSnap = await lockRef.get();
      if (lockSnap.exists && lockSnap.data()?.status === "success") {
        await markJobSkipped(logId, name, `Duplicate execution — key: ${idempotencyKey}`);
        return jsonResponse({ status: "skipped", reason: "duplicate" });
      }
    }

    // ── 2. DISTRIBUTED LOCK ──────────────────────────────────────────────────
    let lockAcquired = false;
    if (useLock) {
      lockAcquired = await acquireLock(name);
      if (!lockAcquired) {
        await markJobSkipped(logId, name, "Another instance is already running");
        return jsonResponse({ status: "skipped", reason: "locked" });
      }
    }

    try {
      // ── 3. EXECUTE WITH TIMEOUT ───────────────────────────────────────────
      const result = await executeWithTimeout(execute, timeoutMs, maxRetries, name);

      // ── 4. RECORD IDEMPOTENCY SUCCESS ─────────────────────────────────────
      if (idempotencyKey) {
        await db.collection("job_idempotency_log").doc(idempotencyKey).set({
          jobName: name,
          status: "success",
          completedAt: new Date().toISOString(),
        });
      }

      await markJobComplete(logId, name, tStart, {
        processedItems: result.processedItems,
        message: result.message ?? "Completed",
      });

      return jsonResponse({ status: "success", ...result });
    } finally {
      if (lockAcquired) {
        await releaseLock(name);
      }
    }
  } catch (e: unknown) {
    const errorMessage = e instanceof Error ? e.message : String(e);

    // ── 5. DLQ ROUTING ───────────────────────────────────────────────────────
    await routeToDlq(name, errorMessage, idempotencyKey);
    await markJobFailed(logId, name, tStart, errorMessage);

    return jsonResponse({ status: "error", error: errorMessage }, 500);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeout + Retry Executor
// ─────────────────────────────────────────────────────────────────────────────

async function executeWithTimeout(
  execute: (signal: AbortSignal) => Promise<JobResult>,
  timeoutMs: number,
  maxRetries: number,
  jobName: string
): Promise<JobResult> {
  let lastError: Error = new Error("Unknown error");

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const result = await Promise.race([
        execute(controller.signal),
        new Promise<never>((_, reject) =>
          controller.signal.addEventListener("abort", () =>
            reject(new Error(`Job "${jobName}" timed out after ${timeoutMs}ms`))
          )
        ),
      ]);
      clearTimeout(timer);
      return result;
    } catch (e: unknown) {
      clearTimeout(timer);
      lastError = e instanceof Error ? e : new Error(String(e));

      const isTransient =
        lastError.message.includes("timeout") ||
        lastError.message.includes("network") ||
        lastError.message.includes("UNAVAILABLE") ||
        lastError.message.includes("503") ||
        lastError.message.includes("429");

      if (!isTransient || attempt >= maxRetries) {
        throw lastError;
      }

      // Exponential backoff: 1s, 2s, 4s, 8s…
      const delayMs = Math.min(1000 * Math.pow(2, attempt), 30_000);
      await sleep(delayMs);
    }
  }

  throw lastError;
}

// ─────────────────────────────────────────────────────────────────────────────
// Distributed Lock Helpers
// ─────────────────────────────────────────────────────────────────────────────

async function acquireLock(jobName: string): Promise<boolean> {
  try {
    const lockRef = db.collection(LOCKS_COLLECTION).doc(jobName);
    const snap = await lockRef.get();

    if (snap.exists) {
      const data = snap.data()!;
      const lockedAt = new Date(data.lockedAt as string).getTime();
      // Stale lock: expired TTL — break it
      if (Date.now() - lockedAt < LOCK_TTL_MS) {
        return false; // Another instance holds a valid lock
      }
    }

    await lockRef.set({
      jobName,
      lockedAt: new Date().toISOString(),
      expiresAt: new Date(Date.now() + LOCK_TTL_MS).toISOString(),
    });
    return true;
  } catch (_) {
    return false; // Fail safe: don't run if lock can't be acquired
  }
}

async function releaseLock(jobName: string): Promise<void> {
  try {
    await db.collection(LOCKS_COLLECTION).doc(jobName).delete();
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// DLQ Router
// ─────────────────────────────────────────────────────────────────────────────

async function routeToDlq(
  jobName: string,
  errorMessage: string,
  idempotencyKey?: string
): Promise<void> {
  try {
    await db.collection(DLQ_COLLECTION).add({
      jobName,
      errorMessage,
      idempotencyKey: idempotencyKey ?? null,
      failedAt: new Date().toISOString(),
      status: "dead",
      requeueCount: 0,
    });
  } catch (_) {}
}

// ─────────────────────────────────────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────────────────────────────────────

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
