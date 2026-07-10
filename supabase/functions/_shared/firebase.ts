import { initializeApp, credential } from "https://esm.sh/firebase-admin@11.8.0/app";
import { getFirestore } from "https://esm.sh/firebase-admin@11.8.0/firestore";

let app;
const saEnv = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
if (saEnv) {
  try {
    const serviceAccount = JSON.parse(saEnv);
    app = initializeApp({
      credential: credential.cert(serviceAccount),
    });
  } catch (_) {
    // Suppress secondary initialization attempts
  }
} else {
  try {
    app = initializeApp();
  } catch (_) {}
}

export const db = getFirestore();
export { FieldValue } from "https://esm.sh/firebase-admin@11.8.0/firestore";
