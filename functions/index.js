const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { Resend } = require("resend");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Secrets Manager configs
const RESEND_API_KEY = process.env.RESEND_API_KEY || "re_mock_key";
const WHATSAPP_TOKEN = process.env.WHATSAPP_TOKEN || "EAABw...";
const WHATSAPP_PHONE_ID = process.env.WHATSAPP_PHONE_ID || "1029384756";
const SENDER_EMAIL = process.env.SENDER_EMAIL || "notifications@omevents.com";
const WHATSAPP_WEBHOOK_SECRET = process.env.WHATSAPP_WEBHOOK_SECRET || "my_secure_verify_token";

const ADMIN_EMAIL = "admin@omevents.com";
const ADMIN_PHONE = "9512149944";

// =========================================================================
// 1. CLOUD SCHEDULER: CRON REMINDER PROCESSOR
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

      // Add task to outbox queue
      const queueRef = db.collection("notification_queue").doc();
      batch.set(queueRef, {
        recipient: reminder.recipient,
        recipientId: reminder.recipientId,
        type: reminder.eventType || "Scheduled Reminder",
        title: reminder.title,
        body: reminder.body,
        channel: reminder.channel,
        status: "pending",
        priority: reminder.priority || "normal",
        retryCount: 0,
        errorMessage: "",
        variables: reminder.variables || {},
        expiresAt: reminder.expiresAt || null,
        metadata: { scheduledId: doc.id },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // Update reminder state
      batch.update(ref, {
        status: "sent",
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    await batch.commit();
  });

// =========================================================================
// 2. ASYNC QUEUE PROCESSOR WITH DND, A/B SPLITS, & VARIABLE PARSING
// =========================================================================
exports.processNotificationQueue = functions
  .runWith({
    secrets: ["RESEND_API_KEY", "WHATSAPP_TOKEN", "WHATSAPP_PHONE_ID", "SENDER_EMAIL"]
  })
  .firestore.document("notification_queue/{taskId}")
  .onCreate(async (snap, context) => {
    const task = snap.data();
    const taskId = snap.id;

    if (!task || task.status !== "pending") return;

    const recipientId = task.recipientId || "";
    const priority = task.priority || "normal";
    const expiresAt = task.expiresAt;

    // A. Check Expiry
    if (expiresAt) {
      const expiryDate = new Date(expiresAt);
      if (expiryDate < new Date()) {
        await snap.ref.update({
          status: "expired",
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return;
      }
    }

    // B. QUIET HOURS (DND) CHECKING
    if (priority !== "high") {
      const dndActive = await checkDndStatus(recipientId);
      if (dndActive) {
        await snap.ref.update({
          status: "paused_dnd",
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return; // Defer processing
      }
    }

    // Transition to processing
    await snap.ref.update({
      status: "processing",
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    const channel = task.channel || "push";
    const recipient = task.recipient || "";
    let title = task.title || "";
    let body = task.body || "";
    const metadata = task.metadata || {};
    const variables = task.variables || {};

    // C. DYNAMIC TEMPLATE VARIABLES REPLACEMENTS PARSER
    Object.keys(variables).forEach(key => {
      const placeholder = `{{${key}}}`;
      const value = variables[key];
      title = title.replace(new RegExp(placeholder, "g"), value);
      body = body.replace(new RegExp(placeholder, "g"), value);
    });

    // D. A/B TESTING SPLIT (50/50 split allocations)
    const isVariantB = Math.random() < 0.5;
    const abVariant = isVariantB ? "Variant B" : "Variant A";
    if (isVariantB) {
      body = `${body} [Variant B content: Reserve within 24h for free bonus!]`;
    }

    let success = false;
    let errorMessage = "";
    let externalMessageId = "";

    try {
      if (channel === "email") {
        const apiKey = process.env.RESEND_API_KEY || RESEND_API_KEY;
        const resendInstance = new Resend(apiKey);
        const fromEmail = process.env.SENDER_EMAIL || SENDER_EMAIL;

        const emailResponse = await resendInstance.emails.send({
          from: fromEmail,
          to: [recipient],
          subject: title,
          html: body
        });
        success = true;
        externalMessageId = emailResponse.data ? emailResponse.data.id : "";
      } else if (channel === "whatsapp") {
        const token = process.env.WHATSAPP_TOKEN || WHATSAPP_TOKEN;
        const phoneId = process.env.WHATSAPP_PHONE_ID || WHATSAPP_PHONE_ID;
        const url = `https://graph.facebook.com/v20.0/${phoneId}/messages`;
        
        const waResponse = await axios.post(
          url,
          {
            messaging_product: "whatsapp",
            to: recipient,
            type: "template",
            template: {
              name: metadata.templateName || "admin_alerts",
              language: { code: "en_US" },
              components: (metadata.parameters && metadata.parameters.length)
                ? [
                    {
                      type: "body",
                      parameters: metadata.parameters.map(p => ({ type: "text", text: p }))
                    }
                  ]
                : []
            }
          },
          {
            headers: { Authorization: `Bearer ${token}` }
          }
        );
        success = true;
        externalMessageId = waResponse.data && waResponse.data.messages ? waResponse.data.messages[0].id : "";
      } else if (channel === "push") {
        // E. MULTI-DEVICE FCM LOOP DELIVERY
        const tokensSnap = await db.collection("notification_tokens").where("userId", "==", recipientId).get();
        if (!tokensSnap.empty) {
          const promises = tokensSnap.docs.map(doc => {
            const deviceToken = doc.data().deviceToken;
            return admin.messaging().send({
              notification: { title, body },
              token: deviceToken,
              data: {
                logo: "https://omevents.com/logo.png",
                banner: "https://omevents.com/banner.png",
                click_action: "FLUTTER_NOTIFICATION_CLICK"
              }
            });
          });
          const results = await Promise.all(promises);
          externalMessageId = results[0] || "";
        }
        success = true;
      }
    } catch (err) {
      success = false;
      errorMessage = err.message || "Unknown error";
    }

    if (success) {
      await snap.ref.update({
        status: "sent",
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      await db.collection("notification_logs").doc(taskId).set({
        recipientId: recipient,
        type: task.type || "Alert",
        title: title,
        body: body,
        channelsUsed: [channel],
        status: "sent",
        externalId: externalMessageId,
        variant: abVariant,
        priority: priority,
        sentAt: admin.firestore.FieldValue.serverTimestamp()
      });
    } else {
      const retryCount = (task.retryCount || 0) + 1;
      
      if (retryCount >= 5) {
        await db.collection("dead_letter_notifications").add({
          reason: errorMessage,
          channel: channel,
          payload: task,
          retryCount: retryCount,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          stackTrace: "Serverless thread processing exception logs."
        });
        await snap.ref.delete();
      } else {
        await snap.ref.update({
          status: "retry",
          retryCount: retryCount,
          errorMessage: errorMessage,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }

      await db.collection("notification_logs").add({
        recipientId: recipient,
        type: task.type || "Alert",
        title: `Failed: ${title}`,
        body: `Attempt ${retryCount}/5 - Error: ${errorMessage}`,
        channelsUsed: [channel],
        status: "failed",
        sentAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  });

// DND Quiet Hours Checking Helper
async function checkDndStatus(userId) {
  if (!userId) return false;
  const prefDoc = await db.collection("customer_notification_preferences").doc(userId).get();
  if (!prefDoc.exists) return false;

  const data = prefDoc.data();
  if (!data.dndEnabled) return false;

  const quietHoursStart = data.quietHoursStart || "22:00";
  const quietHoursEnd = data.quietHoursEnd || "07:00";

  const now = new Date();
  const currentHour = now.getHours();
  const currentMin = now.getMinutes();

  const [startHour, startMin] = quietHoursStart.split(":").map(Number);
  const [endHour, endMin] = quietHoursEnd.split(":").map(Number);

  const startTotal = startHour * 60 + startMin;
  const endTotal = endHour * 60 + endMin;
  const currentTotal = currentHour * 60 + currentMin;

  if (endTotal < startTotal) {
    // Spans midnight
    return currentTotal >= startTotal || currentTotal <= endTotal;
  } else {
    return currentTotal >= startTotal && currentTotal <= endTotal;
  }
}

// =========================================================================
// 3. DAILY DIGEST SUMMARY SCHEDULER (Aggregates alerts)
// =========================================================================
exports.sendDailyDigestNotifications = functions.pubsub
  .schedule("0 9 * * *") // Daily morning at 9:00 AM
  .onRun(async (context) => {
    // Get all users who enabled daily digests
    const prefSnap = await db.collection("customer_notification_preferences")
      .where("dailyDigestEnabled", "==", true)
      .get();

    if (prefSnap.empty) return null;

    for (const prefDoc of prefSnap.docs) {
      const uid = prefDoc.id;
      
      // Fetch user email
      const userDoc = await db.collection("users").doc(uid).get();
      if (!userDoc.exists) continue;
      const email = userDoc.data().email;

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
      await queueTask(email, uid, "Daily Digest Briefing", "Om Events Daily Summary Briefing", digestHtml, "email", { priority: "high" });
    }
  });

// =========================================================================
// 4. DELIVERY STATUS CALLBACK WEBHOOKS
// =========================================================================

exports.whatsappWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method === "GET") {
    const mode = req.query["hub.mode"];
    const token = req.query["hub.verify_token"];
    const challenge = req.query["hub.challenge"];

    if (mode === "subscribe" && token === WHATSAPP_WEBHOOK_SECRET) {
      res.status(200).send(challenge);
    } else {
      res.sendStatus(403);
    }
    return;
  }

  if (req.method === "POST") {
    try {
      const body = req.body;
      await db.collection("notification_webhook_logs").add({
        gateway: "whatsapp",
        payload: body,
        receivedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      if (body.entry && body.entry[0].changes && body.entry[0].changes[0].value.statuses) {
        const statusObj = body.entry[0].changes[0].value.statuses[0];
        const msgId = statusObj.id;
        const status = statusObj.status;

        const logDoc = await db.collection("notification_delivery_events").doc(msgId).get();
        if (logDoc.exists && logDoc.data().status === status) {
          res.sendStatus(200);
          return;
        }

        await db.collection("notification_delivery_events").doc(msgId).set({
          logId: msgId,
          event: status,
          status: status,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          details: statusObj
        }, { merge: true });

        const logsQuery = await db.collection("notification_logs").where("externalId", "==", msgId).get();
        if (!logsQuery.empty) {
          const batch = db.batch();
          logsQuery.docs.forEach(doc => {
            batch.update(doc.ref, {
              status: status,
              updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });
          });
          await batch.commit();
        }
      }
      res.sendStatus(200);
    } catch (e) {
      res.status(500).send(e.message);
    }
  }
});

exports.resendWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method === "POST") {
    try {
      const body = req.body;
      await db.collection("notification_webhook_logs").add({
        gateway: "resend",
        payload: body,
        receivedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      const emailId = body.data ? body.data.id : "";
      const eventType = body.type;

      if (emailId) {
        let cleanStatus = "sent";
        if (eventType === "email.delivered") cleanStatus = "delivered";
        if (eventType === "email.opened") cleanStatus = "opened";
        if (eventType === "email.clicked") cleanStatus = "clicked";
        if (eventType === "email.bounced") cleanStatus = "failed";

        await db.collection("notification_delivery_events").doc(emailId).set({
          logId: emailId,
          event: eventType,
          status: cleanStatus,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          details: body
        }, { merge: true });

        const logsQuery = await db.collection("notification_logs").where("externalId", "==", emailId).get();
        if (!logsQuery.empty) {
          const batch = db.batch();
          logsQuery.docs.forEach(doc => {
            batch.update(doc.ref, {
              status: cleanStatus,
              updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });
          });
          await batch.commit();
        }
      }
      res.sendStatus(200);
    } catch (e) {
      res.status(500).send(e.message);
    }
  }
});

// Helper to write tasks directly to notification_queue outbox
async function queueTask(recipient, recipientId, type, title, body, channel, metadata = {}) {
  await db.collection("notification_queue").add({
    recipient,
    recipientId,
    type,
    title,
    body,
    channel,
    status: "pending",
    retryCount: 0,
    errorMessage: "",
    metadata,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
}

// =========================================================================
// CRM EVENT TRIGGERS (Offloaded to Outbox Queue)
// =========================================================================

exports.onBookingCreated = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap) => {
    const booking = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Booking Created", "New Booking Request", `Submitted by ${booking.customer_name || 'Customer'}`, "email");
    await queueTask(ADMIN_PHONE, "admin_main", "Booking Created", "WhatsApp Alert", `New Booking from ${booking.customer_name}`, "whatsapp", {
      templateName: "admin_alerts",
      parameters: ["Booking Created", booking.customer_name || "Customer"]
    });
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
      if (phone) {
        await queueTask(phone, customerId, "Booking Approved", "WhatsApp Alert", "Booking approved", "whatsapp", {
          templateName: "booking_approved",
          parameters: [newVal.booking_number || ""]
        });
      }
    } else if (newVal.status === "cancelled" || newVal.status === "rejected") {
      await queueTask(email, customerId, "Booking Rejected", "Booking Update", "Your booking request was cancelled.", "email");
      if (phone) {
        await queueTask(phone, customerId, "Booking Rejected", "WhatsApp Alert", "Booking update", "whatsapp", {
          templateName: "booking_rejected",
          parameters: [newVal.booking_number || ""]
        });
      }
    }
  });

exports.onLeadCreated = functions.firestore
  .document("leads/{leadId}")
  .onCreate(async (snap) => {
    const lead = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Lead Created", "New CRM Lead Inquiry", `Name: ${lead.name} | Phone: ${lead.phone}`, "email");
    await queueTask(ADMIN_PHONE, "admin_main", "Lead Created", "WhatsApp Alert", "Lead created", "whatsapp", {
      templateName: "admin_alerts",
      parameters: ["Lead Created", lead.name || "Customer"]
    });
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
      // 1. Send Email Alert to Admin
      await queueTask(ADMIN_EMAIL, "admin_main", "Quotation Approved", `Quotation Approved: ${publicId}`, `Quotation ${publicId} has been approved/booked by customer ${customerName}.`, "email");
      
      // 2. Send WhatsApp Alert to Admin
      await queueTask(ADMIN_PHONE, "admin_main", "Quotation Approved", "WhatsApp Alert", `Quotation ${publicId} booked`, "whatsapp", {
        templateName: "admin_alerts",
        parameters: ["Quotation Approved", customerName]
      });

      // 3. Send WhatsApp Alert to Customer
      if (phone) {
        await queueTask(phone, newVal.customerId || "customer", "Quotation Approved", "WhatsApp Alert", "Quotation approved", "whatsapp", {
          templateName: "quotation_approved",
          parameters: [publicId]
        });
      }
    } else if (newVal.status === "rejected") {
      if (phone) {
        await queueTask(phone, newVal.customerId || "customer", "Quotation Rejected", "WhatsApp Alert", "Quotation rejected", "whatsapp", {
          templateName: "quotation_rejected",
          parameters: [publicId]
        });
      }
    }
  });

exports.onPaymentCreated = functions.firestore
  .document("payments/{paymentId}")
  .onCreate(async (snap) => {
    const p = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Payment Created", "Verify Payment Receipt", `Amount: ₹${p.amount}`, "email");
    await queueTask(ADMIN_PHONE, "admin_main", "Payment Created", "WhatsApp Alert", "Verify payment", "whatsapp", {
      templateName: "payment_received",
      parameters: [p.bookingId || "", (p.amount || 0).toString()]
    });
  });

exports.onPaymentUpdated = functions.firestore
  .document("payments/{paymentId}")
  .onUpdate(async (change) => {
    const oldVal = change.before.data();
    const newVal = change.after.data();
    if (oldVal.status === newVal.status) return;

    if (newVal.status === "approved" || newVal.status === "verified") {
      await queueTask(newVal.customer_phone || "", newVal.customerId || "customer", "Payment Approved", "WhatsApp Alert", "Payment approved", "whatsapp", {
        templateName: "payment_approved",
        parameters: [(newVal.amount || 0).toString()]
      });
    }
  });

exports.onReviewCreated = functions.firestore
  .document("reviews/{reviewId}")
  .onCreate(async (snap) => {
    const r = snap.data();
    await queueTask(ADMIN_EMAIL, "admin_main", "Review Created", "New Customer Review", `Rating: ${r.rating} stars | Comment: ${r.comment}`, "email");
  });

exports.onSupportTicketCreated = functions.firestore
  .document("support_tickets/{ticketId}")
  .onCreate(async (snap) => {
    const ticket = snap.data();
    await queueTask(ADMIN_PHONE, "admin_main", "Support Ticket Created", "WhatsApp Alert", "New Support Ticket", "whatsapp", {
      templateName: "admin_alerts",
      parameters: ["Support Ticket", ticket.customerId || "Customer"]
    });
  });
