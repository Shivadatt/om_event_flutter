const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Helper to extract and verify the Firebase ID Token from Authorization header.
 * Strictly verifies admin/staff role using Firestore data, never trusting client flags.
 */
async function authenticateAdminCaller(req) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    console.warn("[CREATE_CUSTOMER_LOGIN][ADMIN_VERIFY] Missing or invalid Authorization header");
    const err = new Error("Missing or invalid Authorization header");
    err.status = 401;
    throw err;
  }
  const idToken = authHeader.split("Bearer ")[1].trim();
  const decodedToken = await admin.auth().verifyIdToken(idToken);
  console.log(`[CREATE_CUSTOMER_LOGIN][ADMIN_VERIFY] Token verified for UID: ${decodedToken.uid}`);

  let isAuthorized = false;

  // Check admin collection
  const adminDoc = await db.collection("admin").doc(decodedToken.uid).get();
  if (adminDoc.exists) {
    const data = adminDoc.data();
    const role = String(data?.roleType || data?.role || "").toLowerCase();
    if (["admin", "super_admin", "staff", "demo_admin"].includes(role)) {
      isAuthorized = true;
    }
  }

  // Check users collection fallback
  if (!isAuthorized) {
    const userDoc = await db.collection("users").doc(decodedToken.uid).get();
    if (userDoc.exists) {
      const data = userDoc.data();
      const role = String(data?.role || "").toLowerCase();
      if (["admin", "super_admin", "staff", "demo_admin"].includes(role)) {
        isAuthorized = true;
      }
    }
  }

  // Fallback bootstrap admin emails
  const callerEmail = String(decodedToken.email || "").toLowerCase().trim();
  if (
    ["admin@omevents.in", "demo@omevents.in", "omeventsanddecorators@gmail.com"].includes(callerEmail)
  ) {
    isAuthorized = true;
  }

  if (!isAuthorized) {
    console.warn(`[CREATE_CUSTOMER_LOGIN][ADMIN_VERIFY] Forbidden: UID ${decodedToken.uid} lacks admin privileges`);
    const err = new Error("Forbidden: Admin or Staff privileges required");
    err.status = 403;
    throw err;
  }

  return decodedToken;
}

/**
 * Normalizes phone number to canonical 10-digit format.
 */
function normalizePhone(rawPhone) {
  const digits = String(rawPhone || "").replace(/\D/g, "");
  return digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
}

/**
 * Core handler: createCustomerLogin
 * Provisions Firebase Authentication for a customer without passwords,
 * links to canonical customers/{phone}, and generates secure password setup link.
 */
async function handleCreateCustomerLogin(req, res) {
  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }
  if (req.method !== "POST") {
    return res.status(405).json({ status: "error", error: "Method not allowed" });
  }

  console.log("[CREATE_CUSTOMER_LOGIN][REQUEST] Incoming customer login provisioning request");

  // 1. Authenticate & verify admin caller
  let caller;
  try {
    caller = await authenticateAdminCaller(req);
  } catch (err) {
    const status = err.status || 401;
    return res.status(status).json({ status: "error", error: err.message });
  }

  // 2. Parse & validate input
  const body = req.body || {};
  const rawPhone = body.customerPhone || body.phone || "";
  const rawEmail = String(body.customerEmail || body.email || "").trim().toLowerCase();
  const fullName = String(body.customerName || body.fullName || body.name || "Valued Client").trim();
  const normalizedPhone = normalizePhone(rawPhone);

  if (normalizedPhone.length !== 10) {
    return res.status(400).json({ status: "error", error: "Please enter a valid 10-digit phone number." });
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!rawEmail || !emailRegex.test(rawEmail)) {
    return res.status(400).json({ status: "error", error: "A valid email address is required for client login." });
  }

  console.log(`[CREATE_CUSTOMER_LOGIN][CUSTOMER_LOOKUP] Checking canonical record customers/${normalizedPhone}`);

  // 3. Find canonical customer record: customers/{normalizedPhone}
  const customerDocRef = db.collection("customers").doc(normalizedPhone);
  const customerDocSnap = await customerDocRef.get();

  if (!customerDocSnap.exists) {
    console.warn(`[CREATE_CUSTOMER_LOGIN][CUSTOMER_LOOKUP] Customer not found: ${normalizedPhone}`);
    return res.status(404).json({
      status: "error",
      error: "Customer record not found. Please create the customer in directory first.",
    });
  }

  const customerData = customerDocSnap.data() || {};

  // Check if auth_uid already exists and login is active
  if (customerData.auth_uid && customerData.login_enabled === true) {
    console.log(`[CREATE_CUSTOMER_LOGIN][CUSTOMER_LOOKUP] Login already enabled for customers/${normalizedPhone} (UID: ${customerData.auth_uid})`);
    let existingSetupLink = "";
    try {
      existingSetupLink = await admin.auth().generatePasswordResetLink(rawEmail);
    } catch (_) {}

    return res.status(200).json({
      status: "already_enabled",
      auth_uid: customerData.auth_uid,
      login_enabled: true,
      setup_link: existingSetupLink,
      message: "Client login is already enabled for this customer.",
    });
  }

  // 4. Duplicate email check in customers collection
  console.log(`[CREATE_CUSTOMER_LOGIN][EMAIL_CHECK] Checking for email collisions: ${rawEmail}`);
  const emailSnap = await db.collection("customers").where("email", "==", rawEmail).limit(5).get();
  for (const doc of emailSnap.docs) {
    if (doc.id !== normalizedPhone) {
      console.warn(`[CREATE_CUSTOMER_LOGIN][EMAIL_CHECK] Collision: Email linked to doc ${doc.id}`);
      return res.status(409).json({
        status: "error",
        error: "This email is already linked to another customer record.",
      });
    }
  }

  // 5. Firebase Authentication user lookup or creation
  console.log(`[CREATE_CUSTOMER_LOGIN][AUTH_CREATE] Resolving Firebase Auth user for: ${rawEmail}`);
  let authUid = "";
  let isNewlyCreated = false;

  try {
    let existingUser = null;
    try {
      existingUser = await admin.auth().getUserByEmail(rawEmail);
    } catch (e) {
      if (e.code !== "auth/user-not-found") throw e;
    }

    if (existingUser) {
      // If customer already had a different auth_uid, reject conflict
      if (customerData.auth_uid && customerData.auth_uid !== existingUser.uid) {
        console.warn(`[CREATE_CUSTOMER_LOGIN][AUTH_CREATE] Conflict: Email belongs to Auth UID ${existingUser.uid} but customer has ${customerData.auth_uid}`);
        return res.status(409).json({
          status: "error",
          error: "This email belongs to another Firebase Auth user not linked to this client.",
        });
      }
      authUid = existingUser.uid;
      console.log(`[CREATE_CUSTOMER_LOGIN][AUTH_CREATE] Linked existing Firebase Auth user: ${authUid}`);
    } else {
      // Create user without password - customer will set password via action link
      const newUser = await admin.auth().createUser({
        email: rawEmail,
        displayName: fullName,
        emailVerified: false,
      });
      authUid = newUser.uid;
      isNewlyCreated = true;
      console.log(`[CREATE_CUSTOMER_LOGIN][AUTH_CREATE] Created new Firebase Auth user with UID: ${authUid}`);
    }

    // 6. Update canonical Firestore document: customers/{normalizedPhone}
    console.log(`[CREATE_CUSTOMER_LOGIN][FIRESTORE_LINK] Updating canonical customers/${normalizedPhone} with auth_uid=${authUid}`);
    const nowIso = new Date().toISOString();
    const batch = db.batch();

    batch.set(
      customerDocRef,
      {
        auth_uid: authUid,
        login_enabled: true,
        login_method: "email_password",
        login_created_at: nowIso,
        login_enabled_at: nowIso,
        updated_at: nowIso,
      },
      { merge: true }
    );

    // Sync auxiliary customer_profiles/{authUid}
    const profileRef = db.collection("customer_profiles").doc(authUid);
    batch.set(
      profileRef,
      {
        id: authUid,
        customer_phone_key: normalizedPhone,
        full_name: fullName,
        name: fullName,
        phone: normalizedPhone,
        email: rawEmail,
        updated_at: nowIso,
      },
      { merge: true }
    );

    await batch.commit();
    console.log(`[CREATE_CUSTOMER_LOGIN][FIRESTORE_LINK] Canonical document updated successfully`);

    // 7. Generate Password Setup Link
    let setupLink = "";
    try {
      setupLink = await admin.auth().generatePasswordResetLink(rawEmail);
      console.log("[CREATE_CUSTOMER_LOGIN][SUCCESS] Password setup link generated");
    } catch (linkErr) {
      console.warn("[CREATE_CUSTOMER_LOGIN][SUCCESS] Could not generate reset link directly:", linkErr.message);
    }

    console.log(`[CREATE_CUSTOMER_LOGIN][SUCCESS] Customer login successfully provisioned: phone=${normalizedPhone}, auth_uid=${authUid}`);
    return res.status(200).json({
      status: "success",
      auth_uid: authUid,
      login_enabled: true,
      setup_link: setupLink,
      message: "Customer login provisioned successfully.",
    });
  } catch (error) {
    console.error("[CREATE_CUSTOMER_LOGIN][ERROR] Failure during customer provisioning:", error);
    // Compensation rollback: delete newly created user if Firestore commit failed
    if (isNewlyCreated && authUid) {
      try {
        console.warn(`[CREATE_CUSTOMER_LOGIN][ERROR] Rolling back orphaned Auth user: ${authUid}`);
        await admin.auth().deleteUser(authUid);
      } catch (delErr) {
        console.error(`[CREATE_CUSTOMER_LOGIN][ERROR] Failed rollback for ${authUid}:`, delErr);
      }
    }
    const errorMsg = error instanceof Error ? error.message : String(error);
    return res.status(500).json({
      status: "error",
      error: `Failed to provision customer login: ${errorMsg}`,
    });
  }
}

/**
 * Core handler: sendCustomerPasswordSetupLink
 * Verifies admin privileges, validates customer record, and generates/sends password reset link.
 */
async function handleSendPasswordSetupLink(req, res) {
  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }
  if (req.method !== "POST") {
    return res.status(405).json({ status: "error", error: "Method not allowed" });
  }

  console.log("[SEND_PASSWORD_LINK][REQUEST] Request to generate password setup link");

  // 1. Authenticate caller
  try {
    await authenticateAdminCaller(req);
  } catch (err) {
    const status = err.status || 401;
    return res.status(status).json({ status: "error", error: err.message });
  }

  // 2. Validate input
  const body = req.body || {};
  const rawPhone = body.customerPhone || body.phone || "";
  const normalizedPhone = normalizePhone(rawPhone);

  if (normalizedPhone.length !== 10) {
    return res.status(400).json({ status: "error", error: "Please enter a valid 10-digit phone number." });
  }

  // 3. Find customer
  const customerDocSnap = await db.collection("customers").doc(normalizedPhone).get();
  if (!customerDocSnap.exists) {
    return res.status(404).json({ status: "error", error: "Customer profile was not found." });
  }

  const customerData = customerDocSnap.data() || {};
  const email = String(customerData.email || body.email || "").trim().toLowerCase();

  if (!email) {
    return res.status(400).json({ status: "error", error: "Customer does not have an email address configured." });
  }

  if (!customerData.auth_uid) {
    return res.status(400).json({ status: "error", error: "Customer login has not been provisioned yet." });
  }

  if (customerData.login_enabled !== true) {
    return res.status(400).json({ status: "error", error: "Client login is currently disabled for this account." });
  }

  try {
    const setupLink = await admin.auth().generatePasswordResetLink(email);
    console.log(`[SEND_PASSWORD_LINK][SUCCESS] Password reset link generated for ${email}`);

    return res.status(200).json({
      status: "success",
      email: email,
      setup_link: setupLink,
      message: `Password setup link generated for ${email}.`,
    });
  } catch (err) {
    console.error(`[SEND_PASSWORD_LINK][ERROR] Could not generate link for ${email}:`, err);
    return res.status(500).json({
      status: "error",
      error: `Password setup email could not be sent: ${err.message}`,
    });
  }
}

/**
 * HTTPS Endpoints (Region: asia-south1)
 */
exports.createCustomerLogin = functions
  .region("asia-south1")
  .https.onRequest((req, res) => {
    return cors(req, res, () => handleCreateCustomerLogin(req, res));
  });

exports.adminCreateCustomerLogin = functions
  .region("asia-south1")
  .https.onRequest((req, res) => {
    return cors(req, res, () => handleCreateCustomerLogin(req, res));
  });

exports.sendCustomerPasswordSetupLink = functions
  .region("asia-south1")
  .https.onRequest((req, res) => {
    return cors(req, res, () => handleSendPasswordSetupLink(req, res));
  });
