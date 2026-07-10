import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// process-retry-queue
//
// Dedicated worker that processes notification_queue items with status="retry"
// whose retryAfter timestamp has passed.
// Exponential backoff: retryCount * 30s, capped at 1 hour.
// Items exceeding maxRetries are moved to dead_letter_notifications (DLQ).
// Scheduled: every 15 minutes via pg_cron.
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") || "";
const WHATSAPP_TOKEN = Deno.env.get("WHATSAPP_TOKEN") || "";
const WHATSAPP_PHONE_ID = Deno.env.get("WHATSAPP_PHONE_ID") || "";
const SENDER_EMAIL = Deno.env.get("SENDER_EMAIL") || "notifications@omevents.com";

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
    name: "process-retry-queue",
    maxRetries: 1,
    timeoutMs: 55_000,
    execute: async (_signal): Promise<JobResult> => {
      const settingsSnap = await db.collection("automation_settings").doc("global_config").get();
      const maxRetries = settingsSnap.exists ? (settingsSnap.data()!.retryCount ?? 5) : 5;

      const now = new Date();

      // Fetch retry items whose backoff window has passed
      const retrySnap = await db.collection("notification_queue")
        .where("status", "==", "retry")
        .limit(30)
        .get();

      if (retrySnap.empty) {
        return { processedItems: 0, message: "Retry queue empty" };
      }

      const eligibleDocs = retrySnap.docs.filter((doc) => {
        const retryAfter = doc.data().retryAfter;
        if (!retryAfter) return true;
        return new Date(retryAfter) <= now;
      });

      if (eligibleDocs.length === 0) {
        return { processedItems: 0, message: "No eligible retry items (all in backoff window)" };
      }

      let requeuedCount = 0;
      let dlqCount = 0;

      for (const doc of eligibleDocs) {
        const task = doc.data();
        const retryCount = task.retryCount ?? 0;

        if (retryCount >= maxRetries) {
          // Exceeded max retries — move to DLQ
          await db.collection("dead_letter_notifications").add({
            queueId: doc.id,
            reason: task.errorMessage ?? "Max retries exceeded",
            channel: task.channel ?? "unknown",
            payload: task,
            retryCount,
            timestamp: now.toISOString(),
            source: "process-retry-queue",
          });
          await doc.ref.update({
            status: "failed_dlq",
            updatedAt: now.toISOString(),
          });
          dlqCount++;
          continue;
        }

        // Attempt re-delivery
        let success = false;
        let errorMessage = "";
        let externalId = "";
        const channel: string = task.channel ?? "push";
        const recipient: string = task.recipient ?? "";
        const title: string = task.title ?? "";
        const body: string = task.body ?? "";

        try {
          if (channel === "email") {
            const res = await fetch("https://api.resend.com/emails", {
              method: "POST",
              headers: {
                Authorization: `Bearer ${RESEND_API_KEY}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                from: SENDER_EMAIL,
                to: [recipient],
                subject: title,
                html: body,
              }),
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.message ?? `Resend error ${res.status}`);
            success = true;
            externalId = data.id ?? "";
          } else if (channel === "whatsapp") {
            const res = await fetch(
              `https://graph.facebook.com/v20.0/${WHATSAPP_PHONE_ID}/messages`,
              {
                method: "POST",
                headers: {
                  Authorization: `Bearer ${WHATSAPP_TOKEN}`,
                  "Content-Type": "application/json",
                },
                body: JSON.stringify({
                  messaging_product: "whatsapp",
                  to: recipient,
                  type: "template",
                  template: {
                    name: task.metadata?.templateName ?? "admin_alerts",
                    language: { code: "en_US" },
                    components: [],
                  },
                }),
              }
            );
            const data = await res.json();
            if (!res.ok) throw new Error(data.error?.message ?? `Meta error ${res.status}`);
            success = true;
            externalId = data.messages?.[0]?.id ?? "";
          } else {
            // push and other — mark as success (FCM handled separately)
            success = true;
          }
        } catch (e: unknown) {
          errorMessage = e instanceof Error ? e.message : String(e);
        }

        if (success) {
          await doc.ref.update({
            status: "sent",
            processedAt: now.toISOString(),
            updatedAt: now.toISOString(),
            externalId,
          });
          await db.collection("notification_logs").doc(doc.id).set({
            recipientId: task.recipientId ?? "",
            type: task.type ?? "Alert",
            title,
            body,
            channelsUsed: [channel],
            status: "sent",
            externalId,
            priority: task.priority ?? "normal",
            sentAt: now.toISOString(),
            retriedFrom: "process-retry-queue",
          });
          requeuedCount++;
        } else {
          const nextRetry = retryCount + 1;
          const backoffMs = Math.min(30_000 * Math.pow(2, nextRetry), 3_600_000);
          await doc.ref.update({
            status: "retry",
            retryCount: nextRetry,
            errorMessage,
            retryAfter: new Date(now.getTime() + backoffMs).toISOString(),
            updatedAt: now.toISOString(),
          });
        }
      }

      return {
        processedItems: requeuedCount,
        metadata: { dlqCount, eligible: eligibleDocs.length },
        message: `Re-sent: ${requeuedCount} | DLQ: ${dlqCount}`,
      };
    },
  });
});
