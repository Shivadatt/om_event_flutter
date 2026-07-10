import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const ADMIN_EMAIL = "admin@omevents.com";
const ADMIN_PHONE = "9512149944";

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const body = await req.json();
    const eventType = body.eventType; // 'created' or 'updated'
    const quoteId = body.quoteId;

    if (!quoteId) {
      return new Response("Missing quoteId", { status: 400 });
    }

    const doc = await db.collection("quotations").doc(quoteId).get();
    if (!doc.exists) {
      return new Response("Quotation not found", { status: 404 });
    }

    const quote = doc.data()!;

    if (eventType === "created") {
      const phone = quote.customer_phone || "";
      if (phone) {
        await db.collection("notification_queue").add({
          recipient: phone,
          recipientId: quote.customerId || "customer",
          type: "Quotation Ready",
          title: "WhatsApp Alert",
          body: "Quotation ready",
          channel: "whatsapp",
          status: "pending",
          retryCount: 0,
          metadata: {
            templateName: "quotation_ready",
            parameters: [quote.public_id || ""]
          },
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });
      }
    } else if (eventType === "updated") {
      const status = quote.status;
      const phone = quote.customer_phone || "";
      const publicId = quote.public_id || quoteId;
      const customerName = quote.customer_name || "Customer";

      if (status === "approved" || status === "accepted" || status === "booked") {
        await db.collection("notification_queue").add({
          recipient: ADMIN_EMAIL,
          recipientId: "admin_main",
          type: "Quotation Approved",
          title: `Quotation Approved: ${publicId}`,
          body: `Quotation ${publicId} has been approved/booked by customer ${customerName}.`,
          channel: "email",
          status: "pending",
          retryCount: 0,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });

        await db.collection("notification_queue").add({
          recipient: ADMIN_PHONE,
          recipientId: "admin_main",
          type: "Quotation Approved",
          title: "WhatsApp Alert",
          body: `Quotation ${publicId} booked`,
          channel: "whatsapp",
          status: "pending",
          retryCount: 0,
          metadata: {
            templateName: "admin_alerts",
            parameters: ["Quotation Approved", customerName]
          },
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });

        if (phone) {
          await db.collection("notification_queue").add({
            recipient: phone,
            recipientId: quote.customerId || "customer",
            type: "Quotation Approved",
            title: "WhatsApp Alert",
            body: "Quotation approved",
            channel: "whatsapp",
            status: "pending",
            retryCount: 0,
            metadata: {
              templateName: "quotation_approved",
              parameters: [publicId]
            },
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
          });
        }
      } else if (status === "rejected") {
        if (phone) {
          await db.collection("notification_queue").add({
            recipient: phone,
            recipientId: quote.customerId || "customer",
            type: "Quotation Rejected",
            title: "WhatsApp Alert",
            body: "Quotation rejected",
            channel: "whatsapp",
            status: "pending",
            retryCount: 0,
            metadata: {
              templateName: "quotation_rejected",
              parameters: [publicId]
            },
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
          });
        }
      }
    }

    return new Response(JSON.stringify({ status: "success" }), {
      headers: { "Content-Type": "application/json" }
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});
