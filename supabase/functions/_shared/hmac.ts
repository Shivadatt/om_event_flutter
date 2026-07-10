// ═══════════════════════════════════════════════════════════════════════════
// _shared/hmac.ts
//
// HMAC-SHA256 signature verification for inbound webhooks.
// Supports Resend (svix-style header) and Meta WhatsApp webhook verification.
// ═══════════════════════════════════════════════════════════════════════════

/**
 * Verify a HMAC-SHA256 webhook signature.
 *
 * @param secret     Raw signing secret (not base64-encoded)
 * @param body       Raw request body as string
 * @param signature  Signature from the webhook header (hex or base64)
 * @param encoding   "hex" | "base64" — how the provider encodes the sig
 */
export async function verifyHmacSignature(
  secret: string,
  body: string,
  signature: string,
  encoding: "hex" | "base64" = "hex"
): Promise<boolean> {
  try {
    const encoder = new TextEncoder();
    const keyData = encoder.encode(secret);
    const bodyData = encoder.encode(body);

    const cryptoKey = await crypto.subtle.importKey(
      "raw",
      keyData,
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const signatureBuffer = await crypto.subtle.sign("HMAC", cryptoKey, bodyData);
    const computedHex = bufferToHex(signatureBuffer);

    let expectedSig = signature;

    // Strip common prefixes
    if (expectedSig.startsWith("sha256=")) {
      expectedSig = expectedSig.slice("sha256=".length);
    }

    if (encoding === "base64") {
      const computedBase64 = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer)));
      return timingSafeEqual(computedBase64, expectedSig);
    }

    return timingSafeEqual(computedHex, expectedSig.toLowerCase());
  } catch (_) {
    return false;
  }
}

/**
 * Verify Resend webhook signature.
 * Header: `svix-signature` contains one or more `v1,<base64>` pairs.
 * Also checks `svix-timestamp` for replay attack prevention (5 min window).
 */
export async function verifyResendWebhook(
  secret: string,
  headers: Headers,
  rawBody: string
): Promise<boolean> {
  const svixId = headers.get("svix-id") ?? "";
  const svixTimestamp = headers.get("svix-timestamp") ?? "";
  const svixSignature = headers.get("svix-signature") ?? "";

  if (!svixTimestamp || !svixSignature) return false;

  // Replay attack prevention: reject messages older than 5 minutes
  const ts = parseInt(svixTimestamp, 10);
  const nowSeconds = Math.floor(Date.now() / 1000);
  if (Math.abs(nowSeconds - ts) > 300) return false;

  const signedContent = `${svixId}.${svixTimestamp}.${rawBody}`;
  const signatures = svixSignature.split(" ");

  for (const sig of signatures) {
    const [, b64] = sig.split(",");
    if (!b64) continue;
    const isValid = await verifyHmacSignature(secret, signedContent, b64, "base64");
    if (isValid) return true;
  }

  return false;
}

/**
 * Verify Meta WhatsApp webhook signature.
 * Header: `x-hub-signature-256` = `sha256=<hex>`
 */
export async function verifyMetaWebhook(
  appSecret: string,
  headers: Headers,
  rawBody: string
): Promise<boolean> {
  const sig = headers.get("x-hub-signature-256") ?? "";
  if (!sig) return false;
  return verifyHmacSignature(appSecret, rawBody, sig, "hex");
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

function bufferToHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/** Constant-time string comparison to prevent timing attacks */
function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}
