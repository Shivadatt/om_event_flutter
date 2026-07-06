-- =============================================================================
-- Migration: 20260703000014_create_mirror_tables.sql
-- Purpose  : Creates mirror tables in Supabase for Firestore synchronization:
--            bookings, leads, quotations, reviews, settings.
--            Enables RLS on all tables and restricts writes to Service Role.
-- Author   : Om Events – Database Architecture Team
-- =============================================================================

-- 1. Bookings Mirror Table
CREATE TABLE IF NOT EXISTS public.bookings (
  id              TEXT        NOT NULL,
  customer_id     TEXT        NOT NULL,
  booking_number  TEXT        NOT NULL,
  status          TEXT        NOT NULL DEFAULT 'pending',
  event_date      TEXT,
  customer_email  TEXT,
  customer_phone  TEXT,
  amount          NUMERIC     NOT NULL DEFAULT 0.0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT bookings_pkey PRIMARY KEY (id)
);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "bookings_read_policy"
  ON public.bookings FOR SELECT
  USING (TRUE); -- Allow read access

CREATE POLICY "bookings_service_role_all_policy"
  ON public.bookings FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- 2. Leads Mirror Table
CREATE TABLE IF NOT EXISTS public.leads (
  id              TEXT        NOT NULL,
  status          TEXT        NOT NULL DEFAULT 'pending',
  customer_name   TEXT,
  customer_phone  TEXT,
  customer_email  TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT leads_pkey PRIMARY KEY (id)
);

ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "leads_read_policy"
  ON public.leads FOR SELECT
  USING (TRUE);

CREATE POLICY "leads_service_role_all_policy"
  ON public.leads FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- 3. Quotations Mirror Table
CREATE TABLE IF NOT EXISTS public.quotations (
  id              TEXT        NOT NULL,
  status          TEXT        NOT NULL DEFAULT 'pending',
  customer_id     TEXT        NOT NULL,
  customer_name   TEXT,
  public_id       TEXT,
  customer_email  TEXT,
  customer_phone  TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT quotations_pkey PRIMARY KEY (id)
);

ALTER TABLE public.quotations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "quotations_read_policy"
  ON public.quotations FOR SELECT
  USING (TRUE);

CREATE POLICY "quotations_service_role_all_policy"
  ON public.quotations FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- 4. Reviews Mirror Table
CREATE TABLE IF NOT EXISTS public.reviews (
  id              TEXT        NOT NULL,
  rating          INTEGER     NOT NULL DEFAULT 5,
  comment         TEXT,
  customer_id     TEXT        NOT NULL,
  experience_id   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT reviews_pkey PRIMARY KEY (id)
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reviews_read_policy"
  ON public.reviews FOR SELECT
  USING (TRUE);

CREATE POLICY "reviews_service_role_all_policy"
  ON public.reviews FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);

-- 5. Settings Mirror Table
CREATE TABLE IF NOT EXISTS public.settings (
  id              TEXT        NOT NULL,
  key             TEXT        NOT NULL,
  value           TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT settings_pkey PRIMARY KEY (id),
  CONSTRAINT settings_key_uq UNIQUE (key)
);

ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "settings_read_policy"
  ON public.settings FOR SELECT
  USING (TRUE);

CREATE POLICY "settings_service_role_all_policy"
  ON public.settings FOR ALL TO service_role
  USING (TRUE) WITH CHECK (TRUE);
