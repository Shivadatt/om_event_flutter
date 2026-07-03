-- =============================================================================
-- Migration: 20260703000005_create_notification_preferences.sql
-- Table    : notification_preferences
-- Purpose  : Per-user notification delivery preferences including:
--            - Channel opt-in/opt-out (push, email, whatsapp)
--            - DND (Do Not Disturb) quiet hours
--            - Event-type level granular toggles
--            - Frequency capping settings
--            Read by the queue runner before dispatching any notification.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Table: notification_preferences
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_preferences (
  id                      UUID        NOT NULL DEFAULT gen_random_uuid(),

  -- One preferences row per user.
  user_id                 TEXT        NOT NULL,
  user_role               TEXT        NOT NULL DEFAULT 'customer',

  -- â”€â”€ Global channel toggles â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  push_enabled            BOOLEAN     NOT NULL DEFAULT TRUE,
  email_enabled           BOOLEAN     NOT NULL DEFAULT TRUE,
  whatsapp_enabled        BOOLEAN     NOT NULL DEFAULT TRUE,
  sms_enabled             BOOLEAN     NOT NULL DEFAULT FALSE,
  in_app_enabled          BOOLEAN     NOT NULL DEFAULT TRUE,

  -- â”€â”€ DND Quiet Hours â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  -- Stored as HH:MM strings for timezone-aware comparison in application code.
  dnd_enabled             BOOLEAN     NOT NULL DEFAULT FALSE,
  quiet_hours_start       TIME                 DEFAULT '22:00:00',  -- local time
  quiet_hours_end         TIME                 DEFAULT '07:00:00',  -- local time
  timezone                TEXT        NOT NULL DEFAULT 'Asia/Kolkata',

  -- â”€â”€ Event-type granular toggles (JSONB for extensibility) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  -- Example:
  -- {
  --   "Booking Confirmed":    { "push": true,  "email": true,  "whatsapp": true  },
  --   "Payment Approved":     { "push": true,  "email": true,  "whatsapp": true  },
  --   "Quotation Approved":   { "push": true,  "email": true,  "whatsapp": false },
  --   "Event Day Reminder":   { "push": true,  "email": false, "whatsapp": true  },
  --   "Promotional Offers":   { "push": false, "email": true,  "whatsapp": false }
  -- }
  event_type_preferences  JSONB       NOT NULL DEFAULT '{}'::JSONB,

  -- â”€â”€ Frequency Capping â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  -- Maximum notifications per channel per day (0 = unlimited).
  max_push_per_day        SMALLINT    NOT NULL DEFAULT 0,
  max_email_per_day       SMALLINT    NOT NULL DEFAULT 0,
  max_whatsapp_per_day    SMALLINT    NOT NULL DEFAULT 5,

  -- â”€â”€ Unsubscribe tracking â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  -- Global unsubscribe (overrides all other settings).
  is_globally_unsubscribed BOOLEAN    NOT NULL DEFAULT FALSE,
  unsubscribed_at         TIMESTAMPTZ,
  unsubscribe_reason      TEXT,

  -- Audit timestamps
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- -------------------------------------------------------------------------
  -- Constraints
  -- -------------------------------------------------------------------------
  CONSTRAINT notification_preferences_pkey           PRIMARY KEY (id),
  CONSTRAINT notification_preferences_user_id_uq     UNIQUE (user_id),
  CONSTRAINT notification_preferences_user_id_chk    CHECK (char_length(trim(user_id)) > 0),
  CONSTRAINT notification_preferences_max_push_chk   CHECK (max_push_per_day >= 0),
  CONSTRAINT notification_preferences_max_email_chk  CHECK (max_email_per_day >= 0),
  CONSTRAINT notification_preferences_max_wa_chk     CHECK (max_whatsapp_per_day >= 0),
  CONSTRAINT notification_preferences_tz_chk         CHECK (char_length(trim(timezone)) > 0)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Primary lookup: preferences by user_id (most frequent query).
CREATE INDEX IF NOT EXISTS idx_npref_user_id
  ON public.notification_preferences (user_id);

-- DND filter: find users currently in quiet hours (queue runner uses this).
CREATE INDEX IF NOT EXISTS idx_npref_dnd_enabled
  ON public.notification_preferences (user_id)
  WHERE dnd_enabled = TRUE;

-- Globally unsubscribed users (suppress all deliveries).
CREATE INDEX IF NOT EXISTS idx_npref_globally_unsubscribed
  ON public.notification_preferences (user_id)
  WHERE is_globally_unsubscribed = TRUE;

-- Channel-specific suppression queries.
CREATE INDEX IF NOT EXISTS idx_npref_push_disabled
  ON public.notification_preferences (user_id)
  WHERE push_enabled = FALSE;

CREATE INDEX IF NOT EXISTS idx_npref_email_disabled
  ON public.notification_preferences (user_id)
  WHERE email_enabled = FALSE;

CREATE INDEX IF NOT EXISTS idx_npref_whatsapp_disabled
  ON public.notification_preferences (user_id)
  WHERE whatsapp_enabled = FALSE;

-- GIN index on event_type_preferences for deep JSONB queries.
CREATE INDEX IF NOT EXISTS idx_npref_event_type_gin
  ON public.notification_preferences USING GIN (event_type_preferences);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_notification_preferences_updated_at ON public.notification_preferences;
CREATE TRIGGER trg_notification_preferences_updated_at
  BEFORE UPDATE ON public.notification_preferences
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Trigger: set unsubscribed_at on global unsubscribe
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_set_unsubscribed_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_globally_unsubscribed = TRUE AND OLD.is_globally_unsubscribed = FALSE THEN
    NEW.unsubscribed_at = NOW();
  END IF;
  IF NEW.is_globally_unsubscribed = FALSE AND OLD.is_globally_unsubscribed = TRUE THEN
    NEW.unsubscribed_at = NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notification_preferences_unsubscribe ON public.notification_preferences;
CREATE TRIGGER trg_notification_preferences_unsubscribe
  BEFORE UPDATE ON public.notification_preferences
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_unsubscribed_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

-- Users can manage only their own preferences.
CREATE POLICY "npref_owner_policy"
  ON public.notification_preferences FOR ALL
  USING (public.is_firebase_admin() OR user_id = public.firebase_uid())
  WITH CHECK (public.is_firebase_admin() OR user_id = public.firebase_uid());

-- Service role has full access (queue runner reads preferences).
CREATE POLICY "npref_service_role_policy"
  ON public.notification_preferences FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
COMMENT ON TABLE  public.notification_preferences IS 'Per-user notification delivery preferences: channel toggles, DND quiet hours, event-type granular control, frequency caps, and global unsubscribe.';
COMMENT ON COLUMN public.notification_preferences.id                       IS 'UUID primary key.';
COMMENT ON COLUMN public.notification_preferences.user_id                  IS 'Internal user identifier â€“ one row per user.';
COMMENT ON COLUMN public.notification_preferences.user_role                IS 'User role (admin | customer | staff | coordinator).';
COMMENT ON COLUMN public.notification_preferences.push_enabled             IS 'Global push notification opt-in toggle.';
COMMENT ON COLUMN public.notification_preferences.email_enabled            IS 'Global email notification opt-in toggle.';
COMMENT ON COLUMN public.notification_preferences.whatsapp_enabled         IS 'Global WhatsApp notification opt-in toggle.';
COMMENT ON COLUMN public.notification_preferences.sms_enabled              IS 'Global SMS notification opt-in toggle.';
COMMENT ON COLUMN public.notification_preferences.in_app_enabled           IS 'Global in-app notification opt-in toggle.';
COMMENT ON COLUMN public.notification_preferences.dnd_enabled              IS 'TRUE = enforce quiet hours; non-critical notifications are paused.';
COMMENT ON COLUMN public.notification_preferences.quiet_hours_start        IS 'DND start time in local timezone (HH:MM:SS). Default 22:00.';
COMMENT ON COLUMN public.notification_preferences.quiet_hours_end          IS 'DND end time in local timezone (HH:MM:SS). Default 07:00.';
COMMENT ON COLUMN public.notification_preferences.timezone                 IS 'IANA timezone for DND and frequency cap calculations.';
COMMENT ON COLUMN public.notification_preferences.event_type_preferences   IS 'Granular per-event-type, per-channel toggle map (see table comment).';
COMMENT ON COLUMN public.notification_preferences.max_push_per_day         IS 'Max push notifications per day. 0 = unlimited.';
COMMENT ON COLUMN public.notification_preferences.max_email_per_day        IS 'Max email notifications per day. 0 = unlimited.';
COMMENT ON COLUMN public.notification_preferences.max_whatsapp_per_day     IS 'Max WhatsApp messages per day. 0 = unlimited.';
COMMENT ON COLUMN public.notification_preferences.is_globally_unsubscribed IS 'TRUE = suppress ALL notifications regardless of other settings.';
COMMENT ON COLUMN public.notification_preferences.unsubscribed_at          IS 'Timestamp of global unsubscribe â€“ auto-set by trigger.';
COMMENT ON COLUMN public.notification_preferences.unsubscribe_reason       IS 'Optional reason provided by user on global unsubscribe.';
COMMENT ON COLUMN public.notification_preferences.created_at               IS 'Row creation timestamp in UTC.';
COMMENT ON COLUMN public.notification_preferences.updated_at               IS 'Last modification timestamp in UTC â€“ auto-managed by trigger.';
