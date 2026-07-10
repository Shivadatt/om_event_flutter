import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const ADMIN_EMAIL = "admin@omevents.com";

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const body = await req.json();
    const reviewId = body.reviewId;

    if (!reviewId) {
      return new Response("Missing reviewId", { status: 400 });
    }

    const doc = await db.collection("reviews").doc(reviewId).get();
    if (!doc.exists) {
      return new Response("Review not found", { status: 404 });
    }

    const review = doc.data()!;

    await db.collection("notification_queue").add({
      recipient: ADMIN_EMAIL,
      recipientId: "admin_main",
      type: "Review Created",
      title: "New Customer Review",
      body: `Rating: ${review.rating || 5} stars | Comment: ${review.comment || ''}`,
      channel: "email",
      status: "pending",
      retryCount: 0,
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
