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
    const paymentId = body.paymentId;

    if (!paymentId) {
      return new Response("Missing paymentId", { status: 400 });
    }

    const doc = await db.collection("payments").doc(paymentId).get();
    if (!doc.exists) {
      return new Response("Payment not found", { status: 404 });
    }

    const payment = doc.data()!;

    if (eventType === "created") {
      await db.collection("notification_queue").add({
        recipient: ADMIN_EMAIL,
        recipientId: "admin_main",
        type: "Payment Created",
        title: "Verify Payment Receipt",
        body: `Amount: ₹${payment.amount || 0}`,
        channel: "email",
        status: "pending",
        retryCount: 0,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

      await db.collection("notification_queue").add({
        recipient: ADMIN_PHONE,
        recipientId: "admin_main",
        type: "Payment Created",
        title: "WhatsApp Alert",
        body: "Verify payment",
        channel: "whatsapp",
        status: "pending",
        retryCount: 0,
        metadata: {
          templateName: "payment_received",
          parameters: [payment.bookingId || "", (payment.amount || 0).toString()]
        },
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
    } else if (eventType === "updated") {
      const status = payment.status;
      if (status === "approved" || status === "verified") {
        await db.collection("notification_queue").add({
          recipient: payment.customer_phone || "",
          recipientId: payment.customerId || "customer",
          type: "Payment Approved",
          title: "WhatsApp Alert",
          body: "Payment approved",
          channel: "whatsapp",
          status: "pending",
          retryCount: 0,
          metadata: {
            templateName: "payment_approved",
            parameters: [(payment.amount || 0).toString()]
          },
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });
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
