import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { markJobStart, markJobComplete, markJobFailed, markJobSkipped } from "../_shared/cron_monitor.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const JOB_NAME = "send-expiry-reminders";

serve(async (req) => {
  const tStart = Date.now();
  const logId = await markJobStart(JOB_NAME);
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const settingsSnap = await db.collection("automation_settings").doc("global_config").get();
    let isEnabled = true;
    let expiryDurationDays = 7;
    
    if (settingsSnap.exists) {
      isEnabled = settingsSnap.data()!.isEnabled ?? true;
      expiryDurationDays = settingsSnap.data()!.expiryDurationDays ?? 7;
    }

    if (!isEnabled) {
      await markJobSkipped(logId, JOB_NAME, "Automation disabled in settings");
      return new Response(JSON.stringify({ status: "skipped" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const now = new Date();
    const quotesSnap = await db.collection("quotations")
      .where("status", "in", ["published", "republished", "viewed"])
      .get();
    let sentCount = 0;

    for (const doc of quotesSnap.docs) {
      const quote = doc.data();
      const validFromStr = quote.publishedAt ?? quote.createdAt ?? quote.created_at;
      if (!validFromStr) continue;

      const validFrom = new Date(validFromStr);
      const expiryDate = new Date(validFrom.getTime() + expiryDurationDays * 24 * 60 * 60 * 1000);

      // 24h reminder
      const reminder24hTime = new Date(expiryDate.getTime() - 24 * 60 * 60 * 1000);
      if (now > reminder24hTime && now < expiryDate) {
        const remId = `${doc.id}_24h`;
        const remSnap = await db.collection("quotation_reminders").doc(remId).get();
        
        if (!remSnap.exists) {
          await db.collection("quotation_reminders").doc(remId).set({
            quotationId: doc.id,
            type: "24h_before_expiry",
            scheduledAt: reminder24hTime.toISOString(),
            executedAt: now.toISOString(),
            status: "sent",
            retryCount: 0,
          });

          await db.collection("quotation_automation_logs").add({
            quotationId: doc.id,
            automationType: "Expiry Reminder 24h",
            executedAt: now.toISOString(),
            status: "Success",
            details: `24-hour pre-expiry reminder triggered for quotation ${quote.publicId ?? doc.id}.`,
            duration: Date.now() - tStart,
            executedBy: "Supabase Cron",
          });

          await db.collection("notification_queue").add({
            recipient: "Client",
            recipientId: quote.customerId ?? "",
            quotationId: doc.id,
            type: "Reminder",
            title: "Quotation Expires Tomorrow",
            body: `Your quotation ${quote.publicId ?? doc.id} is expiring tomorrow.`,
            status: "pending",
            retryCount: 0,
            idempotencyKey: `expiry_24h_${doc.id}`,
            scheduledAt: now.toISOString(),
            createdAt: now.toISOString(),
            priority: "normal",
          });
          sentCount++;
        }
      }

      // 2h reminder
      const reminder2hTime = new Date(expiryDate.getTime() - 2 * 60 * 60 * 1000);
      if (now > reminder2hTime && now < expiryDate) {
        const remId = `${doc.id}_2h`;
        const remSnap = await db.collection("quotation_reminders").doc(remId).get();

        if (!remSnap.exists) {
          await db.collection("quotation_reminders").doc(remId).set({
            quotationId: doc.id,
            type: "2h_before_expiry",
            scheduledAt: reminder2hTime.toISOString(),
            executedAt: now.toISOString(),
            status: "sent",
            retryCount: 0,
          });

          await db.collection("quotation_automation_logs").add({
            quotationId: doc.id,
            automationType: "Expiry Reminder 2h",
            executedAt: now.toISOString(),
            status: "Success",
            details: `2-hour pre-expiry reminder triggered for quotation ${quote.publicId ?? doc.id}.`,
            duration: Date.now() - tStart,
            executedBy: "Supabase Cron",
          });

          await db.collection("notification_queue").add({
            recipient: "Client",
            recipientId: quote.customerId ?? "",
            quotationId: doc.id,
            type: "Reminder",
            title: "Quotation Expires Soon",
            body: `Your quotation ${quote.publicId ?? doc.id} expires in 2 hours.`,
            status: "pending",
            retryCount: 0,
            idempotencyKey: `expiry_2h_${doc.id}`,
            scheduledAt: now.toISOString(),
            createdAt: now.toISOString(),
            priority: "high",
          });
          sentCount++;
        }
      }
    }

    await markJobComplete(logId, JOB_NAME, tStart, {
      processedItems: sentCount,
      message: `Sent ${sentCount} expiry reminders`,
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
