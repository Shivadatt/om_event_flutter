import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { markJobStart, markJobComplete, markJobFailed, markJobSkipped } from "../_shared/cron_monitor.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const JOB_NAME = "send-booking-reminders";

// Workaround: Deno type for list used in bookingReminderDays
type List = unknown[];

serve(async (req) => {
  const tStart = Date.now();
  const logId = await markJobStart(JOB_NAME);
  try {
    const authHeader = req.headers.get("Authorization");
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);

    const settingsSnap = await db.collection("automation_settings").doc("global_config").get();
    let isEnabled = true;
    let bookingReminderDays: number[] = [7, 3, 1, 0];

    if (settingsSnap.exists) {
      isEnabled = settingsSnap.data()!.isEnabled ?? true;
      const list = settingsSnap.data()!.bookingReminderDays as List | undefined;
      if (list) {
        bookingReminderDays = list.map((e) => Number(e));
      }
    }

    if (!isEnabled) {
      await markJobSkipped(logId, JOB_NAME, "Automation disabled in settings");
      return new Response(JSON.stringify({ status: "skipped" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const now = new Date();
    const quotesSnap = await db.collection("quotations").where("status", "==", "bookingConfirmed").get();
    let sentCount = 0;

    for (const doc of quotesSnap.docs) {
      const quote = doc.data();
      const eventDateStr = quote.eventDate ?? quote.event_date;
      if (!eventDateStr) continue;

      const eventDate = new Date(eventDateStr);
      const cleanEventDate = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate());
      const cleanNow = new Date(now.getFullYear(), now.getMonth(), now.getDate());

      for (const daysBefore of bookingReminderDays) {
        const reminderTime = new Date(cleanEventDate.getTime() - daysBefore * 24 * 60 * 60 * 1000);

        if (cleanNow >= reminderTime) {
          const remId = `${doc.id}_booking_${daysBefore}d`;
          const remSnap = await db.collection("quotation_reminders").doc(remId).get();

          if (!remSnap.exists) {
            await db.collection("quotation_reminders").doc(remId).set({
              quotationId: doc.id,
              type: `booking_${daysBefore}d`,
              scheduledAt: reminderTime.toISOString(),
              executedAt: now.toISOString(),
              status: "sent",
              retryCount: 0,
            });

            await db.collection("quotation_automation_logs").add({
              quotationId: doc.id,
              automationType: "Booking Reminder",
              executedAt: now.toISOString(),
              status: "Success",
              details: `Client reminder sent ${daysBefore} days before booked event.`,
              duration: Date.now() - tStart,
              executedBy: "Supabase Cron",
            });

            const dayText = daysBefore === 0 ? "today" : `in ${daysBefore} days`;
            await db.collection("notification_queue").add({
              recipient: "Client",
              recipientId: quote.customerId ?? "",
              quotationId: doc.id,
              type: "BookingReminder",
              title: "Upcoming Event Reminder",
              body: `Reminder: Your booked event for proposal ${quote.publicId ?? doc.id} is scheduled ${dayText}!`,
              status: "pending",
              retryCount: 0,
              idempotencyKey: `booking_reminder_${remId}`,
              scheduledAt: now.toISOString(),
              createdAt: now.toISOString(),
              priority: "normal",
            });
            sentCount++;
          }
        }
      }
    }

    await markJobComplete(logId, JOB_NAME, tStart, {
      processedItems: sentCount,
      message: `Sent ${sentCount} booking reminders`,
    });

    return new Response(JSON.stringify({ status: "success", sentCount }), {
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
