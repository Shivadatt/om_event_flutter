-- =============================================================================
-- Migration: 20260703000008_create_dead_letter_notifications.sql
-- Table    : dead_letter_notifications
-- Purpose  : Permanent repository for notifications that exhausted all retry
--            attempts (retry_count >= max_retries) and could not be delivered.
--            Enables manual inspection, re-queue, or root-cause analysis.
--            Also captures notifications that failed due to infrastructure
--            errors (malformed payload, invalid token, provider outage).
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enum: dead_letter_reason
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dead_letter_reason') THEN
    CREATE TYPE dead_letter_reason AS ENUM (
      'max_retries_exceeded',
      'invalid_token',
      'invalid_recipient',
      'malformed_payload',
      'provider_rejected',
      'provider_outage',
      'rate_limit_exceeded',
      'unsubscribed',
      'expired',
      'unknown'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Enum: dead_letter_resolution
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dead_letter_resolution') THEN
    CREATE TYPE dead_letter_resolution AS ENUM (
      'unresolved',
      'manually_requeued',
      'discarded',
      'resolved_externally'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: dead_letter_notifications
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.dead_letter_notifications (
  id                  UUID                        NOT NULL DEFAULT gen_random_uuid(),

  -- Reference to the original queue item (denormalised for permanence).
  original_queue_id   UUID,

  -- Reference to the notification log (if one exists).
  log_id              UUID,

  -- Full snapshot of the original queue item payload at time of dead-lettering.
  original_payload    JSONB                       NOT NULL DEFAULT '{}'::JSONB,

  -- Recipient information (denormalised for permanence).
  recipient           TEXT                        NOT NULL DEFAULT '',
  recipient_id        TEXT                        NOT NULL DEFAULT '',
  recipient_role      TEXT                        NOT NULL DEFAULT 'customer',

  -- Notification content snapshot.
  notification_type   TEXT                        NOT NULL DEFAULT '',
  title               TEXT                        NOT NULL DEFAULT '',
  body                TEXT                        NOT NULL DEFAULT '',
  channel             notification_channel        NOT NULL DEFAULT 'push',
  priority            notification_priority       NOT NULL DEFAULT 'normal',

  -- Dead-letter classification.
  reason              dead_letter_reason          NOT NULL DEFAULT 'unknown',
  reason_description  TEXT                        NOT NULL DEFAULT '',

  -- Total delivery attempts made before dead-lettering.
  retry_count         SMALLINT                    NOT NULL DEFAULT 0,

  -- Last provider error detail.
  last_error          TEXT                        NOT NULL DEFAULT '',

  -- Stack trace / debug detail from the queue runner.
  stack_trace         TEXT,

  -- Resolution tracking for ops team.
  resolution          dead_letter_resolution      NOT NULL DEFAULT 'unresolved',
  resolved_by         TEXT,
  resolved_at         TIMESTAMPTZ,
  resolution_notes    TEXT,

  -- If re-queued, reference the new queue item.
  requeue_id          UUID,

  -- Audit timestamps.
  created_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT dead_letter_notifications_pkey          PRIMARY KEY (id),
  CONSTRAINT dead_letter_notifications_retry_chk     CHECK (retry_count >= 0),
  CONSTRAINT dead_letter_notifications_resolved_chk  CHECK (
    (resolution = 'unresolved' AND resolved_at IS NULL AND resolved_by IS NULL)
    OR
    (resolution <> 'unresolved' AND resolved_at IS NOT NULL)
  )
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Primary operations dashboard query: unresolved dead letters.
CREATE INDEX IF NOT EXISTS idx_dl_unresolved
  ON public.dead_letter_notifications (created_at DESC)
  WHERE resolution = 'unresolved';

-- Recipient-based lookup for customer support.
CREATE INDEX IF NOT EXISTS idx_dl_recipient_id
  ON public.dead_letter_notifications (recipient_id, created_at DESC);

-- Reason-based analysis (most common failure modes).
CREATE INDEX IF NOT EXISTS idx_dl_reason
  ON public.dead_letter_notifications (reason, created_at DESC);

-- Channel failure analysis.
CREATE INDEX IF NOT EXISTS idx_dl_channel_reason
  ON public.dead_letter_notifications (channel, reason, created_at DESC);

-- Original queue item tracing.
CREATE INDEX IF NOT EXISTS idx_dl_original_queue_id
  ON public.dead_letter_notifications (original_queue_id)
  WHERE original_queue_id IS NOT NULL;

-- Log linkage.
CREATE INDEX IF NOT EXISTS idx_dl_log_id
  ON public.dead_letter_notifications (log_id)
  WHERE log_id IS NOT NULL;

-- Re-queue tracing.
CREATE INDEX IF NOT EXISTS idx_dl_requeue_id
  ON public.dead_letter_notifications (requeue_id)
  WHERE requeue_id IS NOT NULL;

-- GIN on original_payload for payload-level debugging.
CREATE INDEX IF NOT EXISTS idx_dl_original_payload_gin
  ON public.dead_letter_notifications USING GIN (original_payload);

-- Time-range operations reporting.
CREATE INDEX IF NOT EXISTS idx_dl_created_at
  ON public.dead_letter_notifications (created_at DESC);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_dead_letter_updated_at ON public.dead_letter_notifications;
CREATE TRIGGER trg_dead_letter_updated_at
  BEFORE UPDATE ON public.dead_letter_notifications
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Trigger: set resolved_at when resolution changes from unresolved
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_set_dl_resolved_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.resolution <> 'unresolved' AND OLD.resolution = 'unresolved' AND NEW.resolved_at IS NULL THEN
    NEW.resolved_at = NOW();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_dead_letter_resolved_at ON public.dead_letter_notifications;
CREATE TRIGGER trg_dead_letter_resolved_at
  BEFORE UPDATE ON public.dead_letter_notifications
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_dl_resolved_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.dead_letter_notifications ENABLE ROW LEVEL SECURITY;

-- Only service role (ops tools / admin backend) has access.
CREATE POLICY "dl_service_role_policy"
  ON public.dead_letter_notifications FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.dead_letter_notifications IS 'Permanent repository for notifications that exhausted all retry attempts. Enables ops team to inspect, re-queue, or discard failed notifications.';
COMMENT ON COLUMN public.dead_letter_notifications.id                IS 'UUID primary key.';
COMMENT ON COLUMN public.dead_letter_notifications.original_queue_id IS 'Soft FK to the notification_queue.id that was dead-lettered.';
COMMENT ON COLUMN public.dead_letter_notifications.log_id            IS 'Soft FK to notification_logs.id if a log entry exists.';
COMMENT ON COLUMN public.dead_letter_notifications.original_payload  IS 'Complete snapshot of the queue item payload at time of dead-lettering.';
COMMENT ON COLUMN public.dead_letter_notifications.recipient         IS 'Delivery target – denormalised for permanence.';
COMMENT ON COLUMN public.dead_letter_notifications.recipient_id      IS 'Internal user/customer ID – denormalised for permanence.';
COMMENT ON COLUMN public.dead_letter_notifications.notification_type IS 'Business event type label at time of failure.';
COMMENT ON COLUMN public.dead_letter_notifications.title             IS 'Notification title at time of failure.';
COMMENT ON COLUMN public.dead_letter_notifications.body              IS 'Notification body at time of failure.';
COMMENT ON COLUMN public.dead_letter_notifications.channel           IS 'Delivery channel that failed.';
COMMENT ON COLUMN public.dead_letter_notifications.priority          IS 'Priority at time of failure.';
COMMENT ON COLUMN public.dead_letter_notifications.reason            IS 'Classification: max_retries_exceeded | invalid_token | malformed_payload | provider_rejected | etc.';
COMMENT ON COLUMN public.dead_letter_notifications.reason_description IS 'Human-readable failure description.';
COMMENT ON COLUMN public.dead_letter_notifications.retry_count       IS 'Total delivery attempts made before dead-lettering.';
COMMENT ON COLUMN public.dead_letter_notifications.last_error        IS 'Last error message from the queue runner or provider.';
COMMENT ON COLUMN public.dead_letter_notifications.stack_trace       IS 'Stack trace or debug detail from the queue runner for root-cause analysis.';
COMMENT ON COLUMN public.dead_letter_notifications.resolution        IS 'Ops resolution state: unresolved | manually_requeued | discarded | resolved_externally.';
COMMENT ON COLUMN public.dead_letter_notifications.resolved_by       IS 'Admin user ID who resolved this dead letter.';
COMMENT ON COLUMN public.dead_letter_notifications.resolved_at       IS 'Resolution timestamp – auto-set by trigger.';
COMMENT ON COLUMN public.dead_letter_notifications.resolution_notes  IS 'Ops team notes on resolution action taken.';
COMMENT ON COLUMN public.dead_letter_notifications.requeue_id        IS 'Soft FK to notification_queue.id of the re-queued item.';
COMMENT ON COLUMN public.dead_letter_notifications.created_at        IS 'Dead-lettering timestamp in UTC.';
COMMENT ON COLUMN public.dead_letter_notifications.updated_at        IS 'Last modification timestamp in UTC – auto-managed by trigger.';
