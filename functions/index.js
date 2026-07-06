const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Supabase Connection Configuration (Service Role key to bypass RLS)
const SUPABASE_URL = process.env.SUPABASE_URL || "https://kwegyvbgdaednljyhcgm.supabase.co";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

const ADMIN_EMAIL = "admin@omevents.com";
const ADMIN_PHONE = "9512149944";

// =========================================================================
// DATABASE SYNCHRONIZATION LAYER (Firestore -> Supabase)
// =========================================================================

/**
 * Syncs Firestore document mutation to Supabase mirror tables.
 * Employs PostgREST API with Service Role Key bypass.
 */
async function syncToSupabase(table, id, data = null) {
  try {
    const url = `${SUPABASE_URL}/rest/v1/${table}`;
    const headers = {
      "apikey": SUPABASE_SERVICE_ROLE_KEY,
      "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json"
    };

    if (data === null) {
      // DELETE operation
      await axios.delete(`${url}?id=eq.${id}`, { headers });
      console.log(`SUCCESS [SYNC]: Deleted record ${id} from Supabase table ${table}`);
    } else {
      // UPSERT operation (Idempotent write)
      const payload = { id, ...data };
      await axios.post(url, payload, {
        headers: {
          ...headers,
          "Prefer": "resolution=merge-duplicates"
        }
      });
      console.log(`SUCCESS [SYNC]: Upserted record ${id} to Supabase table ${table}`);
    }
  } catch (err) {
    console.error(`ERROR [SYNC]: Failed to sync ${id} to Supabase table ${table}:`, err.response ? err.response.data : err.message);
  }
}

// 1. Sync Bookings
exports.onBookingSync = functions.firestore
  .document("bookings/{bookingId}")
  .onWrite(async (change, context) => {
    const id = context.params.bookingId;
    if (!change.after.exists) {
      await syncToSupabase("bookings", id, null);
      return;
    }
    const data = change.after.data();
    const payload = {
      customer_id: data.customerId || "",
      booking_number: data.booking_number || "",
      status: data.status || "pending",
      event_date: data.event_date || data.eventDate || "",
      customer_email: data.customer_email || data.customerEmail || "",
      customer_phone: data.customer_phone || data.customerPhone || "",
      amount: Number(data.amount || 0),
      updated_at: new Date().toISOString()
    };
    await syncToSupabase("bookings", id, payload);
  });

// 2. Sync Leads
exports.onLeadSync = functions.firestore
  .document("leads/{leadId}")
  .onWrite(async (change, context) => {
    const id = context.params.leadId;
    if (!change.after.exists) {
      await syncToSupabase("leads", id, null);
      return;
    }
    const data = change.after.data();
    const payload = {
      status: data.status || "pending",
      customer_name: data.name || data.customer_name || "",
      customer_phone: data.phone || data.customer_phone || "",
      customer_email: data.email || data.customer_email || "",
      updated_at: new Date().toISOString()
    };
    await syncToSupabase("leads", id, payload);
  });

// 3. Sync Quotations
exports.onQuotationSync = functions.firestore
  .document("quotations/{quoteId}")
  .onWrite(async (change, context) => {
    const id = context.params.quoteId;
    if (!change.after.exists) {
      await syncToSupabase("quotations", id, null);
      return;
    }
    const data = change.after.data();
    const payload = {
      status: data.status || "pending",
      customer_id: data.customerId || "",
      customer_name: data.customer_name || data.customerName || "",
      public_id: data.public_id || data.publicId || "",
      customer_email: data.customer_email || data.customerEmail || "",
      customer_phone: data.customer_phone || data.customerPhone || "",
      updated_at: new Date().toISOString()
    };
    await syncToSupabase("quotations", id, payload);
  });

// 4. Sync Reviews
exports.onReviewSync = functions.firestore
  .document("reviews/{reviewId}")
  .onWrite(async (change, context) => {
    const id = context.params.reviewId;
    if (!change.after.exists) {
      await syncToSupabase("reviews", id, null);
      return;
    }
    const data = change.after.data();
    const payload = {
      rating: Number(data.rating || 5),
      comment: data.comment || "",
      customer_id: data.customerId || "",
      experience_id: data.experienceId || ""
    };
    await syncToSupabase("reviews", id, payload);
  });

// 5. Sync Settings
exports.onSettingsSync = functions.firestore
  .document("settings/{settingId}")
  .onWrite(async (change, context) => {
    const id = context.params.settingId;
    if (!change.after.exists) {
      await syncToSupabase("settings", id, null);
      return;
    }
    const data = change.after.data();
    const payload = {
      key: data.key || id,
      value: data.value !== undefined ? String(data.value) : "",
      updated_at: new Date().toISOString()
    };
    await syncToSupabase("settings", id, payload);
  });

// 6. Sync Users / Customers
exports.onUserSync = functions.firestore
  .document("users/{userId}")
  .onWrite(async (change, context) => {
    const id = context.params.userId;
    if (!change.after.exists) {
      await syncToSupabase("users", id, null);
      return;
    }
    const data = change.after.data();

    // Users table has a UUID primary key, so we upsert based on firebase_uid unique constraint
    try {
      const url = `${SUPABASE_URL}/rest/v1/users?on_conflict=firebase_uid`;
      const payload = {
        firebase_uid: data.firebase_uid || data.firebaseUid || id,
        email: data.email || "",
        name: data.name || "",
        role: data.role || "customer",
        branch: data.branch || "Ahmedabad",
        is_active: data.is_active !== undefined ? data.is_active : true,
        updated_at: new Date().toISOString()
      };

      const headers = {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates"
      };

      await axios.post(url, payload, { headers });
      console.log(`SUCCESS [SYNC]: Upserted user ${id} based on firebase_uid`);
    } catch (err) {
      console.error(`ERROR [SYNC]: Failed to sync user ${id} to Supabase:`, err.response ? err.response.data : err.message);
    }
  });

// =========================================================================
// QUEUE HELPER: Push Directly to Supabase Outbox Queue Table
// =========================================================================
async function queueTask(recipient, recipientId, type, title, body, channel, metadata = {}) {
  try {
    const url = `${SUPABASE_URL}/rest/v1/notification_queue`;
    const payload = {
      recipient,
      recipient_id: recipientId,
      notification_type: type,
      title,
      body,
      channel,
      status: "pending",
      priority: metadata.priority || "normal",
      variables: metadata.variables || {},
      metadata: metadata
    };

    const headers = {
      "apikey": SUPABASE_SERVICE_ROLE_KEY,
      "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json"
    };

    await axios.post(url, payload, { headers });
    console.log(`SUCCESS [QUEUE]: Queued notification to Supabase for ${recipient}`);
  } catch (err) {
    console.error(`ERROR [QUEUE]: Failed to queue notification to Supabase:`, err.response ? err.response.data : err.message);
  }
}

// =========================================================================
// CLOUD SCHEDULER: CRON REMINDER PROCESSOR
// =========================================================================
exports.checkScheduledReminders = functions.pubsub
  .schedule("every 30 minutes")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    // Fetch pending scheduled reminders that are due
    const snap = await db.collection("scheduled_notifications")
      .where("status", "==", "pending")
      .where("triggerAt", "<=", now)
      .limit(100)
      .get();

    if (snap.empty) return null;

    const batch = db.batch();

    for (const doc of snap.docs) {
      const reminder = doc.data();
      const ref = doc.ref;

      // Add task directly to Supabase Queue
      await queueTask(
        reminder.recipient,
        reminder.recipientId,
        reminder.eventType || "Scheduled Reminder",
        reminder.title,
        reminder.body,
        reminder.channel,
        {
          priority: reminder.priority || "normal",
          variables: reminder.variables || {},
          metadata: { scheduledId: doc.id }
        }
      );

      // Update reminder state locally in Firestore
      batch.update(ref, {
        status: "sent",
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    await batch.commit();
  });

// =========================================================================
// CRM EVENT TRIGGERS (Offloaded to Supabase Outbox Queue)
// =========================================================================

exports.onBookingCreated = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap) => {
    const booking = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Booking Created", "New Booking Request", `Submitted by ${booking.customer_name || 'Customer'}`, "email");
  });

exports.onBookingUpdated = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change) => {
    const oldVal = change.before.data();
    const newVal = change.after.data();
    if (oldVal.status === newVal.status) return;

    const customerId = newVal.customerId || "";
    const email = newVal.customer_email || "customer@gmail.com";
    const phone = newVal.customer_phone || "";

    if (newVal.status === "confirmed" || newVal.status === "approved") {
      await queueTask(email, customerId, "Booking Approved", "Booking Accepted!", "Your event has been approved by Om Events.", "email");
    } else if (newVal.status === "cancelled" || newVal.status === "rejected") {
      await queueTask(email, customerId, "Booking Rejected", "Booking Update", "Your booking request was cancelled.", "email");
    }
  });

exports.onLeadCreated = functions.firestore
  .document("leads/{leadId}")
  .onCreate(async (snap) => {
    const lead = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Lead Created", "New CRM Lead Inquiry", `Name: ${lead.name} | Phone: ${lead.phone}`, "email");
  });

exports.onQuotationCreated = functions.firestore
  .document("quotations/{quoteId}")
  .onCreate(async (snap) => {
    const quote = snap.data();
    const phone = quote.customer_phone || "";
    if (phone) {
      await queueTask(phone, quote.customerId || "customer", "Quotation Ready", "WhatsApp Alert", "Quotation ready", "whatsapp", {
        templateName: "quotation_ready",
        parameters: [quote.public_id || ""]
      });
    }
  });

exports.onQuotationUpdated = functions.firestore
  .document("quotations/{quoteId}")
  .onUpdate(async (change) => {
    const oldVal = change.before.data();
    const newVal = change.after.data();
    if (oldVal.status === newVal.status) return;

    const phone = newVal.customer_phone || "";
    const publicId = newVal.public_id || change.after.id;
    const customerName = newVal.customer_name || "Customer";

    if (newVal.status === "approved" || newVal.status === "accepted" || newVal.status === "booked") {
      await queueTask(ADMIN_EMAIL, "admin_main", "Quotation Approved", `Quotation Approved: ${publicId}`, `Quotation ${publicId} has been approved/booked by customer ${customerName}.`, "email");
    }
  });

exports.onPaymentCreated = functions.firestore
  .document("payments/{paymentId}")
  .onCreate(async (snap) => {
    const p = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Payment Created", "Verify Payment Receipt", `Amount: ₹${p.amount}`, "email");
  });

exports.onReviewCreated = functions.firestore
  .document("reviews/{reviewId}")
  .onCreate(async (snap) => {
    const r = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Review Created", "New Customer Review", `Rating: ${r.rating} stars | Comment: ${r.comment}`, "email");
  });
