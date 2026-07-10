// ═══════════════════════════════════════════════════════════════════════════
// _shared/rate_limiter.ts
//
// Token-bucket rate limiter keyed by (jobName + recipientId).
// State is stored in Firestore `rate_limit_buckets` collection.
// Each record holds tokens + last refill timestamp.
//
// Usage:
//   const allowed = await checkRateLimit("notification_queue", recipientId, 10, 60);
//   // 10 tokens per 60 seconds
// ═══════════════════════════════════════════════════════════════════════════

import { db } from "./firebase.ts";

const BUCKET_COLLECTION = "rate_limit_buckets";

export interface RateLimitConfig {
  /** Max tokens in bucket */
  capacity: number;
  /** Refill interval in seconds */
  windowSeconds: number;
  /** Tokens consumed per request */
  cost?: number;
}

export async function checkRateLimit(
  scope: string,
  key: string,
  config: RateLimitConfig
): Promise<{ allowed: boolean; remaining: number; resetAt: string }> {
  const { capacity, windowSeconds, cost = 1 } = config;
  const bucketId = `${scope}__${key}`;
  const bucketRef = db.collection(BUCKET_COLLECTION).doc(bucketId);
  const now = Date.now();
  const windowMs = windowSeconds * 1000;

  try {
    const snap = await bucketRef.get();

    let tokens = capacity;
    let lastRefill = now;

    if (snap.exists) {
      const data = snap.data()!;
      lastRefill = new Date(data.lastRefill as string).getTime();
      tokens = data.tokens as number;

      // Refill proportionally based on elapsed time
      const elapsed = now - lastRefill;
      const refillAmount = Math.floor((elapsed / windowMs) * capacity);
      tokens = Math.min(capacity, tokens + refillAmount);

      if (refillAmount > 0) {
        lastRefill = now;
      }
    }

    if (tokens < cost) {
      const resetAt = new Date(lastRefill + windowMs).toISOString();
      return { allowed: false, remaining: tokens, resetAt };
    }

    const newTokens = tokens - cost;
    await bucketRef.set({
      scope,
      key,
      tokens: newTokens,
      lastRefill: new Date(lastRefill).toISOString(),
      updatedAt: new Date().toISOString(),
    });

    return {
      allowed: true,
      remaining: newTokens,
      resetAt: new Date(lastRefill + windowMs).toISOString(),
    };
  } catch (_) {
    // Fail open on rate limiter errors — don't block production traffic
    return { allowed: true, remaining: capacity, resetAt: new Date(now + windowMs).toISOString() };
  }
}

/**
 * Convenience: Check rate limit and throw if exceeded.
 * Use inside notification queue processor to prevent per-recipient flood.
 */
export async function enforceRateLimit(
  scope: string,
  key: string,
  config: RateLimitConfig
): Promise<void> {
  const result = await checkRateLimit(scope, key, config);
  if (!result.allowed) {
    throw new Error(
      `Rate limit exceeded for ${scope}/${key}. Resets at ${result.resetAt}. Remaining: ${result.remaining}`
    );
  }
}

/**
 * Global notification rate limits per recipient (configurable):
 * - email: 20 per hour
 * - whatsapp: 5 per hour
 * - push: 50 per hour
 */
export const NOTIFICATION_RATE_LIMITS: Record<string, RateLimitConfig> = {
  email: { capacity: 20, windowSeconds: 3600, cost: 1 },
  whatsapp: { capacity: 5, windowSeconds: 3600, cost: 1 },
  push: { capacity: 50, windowSeconds: 3600, cost: 1 },
};
