-- =============================================================================
-- Migration: 20260703000012_fix_notification_rls_and_roles.sql
-- Purpose  : 1. Redefine firebase_uid() to use Postgrest GUC parameters natively
--               request.header.x-firebase-uid with a JSON fallback.
--            2. Update check constraint on notification_tokens.role to allow
--               super_admin and demo_admin roles.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

-- 1. Redefine firebase_uid() helper function
CREATE OR REPLACE FUNCTION public.firebase_uid()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid TEXT;
BEGIN
  -- 1. Check Deno Edge Function session parameter
  v_uid := current_setting('app.firebase_uid', true);
  IF v_uid IS NOT NULL AND v_uid <> '' THEN
    RETURN v_uid;
  END IF;

  -- 2. Check standard Postgrest header GUC parameter
  v_uid := current_setting('request.header.x-firebase-uid', true);
  IF v_uid IS NOT NULL AND v_uid <> '' THEN
    RETURN v_uid;
  END IF;

  -- 3. Check HTTP request header JSON fallback
  IF current_setting('request.headers', true) IS NOT NULL THEN
    BEGIN
      v_uid := current_setting('request.headers', true)::json->>'x-firebase-uid';
      IF v_uid IS NOT NULL AND v_uid <> '' THEN
        RETURN v_uid;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      -- Ignore JSON parsing errors
    END;
  END IF;

  RETURN NULL;
END;
$$;

-- 2. Update role check constraint on notification_tokens
ALTER TABLE public.notification_tokens
  DROP CONSTRAINT IF EXISTS notification_tokens_role_chk;

ALTER TABLE public.notification_tokens
  ADD CONSTRAINT notification_tokens_role_chk
  CHECK (role IN ('super_admin', 'admin', 'demo_admin', 'customer', 'staff', 'coordinator', 'system'));
