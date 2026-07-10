# Om Events Notification & Automation Engine

This repository contains the Flutter mobile client and the fully migrated server-side automation suite. 

## Architectural Overview

The backend has been completely migrated off **Firebase Cloud Functions** and **Google Cloud Scheduler** in favor of:
1. **Deno / Supabase Edge Functions** (located in `/supabase/functions/`) for all business logic, webhook processing, PDF generation, database maintenance, and analytics.
2. **`pg_cron`** + **`pg_net`** in the Supabase PostgreSQL database for database-native, server-side job scheduling and execution.
3. **Firestore** as the primary datastore, accessed via the Firebase Admin SDK within Deno.
4. **Supabase Storage** for PDF/HTML proposal artifacts and media.

No legacy Node.js/Firebase Cloud Functions or Cloud Scheduler configurations remain.

---

## Scheduler & Background Workers

The following background workers run server-side via `pg_cron` triggers calling Supabase Edge Functions:

| Worker / Job Name | Trigger Frequency | Purpose |
| --- | --- | --- |
| `check-scheduled-reminders` | Every 30 minutes | Checks scheduled alerts and routes to delivery outbox. |
| `process-notification-queue` | Every 30 minutes | Priority-based delivery outbox processor (Email, WhatsApp, Push). |
| `process-retry-queue` | Every 15 minutes | Re-evaluates failed deliveries using exponential backoff. |
| `check-quotation-expiry` | Hourly (:00) | Flags expired quotation documents in Firestore. |
| `send-expiry-reminders` | Hourly (:05) | Sends warning notifications for quotations near expiration. |
| `send-followups` | Hourly (:10) | Automates customer follow-up alerts for pending quotes. |
| `send-booking-reminders` | Daily (06:00) | Notifies admins and customers of upcoming booking events. |
| `cleanup-old-automation-logs`| Daily (01:00) | Automatically prunes aged execution logs and health runs. |
| `calculate-analytics` | Daily (02:00) | Regenerates quotation funnel stats and system performance KPIs. |
| `daily-digest` | Daily (09:00) | Bundles customer alerts into a daily briefing digest email. |
| `process-dlq` | Daily (04:00) | Automatically requeues dead-letter notifications under 24h old. |
| `version-cleanup` | Weekly (Sunday 03:00) | Prunes quotation version histories, storage orphans, and rate limits. |

---

## Deployment & Setup

### 1. Database Migrations & Schemas
Apply database migrations to register the jobs within PostgreSQL's `cron.job` table:
```bash
cd supabase
supabase db push
```

### 2. Environment Variables & Secrets
Define the required environment configurations:
```bash
supabase secrets set \
  FIREBASE_PROJECT_ID="your-firebase-project-id" \
  FIREBASE_SERVICE_ACCOUNT='{"type": "service_account", ...}' \
  RESEND_API_KEY="re_..." \
  RESEND_WEBHOOK_SECRET="whsec_..." \
  WHATSAPP_TOKEN="EAAB..." \
  WHATSAPP_PHONE_ID="102..." \
  WHATSAPP_WEBHOOK_SECRET="your_verify_token" \
  META_APP_SECRET="your_app_secret"
```

Configure Postgres to hold the service role key for cron authorization:
```sql
ALTER DATABASE postgres SET app.supabase_service_role_key = 'your-supabase-service-role-key';
```

### 3. Deploy Edge Functions
Deploy the server-side code:
```bash
supabase functions deploy
```
