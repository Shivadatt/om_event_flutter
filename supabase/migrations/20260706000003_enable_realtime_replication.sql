-- =============================================================================
-- Migration: 20260706000003_enable_realtime_replication.sql
-- Purpose  : Automatically registers all tables streamed by the client in
--            the 'supabase_realtime' publication. Enables push-based replication
--            events for PostgreSQL changes and RLS policies.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

DO $$
DECLARE
  v_table_name TEXT;
  v_subscribed_tables TEXT[] := ARRAY[
    'categories',
    'experiences',
    'reviews',
    'bookings',
    'leads',
    'payments',
    'quotations',
    'settings',
    'contact_numbers',
    'chat_messages',
    'customer_leads',
    'customer_bookings',
    'customer_quotes',
    'booking_timelines',
    'customer_payments',
    'customer_notifications',
    'customer_documents',
    'booking_gallery',
    'customer_wishlist',
    'offers',
    'customer_activity',
    'rebook_requests'
  ];
BEGIN
  -- 1. Ensure the supabase_realtime publication exists
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;

  -- 2. Safely add every subscribed table to the publication if not already present
  FOREACH v_table_name IN ARRAY v_subscribed_tables LOOP
    -- Confirm the table exists in the public schema
    IF EXISTS (
      SELECT 1 
      FROM pg_tables 
      WHERE schemaname = 'public' 
        AND tablename = v_table_name
    ) THEN
      -- If not already part of the publication, add it
      IF NOT EXISTS (
        SELECT 1 
        FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = v_table_name
      ) THEN
        EXECUTE FORMAT('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', v_table_name);
      END IF;
    END IF;
  END LOOP;
END;
$$;
