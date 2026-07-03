-- =============================================================================
-- Migration: 20260703000006_create_scheduled_notifications.sql
-- Table    : scheduled_notifications
-- Purpose  : Future-dated notification schedule registry.
--            Records are created when a business event triggers a scheduled
--            reminder (e.g. 30-day, 7-day, 1-day event reminders).
--            A cron scheduler (Edge Function / pgcron / Cloud Scheduler) scans
--            this table every N minutes and moves due items into notification_queue.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enum: scheduled_notification_status
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'scheduled_notification_status') THEN
    CREATE TYPE scheduled_notification_status AS ENUM (
      'pending',    -- waiting to fire
      'queued',     -- promoted to notification_queue
      'sent',       -- queue processing completed
      'cancelled',  -- manually or programmatically cancelled
      'expired',    -- trigger_at passed but never fired
      'failed'      -- promotion to queue failed
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: scheduled_notifications
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.scheduled_notifications (
  id                  UUID                            NOT NULL DEFAULT gen_random_uuid(),

  -- Business context linkage (soft FKs).
  event_id            TEXT,                                    -- e.g. booking ID, lead ID
  event_type          TEXT                            NOT NULL, -- 'Booking Event Reminder', 'Follow-up', etc.

  -- Recipient information.
  recipient           TEXT                            NOT NULL,  -- email / phone
  recipient_id        TEXT                            NOT NULL,  -- internal user/customer ID

  -- Notification content (supports {{variable}} placeholders).
  title               TEXT                            NOT NULL DEFAULT '',
  body                TEXT                            NOT NULL DEFAULT '',

  -- Delivery channel.
  channel             notification_channel            NOT NULL DEFAULT 'email',
  priority            notification_priority           NOT NULL DEFAULT 'normal',

  -- WHEN to fire this notification (absolute UTC timestamp).
  trigger_at          TIMESTAMPTZ                     NOT NULL,

  -- Recurrence rule (NULL = one-shot).
  -- Stored as iCal RRULE string for flexibility, e.g.:
  --   'FREQ=WEEKLY;BYDAY=MO;COUNT=4'
  recurrence_rule     TEXT,

  -- Status lifecycle.
  status              scheduled_notification_status   NOT NULL DEFAULT 'pending',

  -- Reference to the queue item created when this schedule fires.
  queue_id            UUID,

  -- Template and variable substitution.
  template_id         UUID,
  variables           JSONB                           NOT NULL DEFAULT '{}'::JSONB,

  -- Additional scheduling metadata:
  --   { label: '30 Days Event Reminder', source: 'booking_trigger', booking_number: 'OM-001' }
  metadata            JSONB                           NOT NULL DEFAULT '{}'::JSONB,

  -- Audit trail.
  created_by          TEXT,
  created_at          TIMESTAMPTZ                     NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ                     NOT NULL DEFAULT NOW(),
  fired_at            TIMESTAMPTZ,
  cancelled_at        TIMESTAMPTZ,

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT scheduled_notifications_pkey             PRIMARY KEY (id),
  CONSTRAINT scheduled_notifications_recipient_chk    CHECK (char_length(trim(recipient)) > 0),
  CONSTRAINT scheduled_notifications_recipient_id_chk CHECK (char_length(trim(recipient_id)) > 0),
  CONSTRAINT scheduled_notifications_trigger_at_chk   CHECK (trigger_at > '2020-01-01'::TIMESTAMPTZ)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Primary cron scanner index: pending items due to fire.
CREATE INDEX IF NOT EXISTS idx_sn_trigger_pending
  ON public.scheduled_notifications (trigger_at ASC)
  WHERE status = 'pending';

-- Recipient query: all scheduled notifications for a user.
CREATE INDEX IF NOT EXISTS idx_sn_recipient_id
  ON public.scheduled_notifications (recipient_id, trigger_at ASC);

-- Business event linkage (cancel all reminders for a booking on cancellation).
CREATE INDEX IF NOT EXISTS idx_sn_event_id
  ON public.scheduled_notifications (event_id)
  WHERE event_id IS NOT NULL;

-- Channel-based scheduler queries.
CREATE INDEX IF NOT EXISTS idx_sn_channel_status
  ON public.scheduled_notifications (channel, status);

-- Template linkage.
CREATE INDEX IF NOT EXISTS idx_sn_template_id
  ON public.scheduled_notifications (template_id)
  WHERE template_id IS NOT NULL;

-- Queue ID linkage (trace from schedule to queue item).
CREATE INDEX IF NOT EXISTS idx_sn_queue_id
  ON public.scheduled_notifications (queue_id)
  WHERE queue_id IS NOT NULL;

-- GIN on metadata for flexible query.
CREATE INDEX IF NOT EXISTS idx_sn_metadata_gin
  ON public.scheduled_notifications USING GIN (metadata);

-- GIN on variables.
CREATE INDEX IF NOT EXISTS idx_sn_variables_gin
  ON public.scheduled_notifications USING GIN (variables);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_scheduled_notifications_updated_at ON public.scheduled_notifications;
CREATE TRIGGER trg_scheduled_notifications_updated_at
  BEFORE UPDATE ON public.scheduled_notifications
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Trigger: set fired_at when status transitions to queued/sent
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_set_scheduled_notification_timestamps()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status IN ('queued', 'sent') AND OLD.status = 'pending' AND NEW.fired_at IS NULL THEN
    NEW.fired_at = NOW();
  END IF;
  IF NEW.status = 'cancelled' AND OLD.status <> 'cancelled' AND NEW.cancelled_at IS NULL THEN
    NEW.cancelled_at = NOW();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_scheduled_notifications_timestamps ON public.scheduled_notifications;
CREATE TRIGGER trg_scheduled_notifications_timestamps
  BEFORE UPDATE ON public.scheduled_notifications
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_scheduled_notification_timestamps();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.scheduled_notifications ENABLE ROW LEVEL SECURITY;

-- Recipients can view their own scheduled notifications.
CREATE POLICY "sn_owner_read_policy"
  ON public.scheduled_notifications FOR ALL
  USING (public.is_firebase_admin() OR recipient_id = public.firebase_uid())
  WITH CHECK (public.is_firebase_admin() OR recipient_id = public.firebase_uid());

-- Service role has full access (cron scanner).
CREATE POLICY "sn_service_role_policy"
  ON public.scheduled_notifications FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.scheduled_notifications IS 'Future-dated notification schedule registry. Cron scanner promotes pending items to notification_queue at trigger_at.';
COMMENT ON COLUMN public.scheduled_notifications.id               IS 'UUID primary key.';
COMMENT ON COLUMN public.scheduled_notifications.event_id         IS 'Source business entity ID (booking_id, lead_id, etc.) â€“ used for bulk cancellation.';
COMMENT ON COLUMN public.scheduled_notifications.event_type       IS 'Business event type label (e.g. Booking Event Reminder, Follow-up Reminder).';
COMMENT ON COLUMN public.scheduled_notifications.recipient        IS 'Delivery target (email address, phone number).';
COMMENT ON COLUMN public.scheduled_notifications.recipient_id     IS 'Internal user/customer identifier.';
COMMENT ON COLUMN public.scheduled_notifications.title            IS 'Notification title â€“ supports {{variable}} placeholders.';
COMMENT ON COLUMN public.scheduled_notifications.body             IS 'Notification body â€“ supports {{variable}} placeholders.';
COMMENT ON COLUMN public.scheduled_notifications.channel          IS 'Delivery channel: push | email | whatsapp | sms | in_app.';
COMMENT ON COLUMN public.scheduled_notifications.priority         IS 'Dispatch priority: low | normal | high | critical.';
COMMENT ON COLUMN public.scheduled_notifications.trigger_at       IS 'UTC timestamp at which the cron scanner should promote this item to the queue.';
COMMENT ON COLUMN public.scheduled_notifications.recurrence_rule  IS 'Optional iCal RRULE for recurring notifications. NULL = one-shot.';
COMMENT ON COLUMN public.scheduled_notifications.status           IS 'Lifecycle: pending â†’ queued â†’ sent | cancelled | expired | failed.';
COMMENT ON COLUMN public.scheduled_notifications.queue_id         IS 'Soft FK to notification_queue.id created when this schedule fires.';
COMMENT ON COLUMN public.scheduled_notifications.template_id      IS 'Soft FK to notification_templates.id if template-based.';
COMMENT ON COLUMN public.scheduled_notifications.variables        IS 'Template variable map for {{placeholder}} substitution.';
COMMENT ON COLUMN public.scheduled_notifications.metadata         IS 'Extensible JSONB bag (label, source, booking_number, etc.).';
COMMENT ON COLUMN public.scheduled_notifications.created_by       IS 'User/system identifier that created this schedule.';
COMMENT ON COLUMN public.scheduled_notifications.created_at       IS 'Creation timestamp in UTC.';
COMMENT ON COLUMN public.scheduled_notifications.updated_at       IS 'Last modification timestamp in UTC â€“ auto-managed by trigger.';
COMMENT ON COLUMN public.scheduled_notifications.fired_at         IS 'Timestamp when cron scanner promoted this item to queue â€“ auto-set by trigger.';
COMMENT ON COLUMN public.scheduled_notifications.cancelled_at     IS 'Timestamp of cancellation â€“ auto-set by trigger.';
