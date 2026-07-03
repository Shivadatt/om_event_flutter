-- =============================================================================
-- Migration: 20260703000003_create_notification_logs.sql
-- Table    : notification_logs
-- Purpose  : Immutable audit ledger for every notification dispatch attempt.
--            Records are written by the queue runner upon each send attempt
--            (success or failure).  Delivery event webhooks later update the
--            status field via the delivery_events table.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Table: notification_logs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_logs (
  id                  UUID                        NOT NULL DEFAULT gen_random_uuid(),

  -- Back-reference to the originating queue item (soft FK â€“ no CASCADE,
  -- as queue items may be deleted after processing).
  queue_id            UUID,

  -- Recipient information (denormalised for log completeness).
  recipient_id        TEXT                        NOT NULL,
  recipient           TEXT                        NOT NULL DEFAULT '',
  recipient_role      TEXT                        NOT NULL DEFAULT 'customer',

  -- Content snapshot at the moment of dispatch (post variable substitution).
  notification_type   TEXT                        NOT NULL,
  title               TEXT                        NOT NULL DEFAULT '',
  body                TEXT                        NOT NULL DEFAULT '',

  -- Delivery configuration snapshot.
  channel             notification_channel        NOT NULL DEFAULT 'push',
  priority            notification_priority       NOT NULL DEFAULT 'normal',

  -- Final delivery outcome.
  -- 'sent' â†’ provider accepted; webhook updates to delivered / opened / clicked.
  status              TEXT                        NOT NULL DEFAULT 'sent',

  -- External message ID returned by FCM / Resend / WhatsApp Cloud API.
  external_id         TEXT,

  -- A/B variant assigned at dispatch.
  ab_variant          TEXT,

  -- Full provider API response payload for debugging.
  provider_response   JSONB                       NOT NULL DEFAULT '{}'::JSONB,

  -- Error detail if delivery failed.
  error_message       TEXT                        NOT NULL DEFAULT '',

  -- Retry number this log entry corresponds to (0 = first attempt).
  attempt_number      SMALLINT                    NOT NULL DEFAULT 0,

  -- Optional back-reference to template used.
  template_id         UUID,

  -- Audit timestamps
  sent_at             TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ                 NOT NULL DEFAULT NOW(),

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT notification_logs_pkey                  PRIMARY KEY (id),
  CONSTRAINT notification_logs_recipient_id_chk      CHECK (char_length(trim(recipient_id)) > 0),
  CONSTRAINT notification_logs_attempt_number_chk    CHECK (attempt_number >= 0),
  CONSTRAINT notification_logs_status_chk            CHECK (
    status IN ('sent','delivered','failed','opened','clicked','read','bounced','unsubscribed','spam')
  )
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Most common query: all logs for a specific recipient.
CREATE INDEX IF NOT EXISTS idx_nl_recipient_id
  ON public.notification_logs (recipient_id, sent_at DESC);

-- Status-based monitoring dashboard.
CREATE INDEX IF NOT EXISTS idx_nl_status
  ON public.notification_logs (status, sent_at DESC);

-- Channel analytics (email open rate, push CTR, WhatsApp read rate).
CREATE INDEX IF NOT EXISTS idx_nl_channel_status
  ON public.notification_logs (channel, status, sent_at DESC);

-- Link from queue to log.
CREATE INDEX IF NOT EXISTS idx_nl_queue_id
  ON public.notification_logs (queue_id)
  WHERE queue_id IS NOT NULL;

-- External ID lookup for webhook reconciliation.
CREATE INDEX IF NOT EXISTS idx_nl_external_id
  ON public.notification_logs (external_id)
  WHERE external_id IS NOT NULL;

-- Template performance analytics.
CREATE INDEX IF NOT EXISTS idx_nl_template_id
  ON public.notification_logs (template_id)
  WHERE template_id IS NOT NULL;

-- Time-range queries for analytics / reporting.
CREATE INDEX IF NOT EXISTS idx_nl_sent_at
  ON public.notification_logs (sent_at DESC);

-- GIN index on provider_response for deep debugging queries.
CREATE INDEX IF NOT EXISTS idx_nl_provider_response_gin
  ON public.notification_logs USING GIN (provider_response);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_notification_logs_updated_at ON public.notification_logs;
CREATE TRIGGER trg_notification_logs_updated_at
  BEFORE UPDATE ON public.notification_logs
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.notification_logs ENABLE ROW LEVEL SECURITY;

-- Recipients can see their own delivery history.
CREATE POLICY "nl_owner_read_policy"
  ON public.notification_logs FOR ALL
  USING (public.is_firebase_admin() OR recipient_id = public.firebase_uid())
  WITH CHECK (public.is_firebase_admin() OR recipient_id = public.firebase_uid());

-- Service role has full access.
CREATE POLICY "nl_service_role_policy"
  ON public.notification_logs FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.notification_logs IS 'Immutable audit ledger of every notification send attempt. Status updated by delivery webhook events.';
COMMENT ON COLUMN public.notification_logs.id                IS 'UUID primary key.';
COMMENT ON COLUMN public.notification_logs.queue_id          IS 'Soft FK to notification_queue.id (no cascade â€“ queue rows may be purged).';
COMMENT ON COLUMN public.notification_logs.recipient_id      IS 'Internal user/customer identifier â€“ denormalised for log permanence.';
COMMENT ON COLUMN public.notification_logs.recipient         IS 'Delivery target (email, phone, device) â€“ denormalised for log permanence.';
COMMENT ON COLUMN public.notification_logs.notification_type IS 'Business event type label at time of dispatch.';
COMMENT ON COLUMN public.notification_logs.title             IS 'Rendered notification title (post variable substitution).';
COMMENT ON COLUMN public.notification_logs.body              IS 'Rendered notification body (post variable substitution).';
COMMENT ON COLUMN public.notification_logs.channel           IS 'Delivery channel used for this attempt.';
COMMENT ON COLUMN public.notification_logs.priority          IS 'Priority at time of dispatch.';
COMMENT ON COLUMN public.notification_logs.status            IS 'Delivery lifecycle: sent â†’ delivered â†’ opened | clicked | read | bounced.';
COMMENT ON COLUMN public.notification_logs.external_id       IS 'Message ID from provider (FCM message_id, Resend email ID, WhatsApp message SID).';
COMMENT ON COLUMN public.notification_logs.ab_variant        IS 'A/B test variant label for analytics.';
COMMENT ON COLUMN public.notification_logs.provider_response IS 'Raw JSON response from the notification provider API.';
COMMENT ON COLUMN public.notification_logs.error_message     IS 'Provider error detail on failed delivery.';
COMMENT ON COLUMN public.notification_logs.attempt_number    IS 'Which retry attempt this log entry records (0 = first attempt).';
COMMENT ON COLUMN public.notification_logs.template_id       IS 'Soft FK to notification_templates.id if template was used.';
COMMENT ON COLUMN public.notification_logs.sent_at           IS 'Dispatch timestamp in UTC.';
COMMENT ON COLUMN public.notification_logs.updated_at        IS 'Last status update timestamp in UTC.';
