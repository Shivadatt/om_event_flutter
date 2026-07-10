import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyResendWebhook } from "../_shared/hmac.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// resend-webhook
//
// Receives Resend email delivery events.
// Security: HMAC-SHA256 signature verification (svix headers).
// Idempotency: skips already-processed svix-id events.
// Events: email.delivered, email.opened, email.clicked, email.bounced
// ─────────────────────────────────────────────────────────────────────────────

const RESEND_WEBHOOK_SECRET = Deno.env.get("RESEND_WEBHOOK_SECRET") ?? "";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const rawBody = await req.text();
  const svixId = req.headers.get("svix-id") ?? "";

  // ── HMAC SIGNATURE VERIFICATION ───────────────────────────────────────────
  if (RESEND_WEBHOOK_SECRET) {
    const isValid = await verifyResendWebhook(RESEND_WEBHOOK_SECRET, req.headers, rawBody);
    if (!isValid) {
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  return runJob({
    name: "resend-webhook",
    idempotencyKey: svixId ? `resend_webhook_${svixId}` : undefined,
    useLock: false,
    timeoutMs: 15_000,
    execute: async (_signal): Promise<JobResult> => {
      let body: Record<string, unknown>;
      try {
        body = JSON.parse(rawBody);
      } catch {
        return { processedItems: 0, message: "Invalid JSON body" };
      }

      // Log raw webhook
      await db.collection("notification_webhook_logs").add({
        gateway: "resend",
        svixId,
        payload: body,
        receivedAt: new Date().toISOString(),
      });

      const emailId = (body.data as any)?.id ?? "";
      const eventType = body.type as string ?? "";

      if (!emailId) {
        return { processedItems: 0, message: "No emailId in payload" };
      }

      const statusMap: Record<string, string> = {
        "email.sent": "sent",
        "email.delivered": "delivered",
        "email.opened": "opened",
        "email.clicked": "clicked",
        "email.bounced": "failed",
        "email.complained": "spam",
      };
      const cleanStatus = statusMap[eventType] ?? "unknown";

      await db.collection("notification_delivery_events").doc(emailId).set({
        logId: emailId,
        event: eventType,
        status: cleanStatus,
        timestamp: new Date().toISOString(),
        details: body,
      }, { merge: true });

      // Update notification_logs by externalId
      const logsSnap = await db.collection("notification_logs")
        .where("externalId", "==", emailId)
        .limit(5)
        .get();

      if (!logsSnap.empty) {
        const batch = db.batch();
        logsSnap.docs.forEach((doc) =>
          batch.update(doc.ref, { status: cleanStatus, updatedAt: new Date().toISOString() })
        );
        await batch.commit();
      }

      return { processedItems: 1, message: `Processed ${eventType} for email ${emailId}` };
    },
  });
});
