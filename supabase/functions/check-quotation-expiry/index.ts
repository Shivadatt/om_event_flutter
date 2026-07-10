import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { markJobStart, markJobComplete, markJobFailed, markJobSkipped } from "../_shared/cron_monitor.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const JOB_NAME = "check-quotation-expiry";

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
      const d = settingsSnap.data()!;
      isEnabled = d.isEnabled ?? true;
      expiryDurationDays = d.expiryDurationDays ?? 7;
    }

    if (!isEnabled) {
      await markJobSkipped(logId, JOB_NAME, "Automation disabled in settings");
      return new Response(JSON.stringify({ status: "skipped", reason: "Automation disabled" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const now = new Date();
    const quotesSnap = await db.collection("quotations").get();
    let expiredCount = 0;

    for (const doc of quotesSnap.docs) {
      const quote = doc.data();
      const status = quote.status ?? "draft";
      
      if (["completed", "cancelled", "archived", "expired"].includes(status)) continue;

      const validFromStr = quote.publishedAt ?? quote.createdAt ?? quote.created_at;
      if (!validFromStr) continue;
      
      const validFrom = new Date(validFromStr);
      const expiryDate = new Date(validFrom.getTime() + expiryDurationDays * 24 * 60 * 60 * 1000);

      if (now > expiryDate) {
        await doc.ref.update({
          status: "expired",
          updated_at: now.toISOString(),
          updatedAt: now.toISOString(),
        });

        await db.collection("quotation_automation_logs").add({
          quotationId: doc.id,
          automationType: "Expiry Check",
          executedAt: now.toISOString(),
          status: "Success",
          details: `Quotation ${quote.publicId ?? doc.id} expired automatically after ${expiryDurationDays} days.`,
          duration: Date.now() - tStart,
          executedBy: "Supabase Cron",
        });

        // Notify customer
        await db.collection("notification_queue").add({
          recipient: "Client",
          recipientId: quote.customerId ?? "",
          quotationId: doc.id,
          type: "Expired",
          title: "Quotation Expired",
          body: `Your quotation ${quote.publicId ?? doc.id} has expired.`,
          status: "pending",
          retryCount: 0,
          idempotencyKey: `expiry_client_${doc.id}`,
          scheduledAt: now.toISOString(),
          createdAt: now.toISOString(),
          priority: "normal",
        });

        // Notify admin
        await db.collection("notification_queue").add({
          recipient: "Admin",
          recipientId: "Admin",
          quotationId: doc.id,
          type: "Expired",
          title: "Quotation Expired",
          body: `Quotation ${quote.publicId ?? doc.id} has expired automatically.`,
          status: "pending",
          retryCount: 0,
          idempotencyKey: `expiry_admin_${doc.id}`,
          scheduledAt: now.toISOString(),
          createdAt: now.toISOString(),
          priority: "normal",
        });

        expiredCount++;
      }
    }

    await markJobComplete(logId, JOB_NAME, tStart, {
      processedItems: expiredCount,
      message: `Expired ${expiredCount} quotations`,
    });

    return new Response(JSON.stringify({ status: "success", expiredCount }), {
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
