-- =============================================================================
-- Migration: 20260706000004_create_rbac_services_chat_gallery.sql
-- Purpose  : Creates missing PostgreSQL tables for admins, roles, permissions,
--            services, service_categories, gallery, and chat rooms/messages.
--            Sets up triggers, indexes, Row Level Security, and Realtime replication.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- 1. UTILITY TRIGGER FUNCTION (Idempotent declaration)
CREATE OR REPLACE FUNCTION public.fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. ROLES TABLE
CREATE TABLE IF NOT EXISTS public.roles (
  id          TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT roles_pkey PRIMARY KEY (id)
);

-- 3. PERMISSIONS TABLE
CREATE TABLE IF NOT EXISTS public.permissions (
  id          TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT permissions_pkey PRIMARY KEY (id)
);

-- 4. ROLE-PERMISSIONS RELATION
CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id       TEXT        NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_id TEXT        NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id)
);

-- 5. ADMINS TABLE
CREATE TABLE IF NOT EXISTS public.admins (
  id           TEXT        NOT NULL, -- Maps to firebase_uid
  name         TEXT        NOT NULL,
  email        TEXT        NOT NULL,
  role_id      TEXT        NOT NULL REFERENCES public.roles(id) ON DELETE RESTRICT,
  is_active    BOOLEAN     NOT NULL DEFAULT TRUE,
  phone        TEXT,
  designation  TEXT,
  bio          TEXT,
  photo_url    TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT admins_pkey PRIMARY KEY (id),
  CONSTRAINT admins_email_uq UNIQUE (email)
);

-- 6. SERVICE CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.service_categories (
  id          TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  slug        TEXT        NOT NULL,
  description TEXT,
  icon        TEXT,
  color       TEXT,
  image_url   TEXT,
  sort_order  INTEGER     NOT NULL DEFAULT 999,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT service_categories_pkey PRIMARY KEY (id),
  CONSTRAINT service_categories_slug_uq UNIQUE (slug)
);

-- 7. SERVICES TABLE
CREATE TABLE IF NOT EXISTS public.services (
  id             TEXT        NOT NULL,
  category_id    TEXT        NOT NULL REFERENCES public.service_categories(id) ON DELETE CASCADE,
  name           TEXT        NOT NULL,
  slug           TEXT        NOT NULL,
  description    TEXT,
  price          NUMERIC     NOT NULL DEFAULT 0.0,
  duration_hours NUMERIC     NOT NULL DEFAULT 1.0,
  image_url      TEXT,
  is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT services_pkey PRIMARY KEY (id),
  CONSTRAINT services_slug_uq UNIQUE (slug)
);

-- 8. GALLERY TABLE
CREATE TABLE IF NOT EXISTS public.gallery (
  id          TEXT        NOT NULL,
  booking_id  TEXT        NOT NULL,
  customer_id TEXT        NOT NULL,
  media_url   TEXT        NOT NULL,
  media_type  TEXT        NOT NULL DEFAULT 'image',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT gallery_pkey PRIMARY KEY (id)
);

-- 9. CHAT ROOMS TABLE
CREATE TABLE IF NOT EXISTS public.chat_rooms (
  id          TEXT        NOT NULL,
  name        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chat_rooms_pkey PRIMARY KEY (id)
);

-- 10. CHAT MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id          UUID        NOT NULL DEFAULT gen_random_uuid(),
  room_id     TEXT        NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id   TEXT        NOT NULL,
  message     TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chat_messages_pkey PRIMARY KEY (id)
);

-- ---------------------------------------------------------------------------
-- 11. TRIGGER SETUPS
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_roles_updated_at ON public.roles;
CREATE TRIGGER trg_roles_updated_at
  BEFORE UPDATE ON public.roles
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

DROP TRIGGER IF EXISTS trg_permissions_updated_at ON public.permissions;
CREATE TRIGGER trg_permissions_updated_at
  BEFORE UPDATE ON public.permissions
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

DROP TRIGGER IF EXISTS trg_admins_updated_at ON public.admins;
CREATE TRIGGER trg_admins_updated_at
  BEFORE UPDATE ON public.admins
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

DROP TRIGGER IF EXISTS trg_service_categories_updated_at ON public.service_categories;
CREATE TRIGGER trg_service_categories_updated_at
  BEFORE UPDATE ON public.service_categories
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

DROP TRIGGER IF EXISTS trg_services_updated_at ON public.services;
CREATE TRIGGER trg_services_updated_at
  BEFORE UPDATE ON public.services
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

DROP TRIGGER IF EXISTS trg_gallery_updated_at ON public.gallery;
CREATE TRIGGER trg_gallery_updated_at
  BEFORE UPDATE ON public.gallery
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

DROP TRIGGER IF EXISTS trg_chat_rooms_updated_at ON public.chat_rooms;
CREATE TRIGGER trg_chat_rooms_updated_at
  BEFORE UPDATE ON public.chat_rooms
  FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- ---------------------------------------------------------------------------
-- 12. INDEXES SETUP
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_admins_role      ON public.admins (role_id);
CREATE INDEX IF NOT EXISTS idx_serv_cat_slug    ON public.service_categories (slug);
CREATE INDEX IF NOT EXISTS idx_services_slug    ON public.services (slug);
CREATE INDEX IF NOT EXISTS idx_services_cat     ON public.services (category_id);
CREATE INDEX IF NOT EXISTS idx_gallery_booking  ON public.gallery (booking_id);
CREATE INDEX IF NOT EXISTS idx_gallery_customer ON public.gallery (customer_id);
CREATE INDEX IF NOT EXISTS idx_chat_msg_room    ON public.chat_messages (room_id, created_at ASC);

-- ---------------------------------------------------------------------------
-- 13. ROW LEVEL SECURITY (RLS)
-- ---------------------------------------------------------------------------
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- 14. POLICIES SETUP
-- ---------------------------------------------------------------------------
-- Public read access policies
DROP POLICY IF EXISTS "roles_public_select" ON public.roles;
CREATE POLICY "roles_public_select" ON public.roles FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "permissions_public_select" ON public.permissions;
CREATE POLICY "permissions_public_select" ON public.permissions FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "role_perms_public_select" ON public.role_permissions;
CREATE POLICY "role_perms_public_select" ON public.role_permissions FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "srv_cat_public_select" ON public.service_categories;
CREATE POLICY "srv_cat_public_select" ON public.service_categories FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "srv_public_select" ON public.services;
CREATE POLICY "srv_public_select" ON public.services FOR SELECT USING (TRUE);

-- Admin CRUD/All access policies
DROP POLICY IF EXISTS "roles_admin_all" ON public.roles;
CREATE POLICY "roles_admin_all" ON public.roles FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

DROP POLICY IF EXISTS "permissions_admin_all" ON public.permissions;
CREATE POLICY "permissions_admin_all" ON public.permissions FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

DROP POLICY IF EXISTS "role_perms_admin_all" ON public.role_permissions;
CREATE POLICY "role_perms_admin_all" ON public.role_permissions FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

DROP POLICY IF EXISTS "admins_admin_all" ON public.admins;
CREATE POLICY "admins_admin_all" ON public.admins FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

DROP POLICY IF EXISTS "srv_cat_admin_all" ON public.service_categories;
CREATE POLICY "srv_cat_admin_all" ON public.service_categories FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

DROP POLICY IF EXISTS "srv_admin_all" ON public.services;
CREATE POLICY "srv_admin_all" ON public.services FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

DROP POLICY IF EXISTS "chat_rooms_admin_all" ON public.chat_rooms;
CREATE POLICY "chat_rooms_admin_all" ON public.chat_rooms FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

-- Gallery policies
DROP POLICY IF EXISTS "gallery_select_policy" ON public.gallery;
CREATE POLICY "gallery_select_policy" ON public.gallery 
  FOR SELECT USING (customer_id = public.firebase_uid() OR public.is_firebase_admin());

DROP POLICY IF EXISTS "gallery_admin_all" ON public.gallery;
CREATE POLICY "gallery_admin_all" ON public.gallery 
  FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

-- Chat Rooms & Messages policies
DROP POLICY IF EXISTS "chat_rooms_select_policy" ON public.chat_rooms;
CREATE POLICY "chat_rooms_select_policy" ON public.chat_rooms 
  FOR SELECT USING (id = public.firebase_uid() OR public.is_firebase_admin());

DROP POLICY IF EXISTS "chat_msgs_select_policy" ON public.chat_messages;
CREATE POLICY "chat_msgs_select_policy" ON public.chat_messages 
  FOR SELECT USING (sender_id = public.firebase_uid() OR public.is_firebase_admin());

DROP POLICY IF EXISTS "chat_msgs_insert_policy" ON public.chat_messages;
CREATE POLICY "chat_msgs_insert_policy" ON public.chat_messages 
  FOR INSERT WITH CHECK (sender_id = public.firebase_uid() OR public.is_firebase_admin());

-- ---------------------------------------------------------------------------
-- 15. REALTIME COMPATIBILITY & PUBLICATIONS
-- ---------------------------------------------------------------------------
ALTER TABLE public.admins REPLICA IDENTITY FULL;
ALTER TABLE public.roles REPLICA IDENTITY FULL;
ALTER TABLE public.permissions REPLICA IDENTITY FULL;
ALTER TABLE public.service_categories REPLICA IDENTITY FULL;
ALTER TABLE public.services REPLICA IDENTITY FULL;
ALTER TABLE public.gallery REPLICA IDENTITY FULL;
ALTER TABLE public.chat_rooms REPLICA IDENTITY FULL;
ALTER TABLE public.chat_messages REPLICA IDENTITY FULL;

-- Add tables safely to publication if exists and not already present (Idempotent loop)
DO $$
DECLARE
  pub_id OID;
  t_name TEXT;
  tables_to_add TEXT[] := ARRAY['admins', 'roles', 'permissions', 'service_categories', 'services', 'gallery', 'chat_rooms', 'chat_messages'];
BEGIN
  SELECT oid INTO pub_id FROM pg_publication WHERE pubname = 'supabase_realtime';
  IF pub_id IS NOT NULL THEN
    FOREACH t_name IN ARRAY tables_to_add LOOP
      IF NOT EXISTS (
        SELECT 1 
        FROM pg_publication_rel pr
        JOIN pg_class c ON c.oid = pr.prrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE pr.prpubid = pub_id
          AND n.nspname = 'public'
          AND c.relname = t_name
      ) THEN
        EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t_name);
      END IF;
    END LOOP;
  END IF;
END;
$$;
