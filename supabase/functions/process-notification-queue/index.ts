import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { getMessaging } from "https://esm.sh/firebase-admin@11.8.0/messaging";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";
import { checkRateLimit, NOTIFICATION_RATE_LIMITS } from "../_shared/rate_limiter.ts";

// ─────────────────────────────────────────────────────────────────────────────
// process-notification-queue
// Priority queue processor: high > normal > low, FIFO within each tier.
// DND quiet-hours, idempotency, template variables, A/B testing,
// rate limiting, real delivery via Resend / Meta / FCM.
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") || "";
const WHATSAPP_TOKEN = Deno.env.get("WHATSAPP_TOKEN") || "";
const WHATSAPP_PHONE_ID = Deno.env.get("WHATSAPP_PHONE_ID") || "";
const SENDER_EMAIL = Deno.env.get("SENDER_EMAIL") || "notifications@omevents.com";
const BATCH_SIZE = 50; // Process at most 50 per run

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  try {
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);
  } catch (e) {
    return new Response(JSON.stringify({ status: "error", error: e.message }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  return runJob({
    name: "process-notification-queue",
    maxRetries: 1,
    timeoutMs: 55_000,
    execute: async (_signal) => {
      const settingsSnap = await db.collection("automation_settings").doc("global_config").get();
      const maxRetries = settingsSnap.exists ? (settingsSnap.data()!.retryCount ?? 5) : 5;

      const now = new Date();

      // Fetch pending queue items — skip retry items (handled by process-retry-queue)
      const queueSnap = await db.collection("notification_queue")
        .where("status", "in", ["pending", "paused_dnd"])
        .limit(BATCH_SIZE)
        .get();

      if (queueSnap.empty) {
        return { processedItems: 0, message: "Queue is empty" };
      }

      // Sort: high → normal → low, then by createdAt ascending
      const priorityWeight: Record<string, number> = { high: 3, normal: 2, low: 1 };
      const sortedDocs = [...queueSnap.docs].sort((a, b) => {
        const dA = a.data(), dB = b.data();
        const pA = priorityWeight[dA.priority ?? "normal"] ?? 2;
        const pB = priorityWeight[dB.priority ?? "normal"] ?? 2;
        if (pA !== pB) return pB - pA;
        return new Date(dA.createdAt ?? 0).getTime() - new Date(dB.createdAt ?? 0).getTime();
      });

      let processedCount = 0;
      let pausedDndCount = 0;
      let dlqCount = 0;
      let failedCount = 0;

      for (const doc of sortedDocs) {
        const task = doc.data();
        const taskId = doc.id;
        const recipientId = task.recipientId ?? "";
        const priority = task.priority ?? "normal";
        const channel: string = task.channel ?? "push";
        const recipient: string = task.recipient ?? "";
        let title: string = task.title ?? "";
        let body: string = task.body ?? "";
        const type = task.type ?? "Alert";
        const quotationId = task.quotationId ?? "";

        // ── IDEMPOTENCY CHECK ──────────────────────────────────────────────
        if (task.idempotencyKey) {
          const dupSnap = await db.collection("notification_logs")
            .where("idempotencyKey", "==", task.idempotencyKey)
            .where("status", "==", "sent")
            .limit(1)
            .get();
          if (!dupSnap.empty) {
            await doc.ref.update({ status: "skipped_duplicate", updatedAt: now.toISOString() });
            continue;
          }
        }

        // ── DND QUIET HOURS CHECK ──────────────────────────────────────────
        if (priority !== "high" && recipientId) {
          const inDnd = await checkQuietHours(recipientId, now);
          if (inDnd) {
            await doc.ref.update({ status: "paused_dnd", updatedAt: now.toISOString() });
            pausedDndCount++;
            continue;
          }
        }

        // ── RATE LIMIT CHECK ───────────────────────────────────────────────
        if (recipientId && priority !== "high") {
          const rlConfig = NOTIFICATION_RATE_LIMITS[channel] ?? NOTIFICATION_RATE_LIMITS["push"];
          const rl = await checkRateLimit("notification_queue", recipientId, rlConfig);
          if (!rl.allowed) {
            await doc.ref.update({
              status: "paused_rate_limited",
              updatedAt: now.toISOString(),
              rateLimitResetAt: rl.resetAt,
            });
            continue;
          }
        }

        // ── TEMPLATE VARIABLE PARSER ──────────────────────────────────────
        const variables = task.variables ?? {};
        for (const [k, v] of Object.entries(variables)) {
          const rx = new RegExp(`{{${k}}}`, "g");
          title = title.replace(rx, String(v));
          body = body.replace(rx, String(v));
        }

        // ── A/B TESTING SPLIT ─────────────────────────────────────────────
        const abVariant = Math.random() > 0.5 ? "Variant A" : "Variant B";
        if (abVariant === "Variant B") {
          body = `${body} [Save 10% on next rebook!]`;
        }

        // ── DELIVERY ──────────────────────────────────────────────────────
        let success = false;
        let errorMessage = "";
        let externalMessageId = "";

        try {
          if (channel === "email") {
            const res = await fetch("https://api.resend.com/emails", {
              method: "POST",
              headers: {
                Authorization: `Bearer ${RESEND_API_KEY}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({ from: SENDER_EMAIL, to: [recipient], subject: title, html: body }),
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.message ?? `Resend error ${res.status}`);
            success = true;
            externalMessageId = data.id ?? "";
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
                    components: task.metadata?.parameters?.length
                      ? [{ type: "body", parameters: task.metadata.parameters.map((p: string) => ({ type: "text", text: p })) }]
                      : [],
                  },
                }),
              }
            );
            const data = await res.json();
            if (!res.ok) throw new Error(data.error?.message ?? `Meta error ${res.status}`);
            success = true;
            externalMessageId = data.messages?.[0]?.id ?? "";
          } else if (channel === "push") {
            const tokensSnap = await db.collection("notification_tokens")
              .where("userId", "==", recipientId)
              .get();
            if (!tokensSnap.empty) {
              const messaging = getMessaging();
              const results = await Promise.allSettled(
                tokensSnap.docs.map((tdoc: any) =>
                  messaging.send({
                    notification: { title, body },
                    token: tdoc.data().deviceToken,
                    data: { click_action: "FLUTTER_NOTIFICATION_CLICK" },
                  })
                )
              );
              externalMessageId = (results[0] as PromiseFulfilledResult<string>)?.value ?? "";
            }
            success = true;
          } else {
            throw new Error(`Unsupported channel: ${channel}`);
          }
        } catch (err: unknown) {
          errorMessage = err instanceof Error ? err.message : String(err);
        }

        if (success) {
          await doc.ref.update({
            status: "sent",
            processedAt: now.toISOString(),
            updatedAt: now.toISOString(),
            externalId: externalMessageId,
          });
          await db.collection("notification_logs").doc(taskId).set({
            recipientId, quotationId, type, title, body,
            channelsUsed: [channel],
            status: "sent",
            externalId: externalMessageId,
            variant: abVariant,
            priority,
            sentAt: now.toISOString(),
            idempotencyKey: task.idempotencyKey ?? null,
          });
          processedCount++;
        } else {
          const nextRetry = (task.retryCount ?? 0) + 1;
          if (nextRetry >= maxRetries) {
            await db.collection("dead_letter_notifications").add({
              queueId: taskId, reason: errorMessage, channel, payload: task,
              retryCount: nextRetry, timestamp: now.toISOString(),
            });
            await doc.ref.update({
              status: "failed_dlq",
              retryCount: nextRetry,
              errorMessage,
              updatedAt: now.toISOString(),
            });
            dlqCount++;
          } else {
            // Move to retry with backoff delay
            const retryAfterMs = Math.min(30_000 * Math.pow(2, nextRetry - 1), 3_600_000);
            await doc.ref.update({
              status: "retry",
              retryCount: nextRetry,
              errorMessage,
              retryAfter: new Date(now.getTime() + retryAfterMs).toISOString(),
              updatedAt: now.toISOString(),
            });
            failedCount++;
          }
          await db.collection("notification_logs").add({
            recipientId, quotationId, type, title,
            body: `Failed (Attempt ${nextRetry}/${maxRetries}): ${errorMessage}`,
            channelsUsed: [channel],
            status: "failed",
            sentAt: now.toISOString(),
          });
        }
      }

      return {
        processedItems: processedCount,
        metadata: { pausedDndCount, dlqCount, failedCount },
        message: `Sent: ${processedCount} | Paused DND: ${pausedDndCount} | DLQ: ${dlqCount} | Retry: ${failedCount}`,
      };
    },
  });
});

async function checkQuietHours(userId: string, now: Date): Promise<boolean> {
  try {
    const doc = await db.collection("customer_notification_preferences").doc(userId).get();
    if (!doc.exists) return false;
    const data = doc.data()!;
    if (!data.dndEnabled) return false;
    const [sh, sm] = (data.quietHoursStart ?? "22:00").split(":").map(Number);
    const [eh, em] = (data.quietHoursEnd ?? "07:00").split(":").map(Number);
    const start = new Date(now); start.setHours(sh, sm, 0, 0);
    const end = new Date(now); end.setHours(eh, em, 0, 0);
    return end < start
      ? now >= start || now < end
      : now >= start && now < end;
  } catch (_) { return false; }
}
