// ═══════════════════════════════════════════════════════════════════════
// _shared/cron_monitor.ts
// Writes a cron health record before and after every scheduled job.
// Every Edge Function calls markJobStart / markJobComplete / markJobFailed.
// ═══════════════════════════════════════════════════════════════════════
import { db } from "./firebase.ts";

export interface CronJobRecord {
  jobName: string;
  status: "running" | "success" | "failed" | "skipped";
  startedAt: string;
  completedAt?: string;
  durationMs?: number;
  failureCount?: number;
  message?: string;
  processedItems?: number;
}

const HEALTH_COLLECTION = "cron_health_logs";
const HEALTH_SUMMARY_COLLECTION = "cron_health_summary";

/** Write a "running" record and return its doc ID for later update. */
export async function markJobStart(jobName: string): Promise<string> {
  const now = new Date().toISOString();
  const ref = await db.collection(HEALTH_COLLECTION).add({
    jobName,
    status: "running",
    startedAt: now,
    updatedAt: now,
  });
  return ref.id;
}

/** Update the doc written by markJobStart with success outcome. */
export async function markJobComplete(
  logId: string,
  jobName: string,
  startMs: number,
  opts: { processedItems?: number; message?: string } = {}
): Promise<void> {
  const durationMs = Date.now() - startMs;
  const now = new Date().toISOString();

  await db.collection(HEALTH_COLLECTION).doc(logId).update({
    status: "success",
    completedAt: now,
    durationMs,
    processedItems: opts.processedItems ?? 0,
    message: opts.message ?? "Completed successfully",
    updatedAt: now,
  });

  // Upsert summary doc (last run / next run estimates / running counts)
  await db.collection(HEALTH_SUMMARY_COLLECTION).doc(jobName).set({
    jobName,
    lastStatus: "success",
    lastRun: now,
    lastDurationMs: durationMs,
    lastProcessedItems: opts.processedItems ?? 0,
    updatedAt: now,
  }, { merge: true });
}

/** Update the doc with failure details and increment failure counter. */
export async function markJobFailed(
  logId: string,
  jobName: string,
  startMs: number,
  errorMessage: string
): Promise<void> {
  const durationMs = Date.now() - startMs;
  const now = new Date().toISOString();

  await db.collection(HEALTH_COLLECTION).doc(logId).update({
    status: "failed",
    completedAt: now,
    durationMs,
    errorMessage,
    updatedAt: now,
  });

  // Read existing summary to increment failure count
  const summaryRef = db.collection(HEALTH_SUMMARY_COLLECTION).doc(jobName);
  const summarySnap = await summaryRef.get();
  const existingFailures = summarySnap.exists ? (summarySnap.data()!.totalFailures ?? 0) : 0;

  await summaryRef.set({
    jobName,
    lastStatus: "failed",
    lastRun: now,
    lastDurationMs: durationMs,
    lastError: errorMessage,
    totalFailures: existingFailures + 1,
    updatedAt: now,
  }, { merge: true });
}

/** Mark job as skipped (e.g., automation disabled). */
export async function markJobSkipped(
  logId: string,
  jobName: string,
  reason: string
): Promise<void> {
  const now = new Date().toISOString();
  await db.collection(HEALTH_COLLECTION).doc(logId).update({
    status: "skipped",
    completedAt: now,
    message: reason,
    updatedAt: now,
  });

  await db.collection(HEALTH_SUMMARY_COLLECTION).doc(jobName).set({
    jobName,
    lastStatus: "skipped",
    lastRun: now,
    lastSkipReason: reason,
    updatedAt: now,
  }, { merge: true });
}
