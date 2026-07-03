-- =============================================================================
-- Migration: 20260703000004_create_notification_templates.sql
-- Table    : notification_templates
-- Purpose  : Reusable, versioned message templates for every channel and event
--            type.  Templates support Mustache-style {{variable}} placeholders
--            which the queue runner resolves at dispatch time.
--            WhatsApp templates store the approved template name + components
--            in the payload JSONB column.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enum: template_status
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'template_status') THEN
    CREATE TYPE template_status AS ENUM (
      'draft',
      'active',
      'inactive',
      'archived'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: notification_templates
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_templates (
  id                  UUID            NOT NULL DEFAULT gen_random_uuid(),

  -- Unique machine-readable key referenced by business logic.
  -- Examples: 'booking_confirmed_push', 'payment_approved_email', 'quotation_approved_whatsapp'
  template_key        TEXT            NOT NULL,

  -- Human-readable name for the admin UI.
  name                TEXT            NOT NULL,

  -- Description for admin reference.
  description         TEXT            NOT NULL DEFAULT '',

  -- Target channel this template is designed for.
  channel             notification_channel NOT NULL,

  -- Notification category / event type.
  event_type          TEXT            NOT NULL,

  -- Subject line for email; ignored for push/whatsapp.
  subject             TEXT            NOT NULL DEFAULT '',

  -- Title template with {{variable}} placeholders.
  title_template      TEXT            NOT NULL DEFAULT '',

  -- Body template with {{variable}} placeholders.
  body_template       TEXT            NOT NULL DEFAULT '',

  -- Channel-specific configuration:
  --   email    : { from_name, reply_to, cc, bcc, html_template_path }
  --   whatsapp : { template_name, template_language, header_type, components[] }
  --   push     : { icon, image_url, click_action, android_channel_id, badge }
  payload             JSONB           NOT NULL DEFAULT '{}'::JSONB,

  -- Variable schema: documents expected placeholders for validation.
  -- Example: { "customer_name": "string", "booking_number": "string", "amount": "number" }
  variable_schema     JSONB           NOT NULL DEFAULT '{}'::JSONB,

  -- Template lifecycle state.
  status              template_status NOT NULL DEFAULT 'draft',

  -- Monotonically increasing version number for change tracking.
  version             SMALLINT        NOT NULL DEFAULT 1,

  -- Locale / language code (BCP-47).  NULL = global default.
  locale              TEXT                     DEFAULT 'en',

  -- Tag array for filtering (e.g. ARRAY['customer','booking','push']).
  tags                TEXT[]          NOT NULL DEFAULT ARRAY[]::TEXT[],

  -- Audit trail
  created_by          TEXT,
  updated_by          TEXT,
  created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT notification_templates_pkey               PRIMARY KEY (id),

  -- template_key + channel + locale combination must be unique per active version.
  CONSTRAINT notification_templates_key_channel_locale_uq UNIQUE (template_key, channel, locale),

  CONSTRAINT notification_templates_key_nonempty_chk   CHECK (char_length(trim(template_key)) > 0),
  CONSTRAINT notification_templates_name_nonempty_chk  CHECK (char_length(trim(name)) > 0),
  CONSTRAINT notification_templates_version_chk        CHECK (version >= 1)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Primary lookup: resolve template by key + channel at dispatch time.
CREATE INDEX IF NOT EXISTS idx_ntpl_key_channel
  ON public.notification_templates (template_key, channel)
  WHERE status = 'active';

-- Event-type filtering for admin UI.
CREATE INDEX IF NOT EXISTS idx_ntpl_event_type
  ON public.notification_templates (event_type, status);

-- Channel-based template listing.
CREATE INDEX IF NOT EXISTS idx_ntpl_channel_status
  ON public.notification_templates (channel, status);

-- Tag-based search using GIN.
CREATE INDEX IF NOT EXISTS idx_ntpl_tags_gin
  ON public.notification_templates USING GIN (tags);

-- Payload deep search.
CREATE INDEX IF NOT EXISTS idx_ntpl_payload_gin
  ON public.notification_templates USING GIN (payload);

-- Recency sort for admin UI.
CREATE INDEX IF NOT EXISTS idx_ntpl_updated_at
  ON public.notification_templates (updated_at DESC);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_notification_templates_updated_at ON public.notification_templates;
CREATE TRIGGER trg_notification_templates_updated_at
  BEFORE UPDATE ON public.notification_templates
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Trigger: auto-increment version on content change
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_increment_template_version()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF (NEW.title_template <> OLD.title_template
      OR NEW.body_template <> OLD.body_template
      OR NEW.subject       <> OLD.subject
      OR NEW.payload::TEXT <> OLD.payload::TEXT) THEN
    NEW.version = OLD.version + 1;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notification_templates_version ON public.notification_templates;
CREATE TRIGGER trg_notification_templates_version
  BEFORE UPDATE ON public.notification_templates
  FOR EACH ROW EXECUTE FUNCTION public.fn_increment_template_version();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

-- Authenticated users may READ active templates (for client-side preview).
CREATE POLICY "ntpl_authenticated_read_policy"
  ON public.notification_templates FOR SELECT
  TO authenticated
  USING (status = 'active');

-- Service role has full CRUD access.
CREATE POLICY "ntpl_service_role_policy"
  ON public.notification_templates FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.notification_templates IS 'Reusable, versioned notification templates for push, email, and WhatsApp channels. Supports {{variable}} substitution.';
COMMENT ON COLUMN public.notification_templates.id              IS 'UUID primary key.';
COMMENT ON COLUMN public.notification_templates.template_key    IS 'Machine-readable unique key used by business logic to select this template (e.g. booking_confirmed_email).';
COMMENT ON COLUMN public.notification_templates.name            IS 'Human-readable name displayed in the admin template editor.';
COMMENT ON COLUMN public.notification_templates.description     IS 'Admin notes describing template purpose and usage context.';
COMMENT ON COLUMN public.notification_templates.channel         IS 'Target channel: push | email | whatsapp | sms | in_app.';
COMMENT ON COLUMN public.notification_templates.event_type      IS 'Business event category (e.g. Booking Confirmed, Payment Approved).';
COMMENT ON COLUMN public.notification_templates.subject         IS 'Email subject line (ignored for push/whatsapp). Supports {{variables}}.';
COMMENT ON COLUMN public.notification_templates.title_template  IS 'Notification title with {{variable}} placeholders.';
COMMENT ON COLUMN public.notification_templates.body_template   IS 'Notification body with {{variable}} placeholders.';
COMMENT ON COLUMN public.notification_templates.payload         IS 'Channel-specific config: email headers, WhatsApp template components, push icon/badge config.';
COMMENT ON COLUMN public.notification_templates.variable_schema IS 'JSON schema documenting expected template variables for validation.';
COMMENT ON COLUMN public.notification_templates.status          IS 'Template lifecycle: draft | active | inactive | archived.';
COMMENT ON COLUMN public.notification_templates.version         IS 'Auto-incremented on content changes for change tracking.';
COMMENT ON COLUMN public.notification_templates.locale          IS 'BCP-47 locale code (e.g. en, hi, gu). NULL = global default.';
COMMENT ON COLUMN public.notification_templates.tags            IS 'Tag array for UI filtering and grouping.';
COMMENT ON COLUMN public.notification_templates.created_by      IS 'Admin user ID who created this template.';
COMMENT ON COLUMN public.notification_templates.updated_by      IS 'Admin user ID who last updated this template.';
COMMENT ON COLUMN public.notification_templates.created_at      IS 'Creation timestamp in UTC.';
COMMENT ON COLUMN public.notification_templates.updated_at      IS 'Last modification timestamp in UTC – auto-managed by trigger.';
