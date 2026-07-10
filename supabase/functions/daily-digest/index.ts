import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    // Get all users who enabled daily digests
    const prefSnap = await db.collection("customer_notification_preferences")
      .where("dailyDigestEnabled", "==", true)
      .get();

    if (prefSnap.empty) {
      return new Response(JSON.stringify({ status: "success", message: "No digests to send" }), {
        headers: { "Content-Type": "application/json" }
      });
    }

    let processedCount = 0;

    for (const prefDoc of prefSnap.docs) {
      const uid = prefDoc.id;
      
      // Fetch user email
      const userDoc = await db.collection("users").doc(uid).get();
      if (!userDoc.exists) continue;
      const email = userDoc.data()!.email;

      // Fetch pending notifications created in last 24h
      const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
      const alertsSnap = await db.collection("customer_notifications")
        .where("customerId", "==", uid)
        .where("createdAt", ">=", yesterday)
        .get();

      if (alertsSnap.empty) continue;

      const summaryList = alertsSnap.docs.map(doc => `<li><b>${doc.data().title}</b>: ${doc.data().body}</li>`).join("");
      const digestHtml = `<h3>Your Daily Om Events Briefing</h3><ul>${summaryList}</ul>`;

      // Queue the Digest Email
      await db.collection("notification_queue").add({
        recipient: email,
        recipientId: uid,
        type: "Daily Digest Briefing",
        title: "Om Events Daily Summary Briefing",
        body: digestHtml,
        channel: "email",
        status: "pending",
        retryCount: 0,
        errorMessage: "",
        metadata: { priority: "high" },
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

      processedCount++;
    }

    return new Response(JSON.stringify({ status: "success", processedCount }), {
      headers: { "Content-Type": "application/json" }
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});
