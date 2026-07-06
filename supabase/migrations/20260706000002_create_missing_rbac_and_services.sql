-- =============================================================================
-- Migration: 20260706000002_create_missing_rbac_and_services.sql
-- Purpose  : Creates missing PostgreSQL tables for admins, roles, permissions,
--            services, service_categories, gallery, and chat rooms.
--            Configures indexes, constraints, updated_at triggers, and RLS policies.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Roles & Permissions (RBAC Engine)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.roles (
  id          TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT roles_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.permissions (
  id          TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT permissions_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id       TEXT        NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_id TEXT        NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id)
);

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

-- ---------------------------------------------------------------------------
-- 2. Services & Categories (Catalog Engine)
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- 3. Gallery (Event Portfolio)
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- 4. Chat Rooms (Real-time Communications)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.chat_rooms (
  id          TEXT        NOT NULL,
  name        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chat_rooms_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id          UUID        NOT NULL DEFAULT gen_random_uuid(),
  room_id     TEXT        NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id   TEXT        NOT NULL,
  message     TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chat_messages_pkey PRIMARY KEY (id)
);

-- ---------------------------------------------------------------------------
-- Triggers for updated_at Auto-Update
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
-- Indexes Setup for Query Optimization
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_admins_role      ON public.admins (role_id);
CREATE INDEX IF NOT EXISTS idx_serv_cat_slug    ON public.service_categories (slug);
CREATE INDEX IF NOT EXISTS idx_services_slug    ON public.services (slug);
CREATE INDEX IF NOT EXISTS idx_services_cat     ON public.services (category_id);
CREATE INDEX IF NOT EXISTS idx_gallery_booking  ON public.gallery (booking_id);
CREATE INDEX IF NOT EXISTS idx_gallery_customer ON public.gallery (customer_id);
CREATE INDEX IF NOT EXISTS idx_chat_msg_room    ON public.chat_messages (room_id, created_at ASC);

-- ---------------------------------------------------------------------------
-- Row Level Security (RLS) & Policies
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

-- 1. Public Read-Only tables
CREATE POLICY "roles_public_select" ON public.roles FOR SELECT USING (TRUE);
CREATE POLICY "permissions_public_select" ON public.permissions FOR SELECT USING (TRUE);
CREATE POLICY "role_perms_public_select" ON public.role_permissions FOR SELECT USING (TRUE);
CREATE POLICY "srv_cat_public_select" ON public.service_categories FOR SELECT USING (TRUE);
CREATE POLICY "srv_public_select" ON public.services FOR SELECT USING (TRUE);

-- Admin control policies
CREATE POLICY "roles_admin_all" ON public.roles FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "permissions_admin_all" ON public.permissions FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "role_perms_admin_all" ON public.role_permissions FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "admins_admin_all" ON public.admins FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "srv_cat_admin_all" ON public.service_categories FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "srv_admin_all" ON public.services FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "chat_rooms_admin_all" ON public.chat_rooms FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

-- Gallery policies (Customers can read their booking photos)
CREATE POLICY "gallery_select_policy" ON public.gallery
  FOR SELECT USING (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "gallery_admin_all" ON public.gallery
  FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

-- Chat Rooms & Messages policies
CREATE POLICY "chat_rooms_select_policy" ON public.chat_rooms
  FOR SELECT USING (id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "chat_msgs_select_policy" ON public.chat_messages
  FOR SELECT USING (sender_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "chat_msgs_insert_policy" ON public.chat_messages
  FOR INSERT WITH CHECK (sender_id = public.firebase_uid() OR public.is_firebase_admin());
