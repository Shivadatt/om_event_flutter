import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// process-dlq
//
// Dead Letter Queue inspector + requeue utility.
// Supports two modes:
//   GET  → list DLQ items with optional filter
//   POST → requeue specific items or all items matching a jobName filter
//
// Scheduled: Daily 04:00 via pg_cron (auto-requeue items < 24h old).
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const DLQ_COLLECTION = "dead_letter_notifications";
const JOB_DLQ_COLLECTION = "job_dead_letter_queue";
const MAX_AUTO_REQUEUE_AGE_HOURS = 24;

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  try {
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ status: "error", error: msg }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  if (req.method === "GET") {
    return handleListDlq(req);
  }

  // POST — requeue
  return runJob({
    name: "process-dlq",
    maxRetries: 1,
    timeoutMs: 55_000,
    execute: async (_signal): Promise<JobResult> => {
      const body = req.headers.get("content-length") !== "0"
        ? await req.json().catch(() => ({}))
        : {};

      const { mode = "auto", itemIds, jobName } = body as {
        mode?: "auto" | "manual";
        itemIds?: string[];
        jobName?: string;
      };

      const now = new Date();
      let requeuedCount = 0;
      let skippedCount = 0;

      // ── MANUAL REQUEUE specific item IDs ──────────────────────────────────
      if (mode === "manual" && itemIds?.length) {
        for (const id of itemIds) {
          const docSnap = await db.collection(DLQ_COLLECTION).doc(id).get();
          if (!docSnap.exists) { skippedCount++; continue; }

          const item = docSnap.data()!;
          await db.collection("notification_queue").add({
            ...item.payload,
            status: "pending",
            retryCount: 0,
            errorMessage: "",
            requeuedFromDlq: true,
            requeuedAt: now.toISOString(),
            createdAt: now.toISOString(),
            updatedAt: now.toISOString(),
          });
          await docSnap.ref.update({
            status: "requeued",
            requeuedAt: now.toISOString(),
            requeueCount: (item.requeueCount ?? 0) + 1,
          });
          await db.collection("dlq_audit_log").add({
            itemId: id, jobName: item.jobName ?? "notification",
            action: "manual_requeue", triggeredAt: now.toISOString(),
          });
          requeuedCount++;
        }

        return { processedItems: requeuedCount, skippedItems: skippedCount, message: `Manual requeue: ${requeuedCount}` };
      }

      // ── AUTO REQUEUE items < 24h old (pg_cron triggered) ─────────────────
      const cutoff = new Date(now.getTime() - MAX_AUTO_REQUEUE_AGE_HOURS * 3_600_000);
      const dlqSnap = await db.collection(DLQ_COLLECTION)
        .where("status", "==", "dead")
        .limit(20)
        .get();

      for (const doc of dlqSnap.docs) {
        const item = doc.data();
        const failedAt = new Date(item.timestamp ?? now.toISOString());

        // Only auto-requeue items that failed recently
        if (failedAt < cutoff) { skippedCount++; continue; }
        // Skip items that have been requeued too many times already
        if ((item.requeueCount ?? 0) >= 3) { skippedCount++; continue; }
        // Skip if jobName filter specified
        if (jobName && item.jobName !== jobName) { skippedCount++; continue; }

        if (item.payload) {
          await db.collection("notification_queue").add({
            ...item.payload,
            status: "pending",
            retryCount: 0,
            errorMessage: "",
            requeuedFromDlq: true,
            requeuedAt: now.toISOString(),
            createdAt: now.toISOString(),
            updatedAt: now.toISOString(),
          });
        }

        await doc.ref.update({
          status: "requeued",
          requeuedAt: now.toISOString(),
          requeueCount: (item.requeueCount ?? 0) + 1,
        });
        await db.collection("dlq_audit_log").add({
          itemId: doc.id, jobName: item.jobName ?? "notification",
          action: "auto_requeue", triggeredAt: now.toISOString(),
        });
        requeuedCount++;
      }

      return {
        processedItems: requeuedCount,
        skippedItems: skippedCount,
        message: `Auto-requeued: ${requeuedCount} | Skipped: ${skippedCount}`,
      };
    },
  });
});

async function handleListDlq(req: Request): Promise<Response> {
  const url = new URL(req.url);
  const filter = url.searchParams.get("jobName");
  const statusFilter = url.searchParams.get("status") ?? "dead";

  let query: any = db.collection("dead_letter_notifications")
    .where("status", "==", statusFilter)
    .limit(50);

  if (filter) {
    query = query.where("jobName", "==", filter);
  }

  const snap = await query.get();
  const items = snap.docs.map((d: any) => ({ id: d.id, ...d.data() }));

  return new Response(JSON.stringify({ status: "success", count: items.length, items }), {
    headers: { "Content-Type": "application/json" },
  });
}
