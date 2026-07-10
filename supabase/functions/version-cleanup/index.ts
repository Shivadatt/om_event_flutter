import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// version-cleanup
//
// Cleans up old data that accumulates over time:
//  1. Quotation version snapshots: keep only last 10 per quotation
//  2. Orphaned Storage object references (stale pdfUrl entries)
//  3. Sent notification_queue items older than 30 days
//  4. Processed scheduled_notifications older than 7 days
//  5. Old rate_limit_buckets older than 2 hours
//
// Scheduled: Every Sunday 03:00 via pg_cron.
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const KEEP_VERSIONS = 10;
const SENT_QUEUE_RETENTION_DAYS = 30;
const SCHEDULED_NOTIF_RETENTION_DAYS = 7;
const RATE_LIMIT_RETENTION_HOURS = 2;
const STORAGE_BUCKET = "quotation-pdfs";

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

  return runJob({
    name: "version-cleanup",
    timeoutMs: 55_000,
    execute: async (_signal): Promise<JobResult> => {
      const now = new Date();
      let deletedTotal = 0;

      // ── 1. QUOTATION VERSION SNAPSHOTS ─────────────────────────────────────
      const quotesSnap = await db.collection("quotations").limit(50).get();
      for (const quotDoc of quotesSnap.docs) {
        const versionsSnap = await db.collection("quotations")
          .doc(quotDoc.id)
          .collection("versions")
          .orderBy("createdAt", "desc")
          .get();

        if (versionsSnap.size > KEEP_VERSIONS) {
          const toDelete = versionsSnap.docs.slice(KEEP_VERSIONS);
          const batch = db.batch();
          toDelete.forEach((v) => batch.delete(v.ref));
          await batch.commit();
          deletedTotal += toDelete.length;
        }
      }

      // ── 2. SENT NOTIFICATION QUEUE ITEMS (> 30 days) ────────────────────────
      const queueCutoff = new Date(now.getTime() - SENT_QUEUE_RETENTION_DAYS * 86_400_000);
      const sentQueueSnap = await db.collection("notification_queue")
        .where("status", "in", ["sent", "skipped_duplicate", "failed_dlq"])
        .limit(200)
        .get();

      const sentBatch = db.batch();
      let sentBatchSize = 0;
      for (const doc of sentQueueSnap.docs) {
        const d = doc.data();
        const ts = new Date(d.processedAt ?? d.updatedAt ?? d.createdAt ?? now.toISOString());
        if (ts < queueCutoff) {
          sentBatch.delete(doc.ref);
          sentBatchSize++;
          deletedTotal++;
        }
      }
      if (sentBatchSize > 0) await sentBatch.commit();

      // ── 3. PROCESSED SCHEDULED NOTIFICATIONS (> 7 days) ────────────────────
      const schedCutoff = new Date(now.getTime() - SCHEDULED_NOTIF_RETENTION_DAYS * 86_400_000);
      const schedSnap = await db.collection("scheduled_notifications")
        .where("status", "==", "sent")
        .limit(100)
        .get();

      const schedBatch = db.batch();
      let schedBatchSize = 0;
      for (const doc of schedSnap.docs) {
        const ts = new Date(doc.data().processedAt ?? doc.data().createdAt ?? now.toISOString());
        if (ts < schedCutoff) {
          schedBatch.delete(doc.ref);
          schedBatchSize++;
          deletedTotal++;
        }
      }
      if (schedBatchSize > 0) await schedBatch.commit();

      // ── 4. STALE RATE LIMIT BUCKETS (> 2 hours) ─────────────────────────────
      const rlCutoff = new Date(now.getTime() - RATE_LIMIT_RETENTION_HOURS * 3_600_000);
      const rlSnap = await db.collection("rate_limit_buckets").limit(100).get();
      const rlBatch = db.batch();
      let rlBatchSize = 0;
      for (const doc of rlSnap.docs) {
        const updatedAt = new Date(doc.data().updatedAt ?? "2000-01-01");
        if (updatedAt < rlCutoff) {
          rlBatch.delete(doc.ref);
          rlBatchSize++;
          deletedTotal++;
        }
      }
      if (rlBatchSize > 0) await rlBatch.commit();

      // ── 5. ORPHANED STORAGE OBJECTS ─────────────────────────────────────────
      // List all Storage objects in the bucket and compare against Firestore pdfUrls
      let orphanedCount = 0;
      if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
        try {
          const listRes = await fetch(
            `${SUPABASE_URL}/storage/v1/object/list/${STORAGE_BUCKET}?prefix=contracts/`,
            {
              headers: { Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}` },
            }
          );
          if (listRes.ok) {
            const storageItems = await listRes.json() as Array<{ name: string }>;
            const firestoreIds = new Set(quotesSnap.docs.map((d) => d.id));

            for (const item of storageItems) {
              const docId = item.name.replace("contracts/", "").replace(".html", "");
              if (!firestoreIds.has(docId)) {
                // Orphaned — delete from storage
                await fetch(
                  `${SUPABASE_URL}/storage/v1/object/${STORAGE_BUCKET}/contracts/${item.name}`,
                  {
                    method: "DELETE",
                    headers: { Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}` },
                  }
                );
                orphanedCount++;
                deletedTotal++;
              }
            }
          }
        } catch (_) {
          // Storage cleanup is best-effort
        }
      }

      return {
        processedItems: deletedTotal,
        metadata: {
          sentQueueCleaned: sentBatchSize,
          scheduledNotifCleaned: schedBatchSize,
          rateLimitCleaned: rlBatchSize,
          orphanedStorageCleaned: orphanedCount,
        },
        message: `Cleaned ${deletedTotal} records total`,
      };
    },
  });
});
