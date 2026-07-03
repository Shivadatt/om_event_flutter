-- =============================================================================
-- Migration: 20260703000011_setup_notification_webhooks.sql
-- Purpose  : Setup pg_net triggers and pg_cron schedules for asynchronous
--            real-time and scheduled processing of notifications.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

-- Enable pg_net extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "pg_net";

-- Enable pg_cron extension if not already enabled (in pg_catalog / standard schema)
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- ---------------------------------------------------------------------------
-- Webhook Trigger Function for Real-time Processing
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_fn_queue_insert_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Invoke process-queue Edge Function asynchronously via pg_net
  PERFORM net.http_post(
    url := 'https://kwegyvbgdaednljyhcgm.supabase.co/functions/v1/process-queue',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := jsonb_build_object('record', row_to_json(NEW)::jsonb),
    timeout_milliseconds := 5000
  );
  RETURN NEW;
END;
$$;

-- Create trigger on notification_queue to fire on new inserts in pending status
DROP TRIGGER IF EXISTS trg_queue_insert_webhook ON public.notification_queue;
CREATE TRIGGER trg_queue_insert_webhook
  AFTER INSERT ON public.notification_queue
  FOR EACH ROW
  WHEN (NEW.status = 'pending')
  EXECUTE FUNCTION public.trg_fn_queue_insert_webhook();

-- ---------------------------------------------------------------------------
-- pg_cron Schedules for Periodical Processing & Reminders Promotion
-- ---------------------------------------------------------------------------

-- Cron 1: Poll queue for retries, paused DND items, and FIFO pending items every minute
SELECT cron.schedule(
  'poll-notification-queue-cron',
  '* * * * *',
  $$ SELECT net.http_post(
       url := 'https://kwegyvbgdaednljyhcgm.supabase.co/functions/v1/process-queue',
       headers := '{"Content-Type": "application/json"}'::jsonb,
       body := '{}'::jsonb
     )
  $$
);

-- Cron 2: Scan scheduled_notifications and promote due reminders every minute
SELECT cron.schedule(
  'poll-scheduled-notifications-cron',
  '* * * * *',
  $$ SELECT net.http_post(
       url := 'https://kwegyvbgdaednljyhcgm.supabase.co/functions/v1/process-scheduled',
       headers := '{"Content-Type": "application/json"}'::jsonb,
       body := '{}'::jsonb
     )
  $$
);

-- ---------------------------------------------------------------------------
-- Helper function to atomically fetch and lock next queue task (skip locked)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.lock_next_queue_task()
RETURNS SETOF public.notification_queue
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
BEGIN
  SELECT id INTO v_id
  FROM public.notification_queue
  WHERE status IN ('pending', 'retry')
    AND (scheduled_at IS NULL OR scheduled_at <= NOW())
  ORDER BY
    priority = 'critical' DESC,
    priority = 'high' DESC,
    priority = 'normal' DESC,
    created_at ASC
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF v_id IS NOT NULL THEN
    UPDATE public.notification_queue
    SET status = 'processing',
        updated_at = NOW()
    WHERE id = v_id;

    RETURN QUERY
    SELECT * FROM public.notification_queue WHERE id = v_id;
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Helper function to fetch aggregated dashboard analytics in one call
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_notification_analytics()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_pending INT;
  v_processing INT;
  v_sent INT;
  v_failed INT;
  v_retry INT;
  v_dead INT;
  v_total_attempts INT;
  v_success_rate NUMERIC;
  v_avg_delivery_time_ms NUMERIC;
BEGIN
  -- Counts from notification_queue
  SELECT COUNT(*) FILTER (WHERE status = 'pending') INTO v_pending FROM public.notification_queue;
  SELECT COUNT(*) FILTER (WHERE status = 'processing') INTO v_processing FROM public.notification_queue;
  SELECT COUNT(*) FILTER (WHERE status = 'retry') INTO v_retry FROM public.notification_queue;

  -- Counts from notification_logs
  SELECT COUNT(*) FILTER (WHERE status = 'sent') INTO v_sent FROM public.notification_logs;
  SELECT COUNT(*) FILTER (WHERE status = 'failed') INTO v_failed FROM public.notification_logs;

  -- Counts from dead_letter_notifications
  SELECT COUNT(*) INTO v_dead FROM public.dead_letter_notifications;

  -- Calculate Success Rate
  v_total_attempts := v_sent + v_failed + v_dead;
  IF v_total_attempts > 0 THEN
    v_success_rate := (v_sent::NUMERIC / v_total_attempts::NUMERIC) * 100.0;
  ELSE
    v_success_rate := 100.0;
  END IF;

  -- Calculate Average Delivery Time (difference between received_at and event_timestamp for 'sent' delivery events)
  SELECT AVG(EXTRACT(EPOCH FROM (event_timestamp - received_at)) * 1000)
  INTO v_avg_delivery_time_ms
  FROM public.delivery_events
  WHERE event_type = 'sent';

  RETURN jsonb_build_object(
    'pending', v_pending,
    'processing', v_processing,
    'sent', v_sent,
    'failed', v_failed,
    'retry', v_retry,
    'dead', v_dead,
    'success_rate', ROUND(v_success_rate, 1),
    'avg_delivery_time_ms', ROUND(COALESCE(v_avg_delivery_time_ms, 0.0), 1)
  );
END;
$$;


