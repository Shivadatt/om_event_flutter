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
    const bookingId = body.bookingId;

    if (!bookingId) {
      return new Response("Missing bookingId", { status: 400 });
    }

    const doc = await db.collection("bookings").doc(bookingId).get();
    if (!doc.exists) {
      return new Response("Booking not found", { status: 404 });
    }

    const booking = doc.data()!;

    if (eventType === "created") {
      await db.collection("notification_queue").add({
        recipient: ADMIN_EMAIL,
        recipientId: "admin_main",
        type: "Booking Created",
        title: "New Booking Request",
        body: `Submitted by ${booking.customer_name || 'Customer'}`,
        channel: "email",
        status: "pending",
        retryCount: 0,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

      await db.collection("notification_queue").add({
        recipient: ADMIN_PHONE,
        recipientId: "admin_main",
        type: "Booking Created",
        title: "WhatsApp Alert",
        body: `New Booking from ${booking.customer_name || 'Customer'}`,
        channel: "whatsapp",
        status: "pending",
        retryCount: 0,
        metadata: {
          templateName: "admin_alerts",
          parameters: ["Booking Created", booking.customer_name || "Customer"]
        },
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
    } else if (eventType === "updated") {
      const status = booking.status;
      const customerId = booking.customerId || "";
      const email = booking.customer_email || "customer@gmail.com";
      const phone = booking.customer_phone || "";

      if (status === "confirmed" || status === "approved") {
        await db.collection("notification_queue").add({
          recipient: email,
          recipientId: customerId,
          type: "Booking Approved",
          title: "Booking Accepted!",
          body: "Your event has been approved by Om Events.",
          channel: "email",
          status: "pending",
          retryCount: 0,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });

        if (phone) {
          await db.collection("notification_queue").add({
            recipient: phone,
            recipientId: customerId,
            type: "Booking Approved",
            title: "WhatsApp Alert",
            body: "Booking approved",
            channel: "whatsapp",
            status: "pending",
            retryCount: 0,
            metadata: {
              templateName: "booking_approved",
              parameters: [booking.booking_number || ""]
            },
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
          });
        }
      } else if (status === "cancelled" || status === "rejected") {
        await db.collection("notification_queue").add({
          recipient: email,
          recipientId: customerId,
          type: "Booking Rejected",
          title: "Booking Update",
          body: "Your booking request was cancelled.",
          channel: "email",
          status: "pending",
          retryCount: 0,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        });

        if (phone) {
          await db.collection("notification_queue").add({
            recipient: phone,
            recipientId: customerId,
            type: "Booking Rejected",
            title: "WhatsApp Alert",
            body: "Booking update",
            channel: "whatsapp",
            status: "pending",
            retryCount: 0,
            metadata: {
              templateName: "booking_rejected",
              parameters: [booking.booking_number || ""]
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
