-- Idempotent SQL script for database cleanup
-- Targets ONLY tables classified as SAFE TO DELETE (admin_profiles)

DROP TABLE IF EXISTS public.admin_profiles CASCADE;
