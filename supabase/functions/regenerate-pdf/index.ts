import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { db } from "../_shared/firebase.ts";
import { verifyFirebaseToken } from "../_shared/auth.ts";
import { runJob, type JobResult } from "../_shared/job_runner.ts";

// ─────────────────────────────────────────────────────────────────────────────
// regenerate-pdf
//
// Server-side PDF/HTML contract generation for quotations.
// Generates an HTML contract document from quotation data,
// uploads it to Supabase Storage, and writes the public URL back
// to the quotation document as pdfUrl.
//
// Trigger: POST with { quotationId } from admin action or quotation update.
// Also used as batch re-generation for all quotations missing pdfUrl.
// ─────────────────────────────────────────────────────────────────────────────

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") || "om-event";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const STORAGE_BUCKET = "quotation-pdfs";

serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  try {
    await verifyFirebaseToken(authHeader, FIREBASE_PROJECT_ID);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ status: "error", error: msg }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  let quotationId: string | undefined;
  if (req.method === "POST" && (req.headers.get("content-length") ?? "0") !== "0") {
    const body = await req.json().catch(() => ({})) as Record<string, string>;
    quotationId = body.quotationId;
  }

  return runJob({
    name: "regenerate-pdf",
    idempotencyKey: quotationId ? `pdf_regen_${quotationId}_${new Date().toDateString()}` : undefined,
    timeoutMs: 55_000,
    execute: async (_signal): Promise<JobResult> => {
      let processedCount = 0;

      if (quotationId) {
        // ── SINGLE QUOTATION ─────────────────────────────────────────────────
        const docSnap = await db.collection("quotations").doc(quotationId).get();
        if (!docSnap.exists) {
          return { processedItems: 0, message: `Quotation ${quotationId} not found` };
        }
        await processQuotation(docSnap.id, docSnap.data()!);
        processedCount = 1;
      } else {
        // ── BATCH: all quotations missing pdfUrl ────────────────────────────
        const snap = await db.collection("quotations")
          .where("pdfUrl", "==", "")
          .limit(20)
          .get();

        for (const doc of snap.docs) {
          await processQuotation(doc.id, doc.data());
          processedCount++;
        }
      }

      return {
        processedItems: processedCount,
        message: quotationId
          ? `PDF regenerated for ${quotationId}`
          : `Batch regenerated ${processedCount} PDFs`,
      };
    },
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Core PDF generation logic
// ─────────────────────────────────────────────────────────────────────────────

async function processQuotation(
  docId: string,
  quote: Record<string, unknown>
): Promise<void> {
  const html = buildHtmlContract(docId, quote);
  const fileName = `${docId}.html`;
  const storagePath = `contracts/${fileName}`;

  // Upload to Supabase Storage
  const uploadUrl = `${SUPABASE_URL}/storage/v1/object/${STORAGE_BUCKET}/${storagePath}`;
  const uploadRes = await fetch(uploadUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "text/html",
      "x-upsert": "true",
    },
    body: html,
  });

  if (!uploadRes.ok) {
    const err = await uploadRes.text();
    throw new Error(`Storage upload failed: ${err}`);
  }

  // Build public URL
  const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/${STORAGE_BUCKET}/${storagePath}`;

  // Write pdfUrl back to Firestore
  await db.collection("quotations").doc(docId).update({
    pdfUrl: publicUrl,
    pdfGeneratedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HTML Contract Template
// ─────────────────────────────────────────────────────────────────────────────

function buildHtmlContract(docId: string, q: Record<string, unknown>): string {
  const publicId = String(q.publicId ?? q.public_id ?? docId);
  const customerName = String(q.customer_name ?? q.customerName ?? "Valued Customer");
  const eventDate = String(q.eventDate ?? q.event_date ?? "TBD");
  const totalAmount = String(q.totalAmount ?? q.total_amount ?? "0.00");
  const items = (q.items as Record<string, unknown>[] | undefined) ?? [];
  const status = String(q.status ?? "draft");
  const createdAt = String(q.createdAt ?? q.created_at ?? new Date().toISOString());

  const itemsHtml = items.length
    ? items.map((item: any) =>
        `<tr>
          <td style="padding:8px;border:1px solid #e5e7eb">${item.name ?? item.title ?? ""}</td>
          <td style="padding:8px;border:1px solid #e5e7eb;text-align:right">${item.quantity ?? 1}</td>
          <td style="padding:8px;border:1px solid #e5e7eb;text-align:right">₹${item.price ?? item.rate ?? 0}</td>
          <td style="padding:8px;border:1px solid #e5e7eb;text-align:right">₹${(Number(item.quantity ?? 1) * Number(item.price ?? item.rate ?? 0)).toFixed(2)}</td>
        </tr>`
      ).join("")
    : `<tr><td colspan="4" style="padding:16px;text-align:center;color:#9ca3af">No items specified</td></tr>`;

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Om Events — Quotation ${publicId}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Georgia, serif; background: #fff; color: #1f2937; padding: 40px; max-width: 800px; margin: auto; }
    .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #d4af37; padding-bottom: 20px; margin-bottom: 30px; }
    .logo { font-size: 28px; font-weight: bold; color: #d4af37; letter-spacing: 2px; }
    .doc-meta { text-align: right; font-size: 13px; color: #6b7280; }
    .doc-meta strong { color: #1f2937; font-size: 16px; display: block; margin-bottom: 4px; }
    .section { margin-bottom: 24px; }
    .section h3 { font-size: 14px; text-transform: uppercase; letter-spacing: 1px; color: #9ca3af; margin-bottom: 8px; border-bottom: 1px solid #f3f4f6; padding-bottom: 4px; }
    .info-row { display: flex; gap: 40px; }
    .info-block p { margin: 4px 0; font-size: 14px; }
    .info-block .label { color: #6b7280; font-size: 12px; }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    thead th { background: #1f2937; color: #fff; padding: 10px 8px; text-align: left; }
    tfoot td { padding: 8px; font-weight: bold; text-align: right; background: #f9fafb; border: 1px solid #e5e7eb; }
    .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; background: #d4af3722; color: #92650a; border: 1px solid #d4af37; }
    .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #9ca3af; text-align: center; }
  </style>
</head>
<body>
  <div class="header">
    <div class="logo">OM EVENTS</div>
    <div class="doc-meta">
      <strong>QUOTATION</strong>
      <span># ${publicId}</span><br>
      <span>Date: ${new Date(createdAt).toLocaleDateString("en-IN")}</span><br>
      <span class="status-badge">${status.toUpperCase()}</span>
    </div>
  </div>

  <div class="section">
    <h3>Client Information</h3>
    <div class="info-row">
      <div class="info-block">
        <p class="label">Customer Name</p>
        <p>${customerName}</p>
      </div>
      <div class="info-block">
        <p class="label">Event Date</p>
        <p>${eventDate}</p>
      </div>
    </div>
  </div>

  <div class="section">
    <h3>Services &amp; Items</h3>
    <table>
      <thead>
        <tr>
          <th>Description</th>
          <th style="text-align:right;width:80px">Qty</th>
          <th style="text-align:right;width:100px">Rate</th>
          <th style="text-align:right;width:110px">Total</th>
        </tr>
      </thead>
      <tbody>${itemsHtml}</tbody>
      <tfoot>
        <tr>
          <td colspan="3">Grand Total</td>
          <td>₹${totalAmount}</td>
        </tr>
      </tfoot>
    </table>
  </div>

  <div class="footer">
    <p>Om Events &bull; Ahmedabad, Gujarat, India</p>
    <p>This document was generated automatically on ${new Date().toLocaleString("en-IN")}</p>
    <p>For queries, contact us at admin@omevents.com</p>
  </div>
</body>
</html>`;
}
