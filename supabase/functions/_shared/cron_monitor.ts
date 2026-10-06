// ═══════════════════════════════════════════════════════════════════════
// _shared/cron_monitor.ts
// Writes a cron health record before and after every scheduled job.
// Every Edge Function calls markJobStart / markJobComplete / markJobFailed.
// ═══════════════════════════════════════════════════════════════════════
import { db } from "./firebase.ts";

export interface CronJobRecord {
  jobName: string;
  status: "running" | "success" | "failed" | "skipped";
  startedAt: string;
  completedAt?: string;
  durationMs?: number;
  failureCount?: number;
  message?: string;
  processedItems?: number;
}

const HEALTH_COLLECTION = "cron_health_logs";
const HEALTH_SUMMARY_COLLECTION = "cron_health_summary";

/** Write a "running" record (console only, Firestore writes temporarily disabled). */
export async function markJobStart(jobName: string): Promise<string> {
  const now = new Date().toISOString();
  console.log(`[CRON START] Job '${jobName}' started at ${now}`);
  // Return dummy ID so callers can pass it around without Firestore document creation
  return `job_${Date.now()}`;
}

/** Complete job (console only, Firestore writes temporarily disabled). */
export async function markJobComplete(
  logId: string,
  jobName: string,
  startMs: number,
  opts: { processedItems?: number; message?: string } = {}
): Promise<void> {
  const durationMs = Date.now() - startMs;
  console.log(`[CRON COMPLETE] Job '${jobName}' finished in ${durationMs}ms (items: ${opts.processedItems ?? 0}, msg: ${opts.message ?? "OK"})`);
}

/** Update the job with failure details (console only, Firestore writes temporarily disabled). */
export async function markJobFailed(
  logId: string,
  jobName: string,
  startMs: number,
  errorMessage: string
): Promise<void> {
  const durationMs = Date.now() - startMs;
  console.error(`[CRON FAILED] Job '${jobName}' failed after ${durationMs}ms: ${errorMessage}`);
}

/** Mark job as skipped (console only, Firestore writes temporarily disabled). */
export async function markJobSkipped(
  logId: string,
  jobName: string,
  reason: string
): Promise<void> {
  console.log(`[CRON SKIPPED] Job '${jobName}' skipped: ${reason}`);
}
