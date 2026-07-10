import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { markJobStart, markJobComplete, markJobFailed, markJobSkipped } from "../_shared/cron_monitor.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const JOB_NAME = "send-followups";

serve(async (req) => {
  const tStart = Date.now();
  const logId = await markJobStart(JOB_NAME);
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const settingsSnap = await db.collection("automation_settings").doc("global_config").get();
    let isEnabled = true;
    let followUpIntervalDays = 3;

    if (settingsSnap.exists) {
      isEnabled = settingsSnap.data()!.isEnabled ?? true;
      followUpIntervalDays = settingsSnap.data()!.followUpIntervalDays ?? 3;
    }

    if (!isEnabled) {
      await markJobSkipped(logId, JOB_NAME, "Automation disabled in settings");
      return new Response(JSON.stringify({ status: "skipped" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const now = new Date();
    const quotesSnap = await db.collection("quotations").where("status", "==", "viewed").get();
    let sentCount = 0;

    for (const doc of quotesSnap.docs) {
      const quote = doc.data();
      const customerViewedAtStr = quote.customerViewedAt;
      if (!customerViewedAtStr) continue;

      const viewedAt = new Date(customerViewedAtStr);
      const followUpTime = new Date(viewedAt.getTime() + followUpIntervalDays * 24 * 60 * 60 * 1000);

      if (now > followUpTime) {
        const remId = `${doc.id}_followup`;
        const remSnap = await db.collection("quotation_reminders").doc(remId).get();

        if (!remSnap.exists) {
          await db.collection("quotation_reminders").doc(remId).set({
            quotationId: doc.id,
            type: "viewed_followup",
            scheduledAt: followUpTime.toISOString(),
            executedAt: now.toISOString(),
            status: "sent",
            retryCount: 0,
          });

          await db.collection("quotation_automation_logs").add({
            quotationId: doc.id,
            automationType: "Inactivity Follow-up",
            executedAt: now.toISOString(),
            status: "Success",
            details: `Admin follow-up triggered for viewed quotation ${quote.publicId ?? doc.id} after ${followUpIntervalDays} days of client inactivity.`,
            duration: Date.now() - tStart,
            executedBy: "Supabase Cron",
          });

          await db.collection("notification_queue").add({
            recipient: "Admin",
            recipientId: "Admin",
            quotationId: doc.id,
            type: "FollowUp",
            title: "Customer Has Not Responded",
            body: `Customer has not responded to quotation ${quote.publicId ?? doc.id} viewed on ${viewedAt.toDateString()}.`,
            status: "pending",
            retryCount: 0,
            idempotencyKey: `followup_${doc.id}`,
            scheduledAt: now.toISOString(),
            createdAt: now.toISOString(),
            priority: "normal",
          });
          sentCount++;
        }
      }
    }

    await markJobComplete(logId, JOB_NAME, tStart, {
      processedItems: sentCount,
      message: `Sent ${sentCount} follow-ups`,
    });

    return new Response(JSON.stringify({ status: "success", sentCount }), {
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
