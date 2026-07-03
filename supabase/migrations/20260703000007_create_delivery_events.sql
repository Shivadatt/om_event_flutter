-- =============================================================================
-- Migration: 20260703000007_create_delivery_events.sql
-- Table    : delivery_events
-- Purpose  : Immutable stream of provider webhook callbacks.
--            Every status transition from the notification provider (FCM,
--            Resend, WhatsApp Cloud API) is appended here as a new row.
--            The queue runner's _simulateWebhookCallback and real provider
--            webhooks both write to this table.
--            Analytical queries aggregate this table to compute open rates,
--            click-through rates, delivery rates, and read receipts.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enum: delivery_event_type
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'delivery_event_type') THEN
    CREATE TYPE delivery_event_type AS ENUM (
      'queued',
      'sent',
      'delivered',
      'opened',
      'clicked',
      'read',
      'bounced',
      'failed',
      'unsubscribed',
      'spam',
      'deferred',
      'rejected'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: delivery_events
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.delivery_events (
  id                  UUID                    NOT NULL DEFAULT gen_random_uuid(),

  -- Back-reference to the notification log entry this event belongs to.
  log_id              UUID                    NOT NULL,

  -- Back-reference to the originating queue item (optional, for tracing).
  queue_id            UUID,

  -- The event type that occurred.
  event_type          delivery_event_type     NOT NULL,

  -- Provider that generated this event (e.g. 'fcm', 'resend', 'whatsapp', 'simulator').
  provider            TEXT                    NOT NULL DEFAULT 'unknown',

  -- Channel at time of event.
  channel             notification_channel    NOT NULL DEFAULT 'push',

  -- Provider-generated event timestamp (may differ from received_at).
  event_timestamp     TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

  -- When this record was inserted into the database.
  received_at         TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

  -- Raw webhook payload from the provider for full auditability.
  raw_payload         JSONB                   NOT NULL DEFAULT '{}'::JSONB,

  -- Parsed detail fields extracted from raw_payload for quick querying:
  --   { user_agent, ip_address, link_url, device_type, error_code, error_description }
  details             JSONB                   NOT NULL DEFAULT '{}'::JSONB,

  -- Provider's message/event ID for deduplication.
  provider_event_id   TEXT,

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT delivery_events_pkey                  PRIMARY KEY (id),

  -- Prevent duplicate webhook replays from the same provider.
  CONSTRAINT delivery_events_provider_event_id_uq  UNIQUE (provider_event_id),

  CONSTRAINT delivery_events_log_id_notnull_chk    CHECK (log_id IS NOT NULL),
  CONSTRAINT delivery_events_provider_chk          CHECK (char_length(trim(provider)) > 0)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Primary analytics query: all events for a log entry.
CREATE INDEX IF NOT EXISTS idx_de_log_id
  ON public.delivery_events (log_id, event_timestamp DESC);

-- Queue tracing.
CREATE INDEX IF NOT EXISTS idx_de_queue_id
  ON public.delivery_events (queue_id)
  WHERE queue_id IS NOT NULL;

-- Event-type analytics (open rate, click rate computation).
CREATE INDEX IF NOT EXISTS idx_de_event_type
  ON public.delivery_events (event_type, received_at DESC);

-- Channel-specific analytics.
CREATE INDEX IF NOT EXISTS idx_de_channel_event
  ON public.delivery_events (channel, event_type, received_at DESC);

-- Provider-level monitoring.
CREATE INDEX IF NOT EXISTS idx_de_provider_event
  ON public.delivery_events (provider, event_type, received_at DESC);

-- Time-series analytics.
CREATE INDEX IF NOT EXISTS idx_de_received_at
  ON public.delivery_events (received_at DESC);

-- GIN on raw_payload for deep webhook debugging.
CREATE INDEX IF NOT EXISTS idx_de_raw_payload_gin
  ON public.delivery_events USING GIN (raw_payload);

-- GIN on details for filtered analytics.
CREATE INDEX IF NOT EXISTS idx_de_details_gin
  ON public.delivery_events USING GIN (details);

-- ---------------------------------------------------------------------------
-- Note: delivery_events is APPEND-ONLY (immutable).
-- No UPDATE trigger is required. Rows are never modified after insert.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.delivery_events ENABLE ROW LEVEL SECURITY;

-- Only service role can write delivery events (webhooks come from backend).
CREATE POLICY "de_service_role_policy"
  ON public.delivery_events FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- Authenticated users cannot directly access delivery events (analytics via views).
-- Admin read access is managed through Supabase RPC / views.

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.delivery_events IS 'Append-only stream of provider webhook delivery events. Each row records one status transition (sent, delivered, opened, clicked, bounced, etc.) for a notification.';
COMMENT ON COLUMN public.delivery_events.id                IS 'UUID primary key.';
COMMENT ON COLUMN public.delivery_events.log_id            IS 'FK to notification_logs.id – the parent notification this event belongs to.';
COMMENT ON COLUMN public.delivery_events.queue_id          IS 'Soft FK to notification_queue.id for end-to-end tracing.';
COMMENT ON COLUMN public.delivery_events.event_type        IS 'Event type: queued | sent | delivered | opened | clicked | read | bounced | failed | unsubscribed | spam | deferred | rejected.';
COMMENT ON COLUMN public.delivery_events.provider          IS 'Source provider: fcm | resend | whatsapp | twilio | simulator.';
COMMENT ON COLUMN public.delivery_events.channel           IS 'Notification channel: push | email | whatsapp | sms | in_app.';
COMMENT ON COLUMN public.delivery_events.event_timestamp   IS 'Provider-reported event timestamp (may be backdated from webhook batch delivery).';
COMMENT ON COLUMN public.delivery_events.received_at       IS 'Database insertion timestamp.';
COMMENT ON COLUMN public.delivery_events.raw_payload       IS 'Complete raw webhook payload from the provider for full audit trail.';
COMMENT ON COLUMN public.delivery_events.details           IS 'Extracted fields: user_agent, ip_address, link_url, device_type, error_code.';
COMMENT ON COLUMN public.delivery_events.provider_event_id IS 'Provider-assigned event/message ID used for idempotent webhook processing.';
