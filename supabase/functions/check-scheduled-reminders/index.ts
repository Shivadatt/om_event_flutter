import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db, FieldValue } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { markJobStart, markJobComplete, markJobFailed, markJobSkipped } from "../_shared/cron_monitor.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const JOB_NAME = "check-scheduled-reminders";

// ─────────────────────────────────────────────────────────────────────────────
// check-scheduled-reminders
// Replaces Firebase checkScheduledReminders (pubsub.schedule every 30 minutes).
// Reads `scheduled_notifications` where status==pending & triggerAt <= now,
// batches them into the `notification_queue` outbox, and marks them sent.
// ─────────────────────────────────────────────────────────────────────────────
serve(async (req) => {
  const tStart = Date.now();
  const logId = await markJobStart(JOB_NAME);
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const now = new Date();

    const snap = await db.collection("scheduled_notifications")
      .where("status", "==", "pending")
      .where("triggerAt", "<=", now.toISOString())
      .limit(100)
      .get();

    if (snap.empty) {
      await markJobSkipped(logId, JOB_NAME, "No pending scheduled notifications");
      return new Response(JSON.stringify({ status: "success", message: "Nothing to process" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const batch = db.batch();
    let queuedCount = 0;

    for (const doc of snap.docs) {
      const reminder = doc.data();

      // Write to outbox queue
      const queueRef = db.collection("notification_queue").doc();
      batch.set(queueRef, {
        recipient: reminder.recipient ?? "",
        recipientId: reminder.recipientId ?? "",
        type: reminder.eventType ?? "Scheduled Reminder",
        title: reminder.title ?? "",
        body: reminder.body ?? "",
        channel: reminder.channel ?? "push",
        status: "pending",
        priority: reminder.priority ?? "normal",
        retryCount: 0,
        errorMessage: "",
        variables: reminder.variables ?? {},
        idempotencyKey: `scheduled_${doc.id}`,
        expiresAt: reminder.expiresAt ?? null,
        metadata: { scheduledId: doc.id },
        createdAt: now.toISOString(),
        updatedAt: now.toISOString(),
      });

      // Mark reminder as dispatched
      batch.update(doc.ref, {
        status: "sent",
        processedAt: now.toISOString(),
        updatedAt: now.toISOString(),
      });

      queuedCount++;
    }

    await batch.commit();

    await markJobComplete(logId, JOB_NAME, tStart, {
      processedItems: queuedCount,
      message: `Queued ${queuedCount} scheduled reminders`,
    });

    return new Response(JSON.stringify({ status: "success", queuedCount }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    await markJobFailed(logId, JOB_NAME, tStart, e.message);
    return new Response(JSON.stringify({ status: "error", error: e.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
