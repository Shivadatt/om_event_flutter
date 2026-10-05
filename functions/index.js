const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Helper to extract and verify the Firebase ID Token from Authorization header.
 */
async function authenticateAdminCaller(req) {
  console.log("[CREATE_CUSTOMER_AUTH][AUTH] Extracting and verifying Authorization header");
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new Error("Missing or invalid Authorization header");
  }
  const idToken = authHeader.split("Bearer ")[1].trim();
  const decodedToken = await admin.auth().verifyIdToken(idToken);
  console.log("[CREATE_CUSTOMER_AUTH][AUTH] Token verified successfully for UID:", decodedToken.uid);

  // Check admin authorization
  console.log("[CREATE_CUSTOMER_AUTH][ADMIN_CHECK] Checking admin authorization for UID:", decodedToken.uid);
  let isAuthorized = false;

  const adminDoc = await db.collection("admin").doc(decodedToken.uid).get();
  if (adminDoc.exists) {
    const data = adminDoc.data();
    const role = String(data?.roleType || data?.role || "").toLowerCase();
    console.log("[CREATE_CUSTOMER_AUTH][ADMIN_CHECK] Admin record found with role:", role);
    if (["admin", "super_admin", "staff", "demo_admin"].includes(role)) {
      isAuthorized = true;
    }
  }

  // Fallback bootstrap admin email
  const callerEmail = String(decodedToken.email || "").toLowerCase().trim();
  if (
    ["admin@omevents.in", "demo@omevents.in", "omeventsanddecorators@gmail.com"].includes(callerEmail)
  ) {
    console.log("[CREATE_CUSTOMER_AUTH][ADMIN_CHECK] Authorized via bootstrap admin email:", callerEmail);
    isAuthorized = true;
  }

  if (!isAuthorized) {
    console.warn("[CREATE_CUSTOMER_AUTH][ADMIN_CHECK] Caller is not authorized as admin:", decodedToken.uid);
    const err = new Error("Forbidden: Admin or Super Admin privileges required");
    err.status = 403;
    throw err;
  }

  return decodedToken;
}

/**
 * Core customer login creation handler.
 */
async function handleCustomerLoginCreation(req, res) {
  console.log("[CREATE_CUSTOMER_AUTH][START] Request received with method:", req.method);

  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }

  if (req.method !== "POST") {
    console.warn("[CREATE_CUSTOMER_AUTH][ERROR] Method not allowed:", req.method);
    return res.status(405).json({ status: "error", error: "Method not allowed" });
  }

  // 1. Authenticate caller
  let caller;
  try {
    caller = await authenticateAdminCaller(req);
  } catch (err) {
    const status = err.status || 401;
    console.error("[CREATE_CUSTOMER_AUTH][AUTH] Authentication/Authorization failed:", err.message);
    return res.status(status).json({ status: "error", error: err.message });
  }

  // 2. Parse & Validate input payload
  console.log("[CREATE_CUSTOMER_AUTH][VALIDATION] Parsing input payload");
  const body = req.body || {};
  const rawPhone = String(body.phone || "").trim();
  const rawEmail = String(body.email || "").trim().toLowerCase();
  const tempPassword = String(body.temporaryPassword || "");
  const fullName = String(body.fullName || "Valued Client").trim();
  const isExistingCustomer = Boolean(body.isExistingCustomer);

  // Normalize phone to exactly 10 digits
  const phoneDigits = rawPhone.replace(/\D/g, "");
  const normalizedPhone =
    phoneDigits.length >= 10 ? phoneDigits.substring(phoneDigits.length - 10) : phoneDigits;

  console.log(`[CREATE_CUSTOMER_AUTH][VALIDATION] Validating customer: phone=${normalizedPhone}, email=${rawEmail}, passwordProvided=${tempPassword.length >= 8}`);

  if (normalizedPhone.length !== 10) {
    return res.status(400).json({ status: "error", error: "Please enter a valid 10-digit phone number." });
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!rawEmail || !emailRegex.test(rawEmail)) {
    return res.status(400).json({ status: "error", error: "A valid email address is required for client login." });
  }

  if (!tempPassword || tempPassword.length < 8) {
    return res.status(400).json({ status: "error", error: "Temporary password must be at least 8 characters long." });
  }

  // 3. Duplicate checks in Firestore
  const customerDocRef = db.collection("customers").doc(normalizedPhone);
  const customerDocSnap = await customerDocRef.get();

  if (!isExistingCustomer && customerDocSnap.exists) {
    const existingData = customerDocSnap.data();
    if (existingData?.auth_uid && existingData?.login_enabled) {
      console.warn("[CREATE_CUSTOMER_AUTH][VALIDATION] Customer already exists with active login:", normalizedPhone);
      return res.status(409).json({
        status: "error",
        error: "Customer with this phone number already exists with an active login.",
      });
    }
  }

  // Duplicate email check in customers collection
  const emailSnap = await db
    .collection("customers")
    .where("email", "==", rawEmail)
    .limit(5)
    .get();

  for (const doc of emailSnap.docs) {
    if (doc.id !== normalizedPhone) {
      console.warn("[CREATE_CUSTOMER_AUTH][VALIDATION] Email already linked to another customer record:", rawEmail);
      return res.status(409).json({
        status: "error",
        error: "This email is already linked to another customer record.",
      });
    }
  }

  // 4. Firebase Admin Auth creation
  console.log("[CREATE_CUSTOMER_AUTH][FIREBASE_ADMIN] Initializing Auth user creation via Firebase Admin SDK");
  let authUid = "";
  let isNewlyCreatedAuthUser = false;

  try {
    let existingAuthUser = null;
    try {
      console.log("[CREATE_CUSTOMER_AUTH][AUTH_LOOKUP] Checking if Firebase Auth user already exists for:", rawEmail);
      existingAuthUser = await admin.auth().getUserByEmail(rawEmail);
      console.log("[CREATE_CUSTOMER_AUTH][AUTH_LOOKUP] Existing Firebase Auth user found with UID:", existingAuthUser.uid);
    } catch (e) {
      if (e.code !== "auth/user-not-found") {
        console.error("[CREATE_CUSTOMER_AUTH][AUTH_LOOKUP] Error during user lookup:", e);
        throw e;
      }
      console.log("[CREATE_CUSTOMER_AUTH][AUTH_LOOKUP] No existing Firebase Auth user found. Creating new user.");
    }

    if (existingAuthUser) {
      if (customerDocSnap.exists) {
        const custData = customerDocSnap.data();
        if (custData?.auth_uid && custData.auth_uid !== existingAuthUser.uid) {
          console.warn("[CREATE_CUSTOMER_AUTH][AUTH_CREATE] Conflict: Email belongs to different Auth user not linked to this client");
          return res.status(409).json({
            status: "error",
            error: "This email belongs to another Firebase Auth user not linked to this client.",
          });
        }
      }
      console.log("[CREATE_CUSTOMER_AUTH][AUTH_CREATE] Updating temporary password for existing Auth UID:", existingAuthUser.uid);
      await admin.auth().updateUser(existingAuthUser.uid, {
        password: tempPassword,
        displayName: fullName,
      });
      authUid = existingAuthUser.uid;
    } else {
      console.log("[CREATE_CUSTOMER_AUTH][AUTH_CREATE] Calling admin.auth().createUser for:", rawEmail);
      const newAuthUser = await admin.auth().createUser({
        email: rawEmail,
        password: tempPassword,
        displayName: fullName,
        emailVerified: false,
      });
      authUid = newAuthUser.uid;
      isNewlyCreatedAuthUser = true;
      console.log("[CREATE_CUSTOMER_AUTH][AUTH_CREATE] New Firebase Auth user created successfully with UID:", authUid);
    }

    // 5. Firestore Linking (Canonical customers/{phone} and customer_profiles/{authUid})
    console.log("[CREATE_CUSTOMER_AUTH][FIRESTORE] Linking canonical customers/" + normalizedPhone + " and customer_profiles/" + authUid);
    const nowIso = new Date().toISOString();
    const batch = db.batch();

    batch.set(
      customerDocRef,
      {
        id: normalizedPhone,
        phone: normalizedPhone,
        email: rawEmail,
        name: fullName,
        full_name: fullName,
        auth_uid: authUid,
        login_enabled: true,
        login_method: "email_password",
        must_change_password: true,
        login_created_at: nowIso,
        login_enabled_at: nowIso,
        updated_at: nowIso,
      },
      { merge: true }
    );

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
    console.log("[CREATE_CUSTOMER_AUTH][FIRESTORE] Firestore batch committed successfully");

    console.log("[CREATE_CUSTOMER_AUTH][SUCCESS] Customer login provisioning completed successfully for UID:", authUid);
    return res.status(200).json({
      status: "success",
      auth_uid: authUid,
      message: "Customer login provisioned successfully.",
    });
  } catch (error) {
    console.error("[CREATE_CUSTOMER_AUTH][ERROR] Failure during customer provisioning:", error);
    // Compensation rollback: delete newly created Auth user if Firestore commit failed
    if (isNewlyCreatedAuthUser && authUid) {
      try {
        console.warn("[CREATE_CUSTOMER_AUTH][ERROR] Rolling back orphaned Auth user:", authUid);
        await admin.auth().deleteUser(authUid);
        console.warn("[CREATE_CUSTOMER_AUTH][ERROR] Rollback compensation: deleted orphaned Auth user", authUid);
      } catch (delErr) {
        console.error("[CREATE_CUSTOMER_AUTH][ERROR] Failed rollback delete for", authUid, delErr);
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
 * HTTPS endpoint: createCustomerLogin
 */
exports.createCustomerLogin = functions
  .region("asia-south1")
  .https.onRequest((req, res) => {
    return cors(req, res, () => handleCustomerLoginCreation(req, res));
  });

/**
 * Alias HTTPS endpoint for backwards compatibility: adminCreateCustomerLogin
 */
exports.adminCreateCustomerLogin = functions
  .region("asia-south1")
  .https.onRequest((req, res) => {
    return cors(req, res, () => handleCustomerLoginCreation(req, res));
  });
