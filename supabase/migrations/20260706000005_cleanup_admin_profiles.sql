-- Migration: 20260706000005_cleanup_admin_profiles.sql
-- Description: Drop the legacy, unused admin_profiles table.
-- Rationale: The application uses 'admins' table for RBAC.

DROP TABLE IF EXISTS public.admin_profiles CASCADE;
