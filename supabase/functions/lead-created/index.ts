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
    const leadId = body.leadId;

    if (!leadId) {
      return new Response("Missing leadId", { status: 400 });
    }

    const doc = await db.collection("leads").doc(leadId).get();
    if (!doc.exists) {
      return new Response("Lead not found", { status: 404 });
    }

    const lead = doc.data()!;

    await db.collection("notification_queue").add({
      recipient: ADMIN_EMAIL,
      recipientId: "admin_main",
      type: "Lead Created",
      title: "New CRM Lead Inquiry",
      body: `Name: ${lead.name} | Phone: ${lead.phone}`,
      channel: "email",
      status: "pending",
      retryCount: 0,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });

    await db.collection("notification_queue").add({
      recipient: ADMIN_PHONE,
      recipientId: "admin_main",
      type: "Lead Created",
      title: "WhatsApp Alert",
      body: "Lead created",
      channel: "whatsapp",
      status: "pending",
      retryCount: 0,
      metadata: {
        templateName: "admin_alerts",
        parameters: ["Lead Created", lead.name || "Customer"]
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
