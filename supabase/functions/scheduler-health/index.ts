import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";

// ─────────────────────────────────────────────────────────────────────────────
// scheduler-health
// Returns the complete cron health summary for every registered pg_cron job.
// Also reads the last 20 individual health log entries for each job.
// Called by the Admin Scheduler Health Dashboard.
// ─────────────────────────────────────────────────────────────────────────────
serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const summarySnap = await db.collection("cron_health_summary").get();
    const summaries = summarySnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    const logsSnap = await db.collection("cron_health_logs")
      .orderBy("startedAt", "desc")
      .limit(100)
      .get();
    const logs = logsSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    // Compute next-run estimates based on known cron schedules
    const cronSchedules: Record<string, string> = {
      "check-scheduled-reminders":   "Every 30 min",
      "check-quotation-expiry":       "Every hour (0 min)",
      "send-expiry-reminders":        "Every hour (5 min)",
      "send-followups":               "Every hour (10 min)",
      "send-booking-reminders":       "Daily 06:00",
      "process-notification-queue":   "Every 30 min",
      "cleanup-old-automation-logs":  "Daily 01:00",
      "calculate-analytics":          "Daily 02:00",
      "daily-digest":                 "Daily 09:00",
    };

    const enrichedSummaries = summaries.map((s: any) => ({
      ...s,
      schedule: cronSchedules[s.jobName] ?? "Custom",
    }));

    return new Response(
      JSON.stringify({ status: "success", summaries: enrichedSummaries, recentLogs: logs }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(JSON.stringify({ status: "error", error: e.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
