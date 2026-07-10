import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const ADMIN_PHONE = "9512149944";

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const body = await req.json();
    const ticketId = body.ticketId;

    if (!ticketId) {
      return new Response("Missing ticketId", { status: 400 });
    }

    const doc = await db.collection("support_tickets").doc(ticketId).get();
    if (!doc.exists) {
      return new Response("Ticket not found", { status: 404 });
    }

    const ticket = doc.data()!;

    await db.collection("notification_queue").add({
      recipient: ADMIN_PHONE,
      recipientId: "admin_main",
      type: "Support Ticket Created",
      title: "WhatsApp Alert",
      body: "New Support Ticket",
      channel: "whatsapp",
      status: "pending",
      retryCount: 0,
      metadata: {
        templateName: "admin_alerts",
        parameters: ["Support Ticket", ticket.customerId || "Customer"]
      },
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

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
