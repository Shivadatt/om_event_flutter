-- =============================================================================
-- Migration: 20260703000002_create_notification_queue.sql
-- Table    : notification_queue
-- Purpose  : Central outbox queue for all outbound notifications.
--            Acts as the single source of truth for all pending / in-flight /
--            retry delivery tasks across Push, Email, and WhatsApp channels.
--            The queue-runner (Edge Function / Cloud Function) polls this table,
--            processes items, then transitions their status.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enum: notification_channel
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_channel') THEN
    CREATE TYPE notification_channel AS ENUM (
      'push',
      'email',
      'whatsapp',
      'sms',
      'in_app'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Enum: notification_queue_status
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_queue_status') THEN
    CREATE TYPE notification_queue_status AS ENUM (
      'pending',
      'processing',
      'sent',
      'failed',
      'retry',
      'paused_dnd',
      'cancelled',
      'dead_lettered'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Enum: notification_priority
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_priority') THEN
    CREATE TYPE notification_priority AS ENUM (
      'low',
      'normal',
      'high',
      'critical'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: notification_queue
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_queue (
  id                  UUID                        NOT NULL DEFAULT gen_random_uuid(),

  -- Recipient information
  recipient           TEXT                        NOT NULL,          -- email / phone / FCM topic
  recipient_id        TEXT                        NOT NULL,          -- internal user/customer id
  recipient_role      TEXT                        NOT NULL DEFAULT 'customer',

  -- Notification content
  notification_type   TEXT                        NOT NULL,          -- 'Booking Confirmed', 'Payment Approved', etc.
  title               TEXT                        NOT NULL DEFAULT '',
  body                TEXT                        NOT NULL DEFAULT '',

  -- Delivery configuration
  channel             notification_channel        NOT NULL DEFAULT 'push',
  priority            notification_priority       NOT NULL DEFAULT 'normal',

  -- Processing state
  status              notification_queue_status   NOT NULL DEFAULT 'pending',
  retry_count         SMALLINT                    NOT NULL DEFAULT 0,
  max_retries         SMALLINT                    NOT NULL DEFAULT 5,
  error_message       TEXT                        NOT NULL DEFAULT '',

  -- Scheduling: NULL = dispatch immediately
  scheduled_at        TIMESTAMPTZ,

  -- JSONB payload for channel-specific data:
  --   push   : { fcm_token, android_config, apns_config, web_push_config }
  --   email  : { from, cc, bcc, reply_to, html_content, attachments[] }
  --   whatsapp: { template_name, template_language, components[], phone_number_id }
  payload             JSONB                       NOT NULL DEFAULT '{}'::JSONB,

  -- Template variable substitutions used by the runner at dispatch time.
  variables           JSONB                       NOT NULL DEFAULT '{}'::JSONB,

  -- A/B experiment tracking
  ab_variant          TEXT,

  -- Optional link back to a template record
  template_id         UUID,

  -- Idempotency key to prevent duplicate deliveries.
  idempotency_key     TEXT,

  -- Audit timestamps
  created_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
  processed_at        TIMESTAMPTZ,

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT notification_queue_pkey                PRIMARY KEY (id),
  CONSTRAINT notification_queue_idempotency_uq      UNIQUE (idempotency_key),
  CONSTRAINT notification_queue_retry_count_chk     CHECK (retry_count >= 0),
  CONSTRAINT notification_queue_max_retries_chk     CHECK (max_retries >= 0 AND max_retries <= 20),
  CONSTRAINT notification_queue_recipient_chk       CHECK (char_length(trim(recipient)) > 0),
  CONSTRAINT notification_queue_recipient_id_chk    CHECK (char_length(trim(recipient_id)) > 0)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Queue runner primary polling index: pending items ordered by creation.
CREATE INDEX IF NOT EXISTS idx_nq_status_created
  ON public.notification_queue (status, created_at ASC)
  WHERE status IN ('pending', 'retry');

-- DND resume polling.
CREATE INDEX IF NOT EXISTS idx_nq_paused_dnd
  ON public.notification_queue (status, updated_at ASC)
  WHERE status = 'paused_dnd';

-- Scheduled dispatch index.
CREATE INDEX IF NOT EXISTS idx_nq_scheduled_at
  ON public.notification_queue (scheduled_at ASC)
  WHERE status = 'pending' AND scheduled_at IS NOT NULL;

-- Recipient query (admin dashboard / audit).
CREATE INDEX IF NOT EXISTS idx_nq_recipient_id
  ON public.notification_queue (recipient_id);

-- Channel-based monitoring.
CREATE INDEX IF NOT EXISTS idx_nq_channel_status
  ON public.notification_queue (channel, status);

-- Priority dispatch (CRITICAL first).
CREATE INDEX IF NOT EXISTS idx_nq_priority_status
  ON public.notification_queue (priority DESC, status, created_at ASC)
  WHERE status IN ('pending', 'retry');

-- Template linkage.
CREATE INDEX IF NOT EXISTS idx_nq_template_id
  ON public.notification_queue (template_id)
  WHERE template_id IS NOT NULL;

-- GIN index on payload for deep JSONB queries.
CREATE INDEX IF NOT EXISTS idx_nq_payload_gin
  ON public.notification_queue USING GIN (payload);

-- GIN index on variables for template variable lookup.
CREATE INDEX IF NOT EXISTS idx_nq_variables_gin
  ON public.notification_queue USING GIN (variables);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_notification_queue_updated_at ON public.notification_queue;
CREATE TRIGGER trg_notification_queue_updated_at
  BEFORE UPDATE ON public.notification_queue
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.notification_queue ENABLE ROW LEVEL SECURITY;

-- Authenticated users can view their own queued notifications.
CREATE POLICY "nq_owner_read_policy"
  ON public.notification_queue FOR ALL
  USING (public.is_firebase_admin() OR recipient_id = public.firebase_uid())
  WITH CHECK (public.is_firebase_admin() OR recipient_id = public.firebase_uid());

-- Service role (Edge Functions / Cloud Functions) has full access.
CREATE POLICY "nq_service_role_policy"
  ON public.notification_queue FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.notification_queue IS 'Central outbox queue for all outbound notification delivery tasks (push, email, whatsapp). Polled by Edge Functions / queue runners.';
COMMENT ON COLUMN public.notification_queue.id               IS 'UUID primary key.';
COMMENT ON COLUMN public.notification_queue.recipient        IS 'Delivery target: email address, phone number, FCM topic, or user ID.';
COMMENT ON COLUMN public.notification_queue.recipient_id     IS 'Internal application user/customer identifier.';
COMMENT ON COLUMN public.notification_queue.recipient_role   IS 'Role of recipient: admin | customer | staff | coordinator.';
COMMENT ON COLUMN public.notification_queue.notification_type IS 'Business event type label (e.g. Booking Confirmed, Payment Approved).';
COMMENT ON COLUMN public.notification_queue.title            IS 'Notification title â€“ may contain {{variable}} placeholders.';
COMMENT ON COLUMN public.notification_queue.body             IS 'Notification body â€“ may contain {{variable}} placeholders.';
COMMENT ON COLUMN public.notification_queue.channel          IS 'Delivery channel: push | email | whatsapp | sms | in_app.';
COMMENT ON COLUMN public.notification_queue.priority         IS 'Dispatch priority: low | normal | high | critical. High/critical bypass DND.';
COMMENT ON COLUMN public.notification_queue.status           IS 'Lifecycle state: pending â†’ processing â†’ sent | failed | retry | paused_dnd | dead_lettered.';
COMMENT ON COLUMN public.notification_queue.retry_count      IS 'Number of delivery attempts made so far.';
COMMENT ON COLUMN public.notification_queue.max_retries      IS 'Maximum delivery attempts before dead-lettering.';
COMMENT ON COLUMN public.notification_queue.error_message    IS 'Last error description from the queue runner.';
COMMENT ON COLUMN public.notification_queue.scheduled_at     IS 'If set, the queue runner will not dispatch before this timestamp (scheduled notifications).';
COMMENT ON COLUMN public.notification_queue.payload          IS 'Channel-specific delivery payload: FCM config, email headers, WhatsApp template components, etc.';
COMMENT ON COLUMN public.notification_queue.variables        IS 'Template variable map used for {{placeholder}} substitution at dispatch time.';
COMMENT ON COLUMN public.notification_queue.ab_variant       IS 'A/B test variant label (e.g. Variant A, Variant B) assigned by the runner.';
COMMENT ON COLUMN public.notification_queue.template_id      IS 'Optional FK to notification_templates.id for template-based dispatch.';
COMMENT ON COLUMN public.notification_queue.idempotency_key  IS 'Unique key to prevent duplicate queue entries for the same business event.';
COMMENT ON COLUMN public.notification_queue.created_at       IS 'Queue entry creation timestamp in UTC.';
COMMENT ON COLUMN public.notification_queue.updated_at       IS 'Last state transition timestamp in UTC â€“ auto-managed by trigger.';
COMMENT ON COLUMN public.notification_queue.processed_at     IS 'Timestamp when the item transitioned out of processing state.';
