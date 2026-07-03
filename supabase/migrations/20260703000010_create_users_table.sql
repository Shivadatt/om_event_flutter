-- =============================================================================
-- Migration: 20260703000010_create_users_table.sql
-- Purpose  : Consolidated. The users table, auth.uid() safety override,
--            and public.firebase_uid() helper functions were moved to
--            migration 20260703000001_create_notification_tokens.sql
--            to allow all subsequent tables to utilize Firebase UID RLS.
-- =============================================================================

SELECT 1;
