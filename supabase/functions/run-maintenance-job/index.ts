import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// run-maintenance-job
//
// Server-side replacement for the Flutter MaintenanceController client operations.
// Supports all batch migration operations with:
//   • Server-side Firestore batch processing (max 500 per batch)
//   • Cancellation via Firestore maintenance_jobs/{jobId}/cancel flag
//   • Progress updates written to maintenance_jobs/{jobId}
//   • Audit log written to maintenance_logs
//
// POST body: { operation: string, dryRun?: boolean, jobId?: string }
// GET  body: { jobId: string } → returns progress
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";

type OperationType =
  | "CustomerId Migration"
  | "Relationship Repair"
  | "Database Seeder"
  | "Category Validation"
  | "Item Validation"
  | "Notification Repair"
  | "Quotation Repair"
  | "Version Repair";

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  let adminClaims: { user_id: string; email?: string };
  try {
    adminClaims = await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID) as any;
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ status: "error", error: msg }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  // GET — check progress
  if (req.method === "GET") {
    const url = new URL(req.url);
    const jobId = url.searchParams.get("jobId");
    if (!jobId) {
      return new Response(JSON.stringify({ error: "jobId required" }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    const snap = await db.collection("maintenance_jobs").doc(jobId).get();
    const data = snap.exists ? snap.data() : { status: "not_found" };
    return new Response(JSON.stringify(data), { headers: { "Content-Type": "application/json" } });
  }

  const reqBody = await req.json().catch(() => ({})) as {
    operation?: OperationType;
    dryRun?: boolean;
    jobId?: string;
  };

  const { operation, dryRun = false, jobId = `maint_${Date.now()}` } = reqBody;
  if (!operation) {
    return new Response(JSON.stringify({ error: "operation is required" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Write initial job state
  const jobRef = db.collection("maintenance_jobs").doc(jobId);
  await jobRef.set({
    jobId,
    operation,
    dryRun,
    status: "running",
    progress: 0,
    scanned: 0,
    updated: 0,
    skipped: 0,
    errors: [],
    startedAt: new Date().toISOString(),
    startedBy: adminClaims.email ?? adminClaims.user_id,
    cancel: false,
  });

  return runJob({
    name: "run-maintenance-job",
    idempotencyKey: dryRun ? undefined : `maint_${operation}_${new Date().toDateString()}`,
    timeoutMs: 55_000,
    execute: async (_signal): Promise<JobResult> => {
      const startTime = Date.now();
      let scanned = 0, updated = 0, skipped = 0;
      const errors: string[] = [];

      const updateProgress = async (progress: number, status = "running") => {
        await jobRef.update({ progress, scanned, updated, skipped, errors, status, updatedAt: new Date().toISOString() });
      };

      // Check for cancellation
      const isCancelled = async (): Promise<boolean> => {
        const snap = await jobRef.get();
        return snap.exists && snap.data()?.cancel === true;
      };

      try {
        if (operation === "CustomerId Migration") {
          const quotesSnap = await db.collection("quotations").get();
          const totalDocs = quotesSnap.size;
          const BATCH_SIZE = 400;

          for (let i = 0; i < totalDocs; i += BATCH_SIZE) {
            if (await isCancelled()) { errors.push("Cancelled by admin"); break; }

            const batchDocs = quotesSnap.docs.slice(i, i + BATCH_SIZE);
            const batch = db.batch();
            let batchWrites = 0;

            for (const doc of batchDocs) {
              scanned++;
              const data = doc.data();
              const customerId = data.customerId;
              const legacyId = data.customer_id;

              if (!customerId || customerId === "unmigrated_legacy_id") {
                if (legacyId && legacyId !== "unmigrated_legacy_id") {
                  if (!dryRun) {
                    batch.update(doc.ref, { customerId: legacyId, updated_at: new Date().toISOString() });
                  }
                  updated++;
                  batchWrites++;
                } else {
                  skipped++;
                }
              } else {
                skipped++;
              }
            }

            if (batchWrites > 0 && !dryRun) {
              await batch.commit();
            }

            await updateProgress((i + batchDocs.length) / totalDocs);
          }
        } else if (operation === "Relationship Repair") {
          const itemsSnap = await db.collection("items").get();
          const catsSnap = await db.collection("categories").get();
          const validCatIds = new Set(catsSnap.docs.map((d) => d.id));
          const totalDocs = itemsSnap.size;
          const BATCH_SIZE = 400;

          for (let i = 0; i < totalDocs; i += BATCH_SIZE) {
            if (await isCancelled()) { errors.push("Cancelled by admin"); break; }

            const batchDocs = itemsSnap.docs.slice(i, i + BATCH_SIZE);
            const batch = db.batch();
            let batchWrites = 0;

            for (const doc of batchDocs) {
              scanned++;
              const data = doc.data();
              const catIds = data.category_ids as string[] | undefined;

              if (!catIds || catIds.length === 0) {
                skipped++;
                continue;
              }

              const validIds = catIds.filter((id) => validCatIds.has(id));
              if (validIds.length !== catIds.length) {
                if (!dryRun) {
                  batch.update(doc.ref, { category_ids: validIds, updated_at: new Date().toISOString() });
                }
                updated++;
                batchWrites++;
              } else {
                skipped++;
              }
            }

            if (batchWrites > 0 && !dryRun) {
              await batch.commit();
            }

            await updateProgress((i + batchDocs.length) / totalDocs);
          }
        } else {
          // Generic: Seeder / Validation / Repair operations
          // These perform collection-level integrity checks
          const targetCollection = operationToCollection(operation);
          const snap = await db.collection(targetCollection).get();
          scanned = snap.size;

          // Generic integrity check: look for docs missing required fields
          const requiredFields = operationToRequiredFields(operation);
          const batch = db.batch();
          let batchWrites = 0;

          for (const doc of snap.docs) {
            const data = doc.data();
            const missingFields = requiredFields.filter((f) => !data[f]);
            if (missingFields.length > 0) {
              const fixes: Record<string, unknown> = { updatedAt: new Date().toISOString() };
              missingFields.forEach((f) => { fixes[f] = getDefaultValue(f); });
              if (!dryRun) {
                batch.update(doc.ref, fixes);
              }
              updated++;
              batchWrites++;
            } else {
              skipped++;
            }
          }

          if (batchWrites > 0 && !dryRun) {
            await batch.commit();
          }

          await updateProgress(1.0);
        }

        const duration = Date.now() - startTime;
        await jobRef.update({
          status: errors.length > 0 ? "cancelled" : "success",
          progress: 1.0,
          scanned,
          updated,
          skipped,
          errors,
          completedAt: new Date().toISOString(),
          durationMs: duration,
        });

        // Write audit log
        await db.collection("maintenance_logs").add({
          jobId,
          adminId: "server",
          operation,
          dryRun,
          startedAt: new Date(Date.now() - duration).toISOString(),
          completedAt: new Date().toISOString(),
          durationMs: duration,
          documentsScanned: scanned,
          documentsUpdated: updated,
          documentsSkipped: skipped,
          errors,
          status: errors.length > 0 ? "Cancelled" : dryRun ? "DryRun" : "Success",
        });

        return {
          processedItems: updated,
          skippedItems: skipped,
          metadata: { scanned, errors: errors.length, dryRun, jobId },
          message: `${operation}: scanned=${scanned}, updated=${updated}, skipped=${skipped}`,
        };
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : String(e);
        await jobRef.update({ status: "failed", error: msg, completedAt: new Date().toISOString() });
        throw e;
      }
    },
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

function operationToCollection(op: OperationType): string {
  const map: Record<OperationType, string> = {
    "CustomerId Migration": "quotations",
    "Relationship Repair": "items",
    "Database Seeder": "categories",
    "Category Validation": "categories",
    "Item Validation": "items",
    "Notification Repair": "notification_queue",
    "Quotation Repair": "quotations",
    "Version Repair": "quotations",
  };
  return map[op] ?? "quotations";
}

function operationToRequiredFields(op: OperationType): string[] {
  const map: Record<OperationType, string[]> = {
    "CustomerId Migration": ["customerId"],
    "Relationship Repair": ["category_ids"],
    "Database Seeder": ["name"],
    "Category Validation": ["name", "createdAt"],
    "Item Validation": ["name", "price", "category_ids"],
    "Notification Repair": ["status", "retryCount"],
    "Quotation Repair": ["status", "customerId"],
    "Version Repair": ["publicId"],
  };
  return map[op] ?? [];
}

function getDefaultValue(field: string): unknown {
  if (field === "retryCount") return 0;
  if (field === "status") return "pending";
  if (field === "category_ids") return [];
  if (field === "createdAt" || field === "updatedAt") return new Date().toISOString();
  return "";
}
