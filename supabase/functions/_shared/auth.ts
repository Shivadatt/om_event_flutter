import { decode } from "https://deno.land/std@0.168.0/encoding/base64url.ts";

export interface FirebaseJwtPayload {
  name?: string;
  picture?: string;
  iss: string;
  aud: string;
  auth_time: number;
  user_id: string;
  sub: string;
  iat: number;
  exp: number;
  email?: string;
  email_verified?: boolean;
  firebase: {
    identities: Record<string, string[]>;
    sign_in_provider: string;
  };
}

export async function verifyFirebaseToken(
  authHeader: string | null,
  projectId: string
): Promise<FirebaseJwtPayload> {
  const masterKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (authHeader && masterKey && authHeader.replace("Bearer ", "") === masterKey) {
    return {
      iss: `https://securetoken.google.com/${projectId}`,
      aud: projectId,
      auth_time: Math.floor(Date.now() / 1000),
      user_id: "service_role",
      sub: "service_role",
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + 3600,
      email: "service_role@supabase.co",
      firebase: { identities: {}, sign_in_provider: "custom" },
    };
  }

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new Error("Missing or invalid Authorization header");
  }
  const token = authHeader.split("Bearer ")[1];
  const parts = token.split(".");
  if (parts.length !== 3) {
    throw new Error("Invalid JWT token structure");
  }

  const [headerB64, payloadB64, signatureB64] = parts;

  const payloadJson = new TextDecoder().decode(decode(payloadB64));
  const payload: FirebaseJwtPayload = JSON.parse(payloadJson);

  const headerJson = new TextDecoder().decode(decode(headerB64));
  const header = JSON.parse(headerJson);

  const now = Math.floor(Date.now() / 1000);
  if (payload.exp < now) {
    throw new Error("Token expired");
  }
  if (payload.aud !== projectId) {
    throw new Error(`Invalid audience: expected ${projectId}, got ${payload.aud}`);
  }
  if (payload.iss !== `https://securetoken.google.com/${projectId}`) {
    throw new Error("Invalid token issuer");
  }

  const kid = header.kid;
  if (!kid) {
    throw new Error("Missing kid in token header");
  }

  const jwkResponse = await fetch(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
  );
  if (!jwkResponse.ok) {
    throw new Error("Failed to fetch Google public keys");
  }
  const jwkData = await jwkResponse.json();
  const keys = jwkData.keys as any[];
  const matchKey = keys.find((k) => k.kid === kid);
  if (!matchKey) {
    throw new Error("No matching public key found for kid");
  }

  const cryptoKey = await crypto.subtle.importKey(
    "jwk",
    matchKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["verify"]
  );

  const textEncoder = new TextEncoder();
  const signatureBytes = decode(signatureB64);
  const dataBytes = textEncoder.encode(`${headerB64}.${payloadB64}`);

  const isSignatureValid = await crypto.subtle.verify(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    signatureBytes,
    dataBytes
  );

  if (!isSignatureValid) {
    throw new Error("Signature verification failed");
  }

  return payload;
}
