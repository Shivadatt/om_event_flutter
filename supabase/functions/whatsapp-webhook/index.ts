import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyMetaWebhook } from "../_shared/hmac.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// whatsapp-webhook
//
// Receives Meta WhatsApp Business Platform delivery events.
// GET  → webhook verification challenge (hub.challenge)
// POST → delivery status callbacks
// Security: HMAC-SHA256 via x-hub-signature-256 header.
// Idempotency: deduplicates on message ID.
// ─────────────────────────────────────────────────────────────────────────────

const WHATSAPP_WEBHOOK_SECRET = Deno.env.get("WHATSAPP_WEBHOOK_SECRET") ?? "my_secure_verify_token";
const META_APP_SECRET = Deno.env.get("META_APP_SECRET") ?? "";

serve(async (req) => {
  // ── META WEBHOOK VERIFICATION CHALLENGE ───────────────────────────────────
  if (req.method === "GET") {
    const url = new URL(req.url);
    const mode = url.searchParams.get("hub.mode");
    const token = url.searchParams.get("hub.verify_token");
    const challenge = url.searchParams.get("hub.challenge");

    if (mode === "subscribe" && token === WHATSAPP_WEBHOOK_SECRET) {
      return new Response(challenge, { status: 200 });
    }
    return new Response("Forbidden", { status: 403 });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const rawBody = await req.text();

  // ── HMAC SIGNATURE VERIFICATION ───────────────────────────────────────────
  if (META_APP_SECRET) {
    const isValid = await verifyMetaWebhook(META_APP_SECRET, req.headers, rawBody);
    if (!isValid) {
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  let body: Record<string, unknown>;
  try {
    body = JSON.parse(rawBody);
  } catch {
    return new Response("Bad Request", { status: 400 });
  }

  const statuses = (body as any)?.entry?.[0]?.changes?.[0]?.value?.statuses;
  const msgId = statuses?.[0]?.id ?? `wa_${Date.now()}`;

  return runJob({
    name: "whatsapp-webhook",
    idempotencyKey: `whatsapp_webhook_${msgId}`,
    useLock: false,
    timeoutMs: 15_000,
    execute: async (_signal): Promise<JobResult> => {
      // Log raw webhook
      await db.collection("notification_webhook_logs").add({
        gateway: "whatsapp",
        msgId,
        payload: body,
        receivedAt: new Date().toISOString(),
      });

      if (!statuses?.length) {
        return { processedItems: 0, message: "No status events in payload" };
      }

      const statusObj = statuses[0];
      const status: string = statusObj.status;

      // Idempotency: skip if we already have this exact status for this message
      const existingSnap = await db.collection("notification_delivery_events").doc(msgId).get();
      if (existingSnap.exists && existingSnap.data()?.status === status) {
        return { processedItems: 0, message: `Duplicate: ${msgId} already ${status}` };
      }

      await db.collection("notification_delivery_events").doc(msgId).set({
        logId: msgId,
        event: status,
        status,
        timestamp: new Date().toISOString(),
        details: statusObj,
      }, { merge: true });

      const logsSnap = await db.collection("notification_logs")
        .where("externalId", "==", msgId)
        .limit(5)
        .get();

      if (!logsSnap.empty) {
        const batch = db.batch();
        logsSnap.docs.forEach((doc) =>
          batch.update(doc.ref, { status, updatedAt: new Date().toISOString() })
        );
        await batch.commit();
      }

      return { processedItems: 1, message: `Processed WhatsApp ${status} for ${msgId}` };
    },
  });
});
