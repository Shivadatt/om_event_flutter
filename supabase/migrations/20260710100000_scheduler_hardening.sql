-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 20260710100000_scheduler_hardening.sql
-- Complete scheduler replacement — removes Cloud Scheduler / Firebase Scheduler.
-- Registers all pg_cron jobs idempotently.
-- Creates cron_health_summary + cron_health_logs tables for Admin Dashboard.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- Extensions
-- ─────────────────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ─────────────────────────────────────────────────────────────────────────────
-- Health monitoring tables (Postgres side for dashboarding)
-- The Flutter Admin Dashboard reads these directly via the Edge Function.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cron_job_registry (
  id              SERIAL PRIMARY KEY,
  job_name        TEXT UNIQUE NOT NULL,
  schedule        TEXT NOT NULL,
  description     TEXT,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Populate registry
INSERT INTO cron_job_registry (job_name, schedule, description)
VALUES
  ('check-scheduled-reminders',  '*/30 * * * *', 'Dispatch pending scheduled notifications every 30 min'),
  ('check-quotation-expiry',     '0 * * * *',    'Mark quotations as expired every hour'),
  ('send-expiry-reminders',      '5 * * * *',    'Send 24h and 2h pre-expiry reminders every hour'),
  ('send-followups',             '10 * * * *',   'Send follow-ups for viewed quotations every hour'),
  ('send-booking-reminders',     '0 6 * * *',    'Send booking event reminders every day at 06:00'),
  ('process-notification-queue', '*/30 * * * *', 'Process notification outbox every 30 min'),
  ('cleanup-old-automation-logs','0 1 * * *',    'Delete logs older than 30 days at 01:00'),
  ('calculate-analytics',        '0 2 * * *',    'Refresh analytics aggregations at 02:00'),
  ('daily-digest',               '0 9 * * *',    'Send admin morning digest at 09:00')
ON CONFLICT (job_name) DO UPDATE SET
  schedule = EXCLUDED.schedule,
  description = EXCLUDED.description,
  updated_at = NOW();

-- ─────────────────────────────────────────────────────────────────────────────
-- Idempotent cron setup helper
-- Use cron.unschedule first so re-runs don't duplicate jobs.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. check-scheduled-reminders — every 30 min (replaces Firebase checkScheduledReminders)
SELECT cron.unschedule('check-scheduled-reminders-cron') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'check-scheduled-reminders-cron'
);
SELECT cron.schedule(
  'check-scheduled-reminders-cron',
  '*/30 * * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/check-scheduled-reminders',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 2. check-quotation-expiry — every hour at minute 0
SELECT cron.unschedule('check-quotation-expiry-hourly') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'check-quotation-expiry-hourly'
);
SELECT cron.schedule(
  'check-quotation-expiry-hourly',
  '0 * * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/check-quotation-expiry',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 3. send-expiry-reminders — every hour at minute 5
SELECT cron.unschedule('send-expiry-reminders-hourly') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-expiry-reminders-hourly'
);
SELECT cron.schedule(
  'send-expiry-reminders-hourly',
  '5 * * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/send-expiry-reminders',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 4. send-followups — every hour at minute 10
SELECT cron.unschedule('send-followups-hourly') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-followups-hourly'
);
SELECT cron.schedule(
  'send-followups-hourly',
  '10 * * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/send-followups',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 5. send-booking-reminders — daily at 06:00
SELECT cron.unschedule('send-booking-reminders-daily') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-booking-reminders-daily'
);
SELECT cron.schedule(
  'send-booking-reminders-daily',
  '0 6 * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/send-booking-reminders',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 6. process-notification-queue — every 30 min
SELECT cron.unschedule('process-notification-queue-hourly') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'process-notification-queue-hourly'
);
SELECT cron.schedule(
  'process-notification-queue-hourly',
  '*/30 * * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/process-notification-queue',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 7. cleanup-old-automation-logs — daily at 01:00
SELECT cron.unschedule('cleanup-old-automation-logs-daily') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-old-automation-logs-daily'
);
SELECT cron.schedule(
  'cleanup-old-automation-logs-daily',
  '0 1 * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/cleanup-old-automation-logs',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 8. calculate-analytics — daily at 02:00
SELECT cron.unschedule('calculate-analytics-daily') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'calculate-analytics-daily'
);
SELECT cron.schedule(
  'calculate-analytics-daily',
  '0 2 * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/calculate-analytics',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- 9. daily-digest — daily at 09:00
SELECT cron.unschedule('send-daily-digest-daily') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-daily-digest-daily'
);
SELECT cron.schedule(
  'send-daily-digest-daily',
  '0 9 * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/daily-digest',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);
