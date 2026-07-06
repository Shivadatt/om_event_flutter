-- =============================================================================
-- Migration: 20260706000001_create_missing_tables.sql
-- Purpose  : Creates missing tables in Supabase for CRM catalog, Customer Portal,
--            audit logging, and settings draft versioning.
--            Configures Row Level Security (RLS) policies for Firebase UID isolation.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- 1. Categories Table
CREATE TABLE IF NOT EXISTS public.categories (
  id          TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  slug        TEXT        NOT NULL,
  description TEXT,
  icon        TEXT,
  color       TEXT,
  image_url   TEXT,
  sort_order  INTEGER     NOT NULL DEFAULT 999,
  item_count  INTEGER     NOT NULL DEFAULT 0,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_slug_uq UNIQUE (slug)
);

-- 2. Experiences (Decoration Items) Table
CREATE TABLE IF NOT EXISTS public.experiences (
  id             TEXT          NOT NULL,
  category_id    TEXT          NOT NULL,
  category_name  TEXT,
  category_slug  TEXT,
  name           TEXT          NOT NULL,
  slug           TEXT          NOT NULL,
  description    TEXT,
  price          NUMERIC       NOT NULL DEFAULT 0.0,
  offer_price    NUMERIC,
  duration_hours NUMERIC       NOT NULL DEFAULT 1.0,
  popularity     INTEGER       NOT NULL DEFAULT 0,
  rating         NUMERIC       NOT NULL DEFAULT 5.0,
  review_count   INTEGER       NOT NULL DEFAULT 0,
  availability   TEXT          NOT NULL DEFAULT 'available',
  tags           TEXT[]        NOT NULL DEFAULT '{}',
  colors         TEXT[]        NOT NULL DEFAULT '{}',
  themes         TEXT[]        NOT NULL DEFAULT '{}',
  image_url      TEXT,
  video_url      TEXT,
  is_featured    BOOLEAN       NOT NULL DEFAULT FALSE,
  is_active      BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT experiences_pkey PRIMARY KEY (id),
  CONSTRAINT experiences_slug_uq UNIQUE (slug),
  CONSTRAINT experiences_category_fk FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE
);

-- 3. Admin Profiles Table
CREATE TABLE IF NOT EXISTS public.admin_profiles (
  uid          TEXT        NOT NULL,
  name         TEXT        NOT NULL,
  email        TEXT        NOT NULL,
  role         TEXT        NOT NULL DEFAULT 'staff',
  is_active    BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by   TEXT,
  role_type    TEXT,
  phone        TEXT,
  designation  TEXT,
  bio          TEXT,
  address      TEXT,
  photo_url    TEXT,
  last_login   TIMESTAMPTZ,

  CONSTRAINT admin_profiles_pkey PRIMARY KEY (uid)
);

-- 4. Customer Profiles Table
CREATE TABLE IF NOT EXISTS public.customer_profiles (
  id                TEXT        NOT NULL,
  full_name         TEXT        NOT NULL,
  phone             TEXT        NOT NULL,
  email             TEXT,
  gender            TEXT,
  date_of_birth     DATE,
  address           TEXT,
  city              TEXT,
  state             TEXT,
  pincode           TEXT,
  branch            TEXT        NOT NULL DEFAULT 'Ahmedabad',
  profile_image_url TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login        TIMESTAMPTZ,

  CONSTRAINT customer_profiles_pkey PRIMARY KEY (id)
);

-- 5. Customer Leads Table
CREATE TABLE IF NOT EXISTS public.customer_leads (
  id          TEXT        NOT NULL,
  customer_id TEXT        NOT NULL,
  lead_number TEXT        NOT NULL,
  date        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  service     TEXT,
  branch      TEXT        NOT NULL DEFAULT 'Ahmedabad',
  budget      NUMERIC,
  event_date  TIMESTAMPTZ,
  status      TEXT        NOT NULL DEFAULT 'Pending',
  admin_notes TEXT,

  CONSTRAINT customer_leads_pkey PRIMARY KEY (id),
  CONSTRAINT customer_leads_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 6. Customer Quotes Table
CREATE TABLE IF NOT EXISTS public.customer_quotes (
  id               TEXT        NOT NULL,
  customer_id      TEXT        NOT NULL,
  quotation_number TEXT        NOT NULL,
  date             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  amount           NUMERIC     NOT NULL DEFAULT 0.0,
  status           TEXT        NOT NULL DEFAULT 'Pending',
  expiry_date      TIMESTAMPTZ,
  pdf_url          TEXT,
  notes            TEXT,
  items            JSONB       NOT NULL DEFAULT '[]'::jsonb,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT customer_quotes_pkey PRIMARY KEY (id),
  CONSTRAINT customer_quotes_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 7. Customer Bookings Table
CREATE TABLE IF NOT EXISTS public.customer_bookings (
  id               TEXT        NOT NULL,
  customer_id      TEXT        NOT NULL,
  booking_number   TEXT        NOT NULL,
  event_name       TEXT,
  package          TEXT,
  branch           TEXT,
  decoration_type  TEXT,
  date             TIMESTAMPTZ NOT NULL,
  venue            TEXT,
  amount           NUMERIC     NOT NULL DEFAULT 0.0,
  advance_paid     NUMERIC     NOT NULL DEFAULT 0.0,
  remaining_amount NUMERIC     NOT NULL DEFAULT 0.0,
  assigned_branch  TEXT,
  assigned_contact TEXT,
  status           TEXT        NOT NULL DEFAULT 'Pending',

  CONSTRAINT customer_bookings_pkey PRIMARY KEY (id),
  CONSTRAINT customer_bookings_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 8. Booking Timelines Table
CREATE TABLE IF NOT EXISTS public.booking_timelines (
  id           TEXT        NOT NULL,
  booking_id   TEXT        NOT NULL,
  status       TEXT        NOT NULL,
  updated_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notes        TEXT,

  CONSTRAINT booking_timelines_pkey PRIMARY KEY (id)
);

-- 9. Customer Payments Table
CREATE TABLE IF NOT EXISTS public.customer_payments (
  id           TEXT        NOT NULL,
  customer_id  TEXT        NOT NULL,
  booking_id   TEXT        NOT NULL,
  amount       NUMERIC     NOT NULL DEFAULT 0.0,
  status       TEXT        NOT NULL DEFAULT 'Pending',
  method       TEXT        NOT NULL DEFAULT 'Offline',
  receipt_url  TEXT,
  invoice_url  TEXT,
  payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT customer_payments_pkey PRIMARY KEY (id),
  CONSTRAINT customer_payments_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 10. Customer Notifications Table
CREATE TABLE IF NOT EXISTS public.customer_notifications (
  id          TEXT        NOT NULL,
  customer_id TEXT        NOT NULL,
  title       TEXT        NOT NULL,
  body        TEXT        NOT NULL,
  type        TEXT        NOT NULL,
  is_read     BOOLEAN     NOT NULL DEFAULT FALSE,
  branch      TEXT        NOT NULL DEFAULT 'Ahmedabad',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_archived BOOLEAN     NOT NULL DEFAULT FALSE,
  priority    TEXT        NOT NULL DEFAULT 'normal',
  expires_at  TIMESTAMPTZ,

  CONSTRAINT customer_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT customer_notifications_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 11. Customer Wishlist Table
CREATE TABLE IF NOT EXISTS public.customer_wishlist (
  id            TEXT        NOT NULL,
  customer_id   TEXT        NOT NULL,
  experience_id TEXT        NOT NULL,
  added_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT customer_wishlist_pkey PRIMARY KEY (id),
  CONSTRAINT customer_wishlist_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE,
  CONSTRAINT customer_wishlist_experience_fk FOREIGN KEY (experience_id) REFERENCES public.experiences(id) ON DELETE CASCADE,
  CONSTRAINT customer_wishlist_uq UNIQUE (customer_id, experience_id)
);

-- 12. Customer Documents Table
CREATE TABLE IF NOT EXISTS public.customer_documents (
  id          TEXT        NOT NULL,
  customer_id TEXT        NOT NULL,
  booking_id  TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  url         TEXT        NOT NULL,
  type        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT customer_documents_pkey PRIMARY KEY (id),
  CONSTRAINT customer_documents_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 13. Booking Gallery Table
CREATE TABLE IF NOT EXISTS public.booking_gallery (
  id          TEXT        NOT NULL,
  customer_id TEXT        NOT NULL,
  booking_id  TEXT        NOT NULL,
  media_urls  TEXT[]      NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT booking_gallery_pkey PRIMARY KEY (id),
  CONSTRAINT booking_gallery_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 14. Rebook Requests Table
CREATE TABLE IF NOT EXISTS public.rebook_requests (
  id                  TEXT        NOT NULL,
  customer_id         TEXT        NOT NULL,
  previous_booking_id TEXT        NOT NULL,
  new_date            TIMESTAMPTZ NOT NULL,
  status              TEXT        NOT NULL DEFAULT 'Pending',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT rebook_requests_pkey PRIMARY KEY (id),
  CONSTRAINT rebook_requests_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 15. Offers Table
CREATE TABLE IF NOT EXISTS public.offers (
  id          TEXT        NOT NULL,
  title       TEXT        NOT NULL,
  description TEXT,
  image_url   TEXT,
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  priority    INTEGER     NOT NULL DEFAULT 0,
  expiry_date TIMESTAMPTZ NOT NULL,
  branch      TEXT        NOT NULL DEFAULT 'Ahmedabad',

  CONSTRAINT offers_pkey PRIMARY KEY (id)
);

-- 16. Customer Activity Table
CREATE TABLE IF NOT EXISTS public.customer_activity (
  id          TEXT        NOT NULL,
  customer_id TEXT        NOT NULL,
  status      TEXT        NOT NULL,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  details     TEXT,

  CONSTRAINT customer_activity_pkey PRIMARY KEY (id),
  CONSTRAINT customer_activity_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customer_profiles(id) ON DELETE CASCADE
);

-- 17. Contact Numbers Table
CREATE TABLE IF NOT EXISTS public.contact_numbers (
  id            TEXT        NOT NULL,
  label         TEXT        NOT NULL,
  number        TEXT        NOT NULL,
  is_primary    BOOLEAN     NOT NULL DEFAULT FALSE,
  is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
  display_order INTEGER     NOT NULL DEFAULT 999,

  CONSTRAINT contact_numbers_pkey PRIMARY KEY (id)
);

-- 18. Settings History Table (Draft/Versioning engine subcollection)
CREATE TABLE IF NOT EXISTS public.settings_history (
  id          UUID        NOT NULL DEFAULT gen_random_uuid(),
  setting_id  TEXT        NOT NULL,
  version     INTEGER     NOT NULL,
  published   JSONB       NOT NULL,
  meta        JSONB       NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT settings_history_pkey PRIMARY KEY (id),
  CONSTRAINT settings_history_uq UNIQUE (setting_id, version)
);

-- 19. Activity Logs Table
CREATE TABLE IF NOT EXISTS public.activity_logs (
  id          UUID        NOT NULL DEFAULT gen_random_uuid(),
  user_id     TEXT,
  action      TEXT        NOT NULL,
  entity_type TEXT        NOT NULL,
  entity_id   TEXT        NOT NULL,
  ip_address  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT activity_logs_pkey PRIMARY KEY (id)
);

-- ---------------------------------------------------------------------------
-- Alter Existing Mirror Tables to Support Draft Engine
-- ---------------------------------------------------------------------------
ALTER TABLE public.settings ADD COLUMN IF NOT EXISTS draft JSONB;
ALTER TABLE public.settings ADD COLUMN IF NOT EXISTS published JSONB;
ALTER TABLE public.settings ADD COLUMN IF NOT EXISTS meta JSONB;

-- Add Foreign Key constraint to settings_history
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'settings_history_settings_fk'
  ) THEN
    ALTER TABLE public.settings_history
      ADD CONSTRAINT settings_history_settings_fk
      FOREIGN KEY (setting_id) REFERENCES public.settings(id) ON DELETE CASCADE;
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Indexes Setup for Optimal Queries
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cat_slug         ON public.categories (slug);
CREATE INDEX IF NOT EXISTS idx_exp_cat          ON public.experiences (category_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_exp_slug         ON public.experiences (slug);
CREATE INDEX IF NOT EXISTS idx_cust_prof_phone  ON public.customer_profiles (phone);
CREATE INDEX IF NOT EXISTS idx_leads_cust       ON public.customer_leads (customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_cust    ON public.customer_bookings (customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_cust    ON public.customer_payments (customer_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_cust    ON public.customer_wishlist (customer_id);
CREATE INDEX IF NOT EXISTS idx_timelines_bk     ON public.booking_timelines (booking_id);
CREATE INDEX IF NOT EXISTS idx_history_setting  ON public.settings_history (setting_id, version DESC);

-- ---------------------------------------------------------------------------
-- Row Level Security (RLS) policies
-- ---------------------------------------------------------------------------
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_wishlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rebook_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_numbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- Select policy triggers
CREATE POLICY "cat_public_select" ON public.categories FOR SELECT USING (TRUE);
CREATE POLICY "exp_public_select" ON public.experiences FOR SELECT USING (TRUE);
CREATE POLICY "offers_public_select" ON public.offers FOR SELECT USING (is_active = TRUE);
CREATE POLICY "contact_public_select" ON public.contact_numbers FOR SELECT USING (is_active = TRUE);

-- Admin control policies
CREATE POLICY "cat_admin_all" ON public.categories FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "exp_admin_all" ON public.experiences FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "admin_profiles_admin_all" ON public.admin_profiles FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "contact_admin_all" ON public.contact_numbers FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "settings_history_admin_all" ON public.settings_history FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());
CREATE POLICY "activity_logs_admin_all" ON public.activity_logs FOR ALL USING (public.is_firebase_admin()) WITH CHECK (public.is_firebase_admin());

-- Customer portal policies using Firebase UID
CREATE POLICY "cust_prof_owner_policy" ON public.customer_profiles
  FOR ALL USING (id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "leads_owner_policy" ON public.customer_leads
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "quotes_owner_policy" ON public.customer_quotes
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "bookings_owner_policy" ON public.customer_bookings
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "payments_owner_policy" ON public.customer_payments
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "notifications_owner_policy" ON public.customer_notifications
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "wishlist_owner_policy" ON public.customer_wishlist
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "documents_owner_policy" ON public.customer_documents
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "booking_gallery_owner_policy" ON public.booking_gallery
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "rebook_owner_policy" ON public.rebook_requests
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

CREATE POLICY "activity_owner_policy" ON public.customer_activity
  FOR ALL USING (customer_id = public.firebase_uid() OR public.is_firebase_admin())
  WITH CHECK (customer_id = public.firebase_uid() OR public.is_firebase_admin());

-- ---------------------------------------------------------------------------
-- RPC Functions
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_experience_popularity(exp_slug TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.experiences
  SET popularity = popularity + 1
  WHERE slug = exp_slug;
END;
$$;
