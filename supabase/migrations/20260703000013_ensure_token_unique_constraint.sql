-- =============================================================================
-- Migration: 20260703000013_ensure_token_unique_constraint.sql
-- Purpose  : Guarantee that notification_tokens has the unique constraint on
--            (user_id, device_id) to prevent HTTP 400 on upserts.
-- Author   : Om Events â€“ Database Architecture Team
-- =============================================================================

ALTER TABLE public.notification_tokens
  DROP CONSTRAINT IF EXISTS notification_tokens_user_device_uq;

ALTER TABLE public.notification_tokens
  ADD CONSTRAINT notification_tokens_user_device_uq UNIQUE (user_id, device_id);
