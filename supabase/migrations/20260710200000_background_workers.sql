-- ═══════════════════════════════════════════════════════════════════════════
-- Migration: 20260710200000_background_workers.sql
-- Registers all new background worker cron jobs idempotently.
-- Creates job_execution_locks and related tables.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ─────────────────────────────────────────────────────────────────────────────
-- Distributed Job Execution Lock Table
-- Used by _shared/job_runner.ts to prevent concurrent runs.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS job_execution_locks (
  job_name     TEXT PRIMARY KEY,
  locked_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at   TIMESTAMPTZ NOT NULL,
  worker_id    TEXT
);

-- Auto-cleanup: delete expired locks every 5 minutes
SELECT cron.unschedule('cleanup-expired-locks') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-expired-locks'
);
SELECT cron.schedule(
  'cleanup-expired-locks',
  '*/5 * * * *',
  $$DELETE FROM job_execution_locks WHERE expires_at < NOW();$$
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Job Registry — add new workers
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO cron_job_registry (job_name, schedule, description)
VALUES
  ('process-retry-queue',  '*/15 * * * *',  'Retry failed notifications with exponential backoff every 15 min'),
  ('process-dlq',          '0 4 * * *',     'Auto-requeue recent DLQ items daily at 04:00'),
  ('version-cleanup',      '0 3 * * 0',     'Prune old versions, sent queue, storage orphans every Sunday 03:00'),
  ('regenerate-pdf',       'manual',        'Server-side HTML contract generation — triggered on demand')
ON CONFLICT (job_name) DO UPDATE SET
  schedule    = EXCLUDED.schedule,
  description = EXCLUDED.description,
  updated_at  = NOW();

-- ─────────────────────────────────────────────────────────────────────────────
-- Cron: process-retry-queue — every 15 minutes
-- ─────────────────────────────────────────────────────────────────────────────
SELECT cron.unschedule('process-retry-queue-cron') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'process-retry-queue-cron'
);
SELECT cron.schedule(
  'process-retry-queue-cron',
  '*/15 * * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/process-retry-queue',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Cron: process-dlq — daily at 04:00
-- ─────────────────────────────────────────────────────────────────────────────
SELECT cron.unschedule('process-dlq-daily') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'process-dlq-daily'
);
SELECT cron.schedule(
  'process-dlq-daily',
  '0 4 * * *',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/process-dlq',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{"mode":"auto"}'::jsonb
  );
  $$
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Cron: version-cleanup — every Sunday at 03:00
-- ─────────────────────────────────────────────────────────────────────────────
SELECT cron.unschedule('version-cleanup-weekly') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'version-cleanup-weekly'
);
SELECT cron.schedule(
  'version-cleanup-weekly',
  '0 3 * * 0',
  $$
  SELECT net.http_post(
    url     := 'https://om-event.supabase.co/functions/v1/version-cleanup',
    headers := jsonb_build_object(
                 'Content-Type',  'application/json',
                 'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key', TRUE)
               ),
    body    := '{}'::jsonb
  );
  $$
);
