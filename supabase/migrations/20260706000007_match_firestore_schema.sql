-- Migration: 20260706000007_match_firestore_schema
-- Purpose  : Decouples legacy unused tables and creates 1:1 mapped Firestore tables (items, admin, notification_delivery_events).

BEGIN;

-- 1. DROP UNUSED LEGACY TABLES AND CONSTRAINTS (Verified completely safe to delete)
ALTER TABLE IF EXISTS public.services DROP CONSTRAINT IF EXISTS services_category_id_fkey CASCADE;
DROP TABLE IF EXISTS public.services CASCADE;
DROP TABLE IF EXISTS public.service_categories CASCADE;

-- 2. CREATE MISSING 1:1 FIRESTORE TABLES

-- Table: items (matches Firestore items collection)
CREATE TABLE IF NOT EXISTS public.items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) DEFAULT 0.00,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: admin (matches Firestore admin collection, links to admins table)
CREATE TABLE IF NOT EXISTS public.admin (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  role_id TEXT REFERENCES public.roles(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: notification_delivery_events (matches Firestore notification_delivery_events collection)
CREATE TABLE IF NOT EXISTS public.notification_delivery_events (
  id TEXT PRIMARY KEY,
  notification_id TEXT,
  recipient TEXT,
  status TEXT DEFAULT 'pending',
  delivered_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ENABLE RLS FOR NEW TABLES
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_delivery_events ENABLE ROW LEVEL SECURITY;

-- 4. CREATE RLS POLICIES FOR NEW TABLES
CREATE POLICY "items_public_select" ON public.items FOR SELECT USING (true);
CREATE POLICY "items_admin_all" ON public.items FOR ALL USING (public.is_firebase_admin());

CREATE POLICY "admin_admin_all" ON public.admin FOR ALL USING (public.is_firebase_admin());

CREATE POLICY "nde_service_role_policy" ON public.notification_delivery_events FOR ALL USING (true);

-- 5. ENABLE REALTIME FOR ITEMS TABLE
ALTER PUBLICATION supabase_realtime ADD TABLE items;

COMMIT;
