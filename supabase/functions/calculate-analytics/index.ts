import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// calculate-analytics
//
// Computes system-wide analytics and writes to automation_analytics/global.
// Metrics: quotation funnel, notification delivery rates, DLQ health,
//          automation job health, queue depth, retry rate.
// Scheduled: Daily 02:00 via pg_cron.
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";

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
    name: "calculate-analytics",
    timeoutMs: 55_000,
    execute: async (_signal): Promise<JobResult> => {
      const now = new Date();

      // ── AUTOMATION LOGS ───────────────────────────────────────────────────
      const logsSnap = await db.collection("quotation_automation_logs").get();
      let autoTotal = 0, autoSuccess = 0, autoFailed = 0, autoTotalDuration = 0;
      for (const doc of logsSnap.docs) {
        const log = doc.data();
        autoTotal++;
        if (log.status === "Success") autoSuccess++;
        if (log.status === "Failed" || log.status === "Error") autoFailed++;
        autoTotalDuration += Number(log.duration ?? 0);
      }

      // ── NOTIFICATION QUEUE STATS ───────────────────────────────────────────
      const queueSnap = await db.collection("notification_queue").get();
      const queueStats: Record<string, number> = {};
      let queueTotal = 0;
      for (const doc of queueSnap.docs) {
        const s = doc.data().status ?? "unknown";
        queueStats[s] = (queueStats[s] ?? 0) + 1;
        queueTotal++;
      }

      // ── NOTIFICATION DELIVERY RATES ────────────────────────────────────────
      const logsNotifSnap = await db.collection("notification_logs").get();
      const deliveryStats: Record<string, number> = {};
      const channelStats: Record<string, number> = {};
      for (const doc of logsNotifSnap.docs) {
        const d = doc.data();
        const s = d.status ?? "unknown";
        deliveryStats[s] = (deliveryStats[s] ?? 0) + 1;
        const ch = (d.channelsUsed as string[])?.[0] ?? "unknown";
        channelStats[ch] = (channelStats[ch] ?? 0) + 1;
      }

      // ── DLQ HEALTH ────────────────────────────────────────────────────────
      const dlqSnap = await db.collection("dead_letter_notifications").get();
      const dlqByStatus: Record<string, number> = {};
      for (const doc of dlqSnap.docs) {
        const s = doc.data().status ?? "dead";
        dlqByStatus[s] = (dlqByStatus[s] ?? 0) + 1;
      }

      // ── QUOTATION FUNNEL ──────────────────────────────────────────────────
      const quotesSnap = await db.collection("quotations").get();
      const quotationFunnel: Record<string, number> = {};
      for (const doc of quotesSnap.docs) {
        const s = doc.data().status ?? "draft";
        quotationFunnel[s] = (quotationFunnel[s] ?? 0) + 1;
      }

      // ── CRON JOB HEALTH SUMMARY ────────────────────────────────────────────
      const cronHealthSnap = await db.collection("cron_health_summary").get();
      let cronHealthy = 0, cronFailed = 0;
      for (const doc of cronHealthSnap.docs) {
        const s = doc.data().lastStatus;
        if (s === "success") cronHealthy++;
        if (s === "failed") cronFailed++;
      }

      const analyticsDoc = {
        // Automation
        automation: {
          totalExecuted: autoTotal,
          successCount: autoSuccess,
          failedCount: autoFailed,
          successRate: autoTotal > 0 ? Math.round((autoSuccess / autoTotal) * 100) : 0,
          averageRuntimeMs: autoTotal > 0 ? Math.round(autoTotalDuration / autoTotal) : 0,
        },
        // Notification queue
        notificationQueue: {
          total: queueTotal,
          byStatus: queueStats,
        },
        // Delivery rates
        notificationDelivery: {
          byStatus: deliveryStats,
          byChannel: channelStats,
          deliveryRate: (() => {
            const sent = (deliveryStats["sent"] ?? 0) + (deliveryStats["delivered"] ?? 0);
            const total = Object.values(deliveryStats).reduce((a, b) => a + b, 0);
            return total > 0 ? Math.round((sent / total) * 100) : 0;
          })(),
        },
        // DLQ
        dlq: {
          byStatus: dlqByStatus,
          totalDead: dlqByStatus["dead"] ?? 0,
          totalRequeued: dlqByStatus["requeued"] ?? 0,
        },
        // Quotation funnel
        quotationFunnel,
        totalQuotations: quotesSnap.size,
        // Cron health
        cronJobs: {
          healthy: cronHealthy,
          failed: cronFailed,
          total: cronHealthSnap.size,
        },
        updatedAt: now.toISOString(),
      };

      await db.collection("automation_analytics").doc("global").set(analyticsDoc);

      return {
        processedItems: 1,
        message: `Analytics refreshed — ${quotesSnap.size} quotations, ${queueTotal} queue items, ${logsNotifSnap.size} notification logs`,
      };
    },
  });
});
