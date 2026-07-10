import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { markJobStart, markJobComplete, markJobFailed } from "../_shared/cron_monitor.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const JOB_NAME = "cleanup-old-automation-logs";
const RETENTION_DAYS = 30;

serve(async (req) => {
  const tStart = Date.now();
  const logId = await markJobStart(JOB_NAME);
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const now = new Date();
    const cutoffDate = new Date(now.getTime() - RETENTION_DAYS * 24 * 60 * 60 * 1000);

    // Clean automation logs
    const logsSnap = await db.collection("quotation_automation_logs").get();
    let deletedCount = 0;
    const batch = db.batch();

    for (const doc of logsSnap.docs) {
      const data = doc.data();
      const executedAtStr = data.executedAt;
      if (executedAtStr) {
        const executedAt = new Date(executedAtStr);
        if (executedAt < cutoffDate) {
          batch.delete(doc.ref);
          deletedCount++;
        }
      }
    }

    // Clean cron health logs older than 30 days
    const healthLogsSnap = await db.collection("cron_health_logs").get();
    for (const doc of healthLogsSnap.docs) {
      const data = doc.data();
      const startedAtStr = data.startedAt;
      if (startedAtStr) {
        const startedAt = new Date(startedAtStr);
        if (startedAt < cutoffDate) {
          batch.delete(doc.ref);
          deletedCount++;
        }
      }
    }

    if (deletedCount > 0) {
      await batch.commit();
    }

    await markJobComplete(logId, JOB_NAME, tStart, {
      processedItems: deletedCount,
      message: `Deleted ${deletedCount} log entries older than ${RETENTION_DAYS} days`,
    });

    return new Response(JSON.stringify({ status: "success", deletedCount }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    await markJobFailed(logId, JOB_NAME, tStart, e.message);
    return new Response(JSON.stringify({ status: "error", error: e.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
