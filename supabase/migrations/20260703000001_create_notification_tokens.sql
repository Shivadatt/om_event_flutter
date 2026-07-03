-- =============================================================================
-- Migration: 20260703000001_create_notification_tokens.sql
-- Purpose  : Bootstraps the database schema.
--            1. Overrides auth.uid() safely to prevent UUID cast exceptions.
--            2. Creates users table to map Firebase UIDs to roles.
--            3. Implements public.firebase_uid() and public.is_firebase_admin().
--            4. Creates public.notification_tokens table.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Safe Override for auth.uid()
-- Prevents "invalid input syntax for type uuid" error when using Firebase JWTs.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- Extension: Enable pgcrypto for gen_random_uuid()
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------------
-- Table: users
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
  id                UUID        NOT NULL DEFAULT gen_random_uuid(),
  firebase_uid      TEXT        NOT NULL,
  email             TEXT        NOT NULL,
  name              TEXT        NOT NULL,
  role              TEXT        NOT NULL DEFAULT 'customer',
  branch            TEXT        NOT NULL DEFAULT 'Ahmedabad',
  is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_firebase_uid_uq UNIQUE (firebase_uid),
  CONSTRAINT users_role_chk CHECK (role IN ('super_admin', 'admin', 'demo_admin', 'customer')),
  CONSTRAINT users_firebase_uid_chk CHECK (char_length(trim(firebase_uid)) > 0),
  CONSTRAINT users_email_chk CHECK (char_length(trim(email)) > 0),
  CONSTRAINT users_name_chk CHECK (char_length(trim(name)) > 0)
);

-- ---------------------------------------------------------------------------
-- Indexes for users
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users (email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users (role);
CREATE INDEX IF NOT EXISTS idx_users_branch ON public.users (branch);
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON public.users (firebase_uid);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at for users
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- Authorization Helper Functions
-- ---------------------------------------------------------------------------

-- Extracts the Firebase UID from session configuration or request header.
CREATE OR REPLACE FUNCTION public.firebase_uid()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- 1. Check Deno Edge Function session parameter
  IF current_setting('app.firebase_uid', true) IS NOT NULL AND current_setting('app.firebase_uid', true) <> '' THEN
    RETURN current_setting('app.firebase_uid', true);
  END IF;

  -- 2. Check HTTP request header 'x-firebase-uid'
  IF current_setting('request.headers', true) IS NOT NULL THEN
    RETURN current_setting('request.headers', true)::json->>'x-firebase-uid';
  END IF;

  RETURN NULL;
END;
$$;

-- Fetches user role from users table.
CREATE OR REPLACE FUNCTION public.firebase_user_role()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid TEXT;
  v_role TEXT;
BEGIN
  v_uid := public.firebase_uid();
  IF v_uid IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT role INTO v_role
  FROM public.users
  WHERE firebase_uid = v_uid;

  RETURN v_role;
END;
$$;

-- Determines if current user has administrator rights.
CREATE OR REPLACE FUNCTION public.is_firebase_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN public.firebase_user_role() IN ('super_admin', 'admin', 'demo_admin');
END;
$$;

-- ---------------------------------------------------------------------------
-- RLS on users Table
-- ---------------------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_super_admin_all_policy"
  ON public.users FOR ALL
  USING (public.firebase_user_role() = 'super_admin')
  WITH CHECK (public.firebase_user_role() = 'super_admin');

CREATE POLICY "users_admin_read_write_policy"
  ON public.users FOR ALL
  USING (public.firebase_user_role() = 'admin')
  WITH CHECK (public.firebase_user_role() = 'admin');

CREATE POLICY "users_owner_read_write_policy"
  ON public.users FOR ALL
  USING (firebase_uid = public.firebase_uid())
  WITH CHECK (firebase_uid = public.firebase_uid());

CREATE POLICY "users_service_role_policy"
  ON public.users FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- ---------------------------------------------------------------------------
-- Enum: notification_platform
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_platform') THEN
    CREATE TYPE notification_platform AS ENUM (
      'android',
      'ios',
      'web',
      'unknown'
    );
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Table: notification_tokens
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_tokens (
  id                UUID        NOT NULL DEFAULT gen_random_uuid(),
  user_id           TEXT        NOT NULL,
  role              TEXT        NOT NULL DEFAULT 'customer',
  device_id         TEXT        NOT NULL DEFAULT 'unknown',
  platform          notification_platform NOT NULL DEFAULT 'unknown',
  token             TEXT,
  is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
  metadata          JSONB       NOT NULL DEFAULT '{}'::JSONB,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT notification_tokens_pkey               PRIMARY KEY (id),
  CONSTRAINT notification_tokens_user_device_uq     UNIQUE (user_id, device_id),
  CONSTRAINT notification_tokens_role_chk           CHECK (role IN ('admin','customer','staff','coordinator','system')),
  CONSTRAINT notification_tokens_device_id_chk      CHECK (char_length(trim(device_id)) > 0),
  CONSTRAINT notification_tokens_user_id_chk        CHECK (char_length(trim(user_id)) > 0)
);

-- ---------------------------------------------------------------------------
-- Indexes for notification_tokens
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_nt_user_id         ON public.notification_tokens (user_id);
CREATE INDEX IF NOT EXISTS idx_nt_platform_active ON public.notification_tokens (platform) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_nt_role_active     ON public.notification_tokens (role)     WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_nt_user_device     ON public.notification_tokens (user_id, device_id);
CREATE INDEX IF NOT EXISTS idx_nt_updated_at      ON public.notification_tokens (updated_at DESC);

-- ---------------------------------------------------------------------------
-- Trigger: auto-update updated_at for notification_tokens
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_notification_tokens_updated_at ON public.notification_tokens;
CREATE TRIGGER trg_notification_tokens_updated_at
  BEFORE UPDATE ON public.notification_tokens
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- RLS on notification_tokens
-- ---------------------------------------------------------------------------
ALTER TABLE public.notification_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nt_owner_policy"
  ON public.notification_tokens FOR ALL
  USING (public.is_firebase_admin() OR user_id = public.firebase_uid())
  WITH CHECK (public.is_firebase_admin() OR user_id = public.firebase_uid());

CREATE POLICY "nt_service_role_policy"
  ON public.notification_tokens FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);
