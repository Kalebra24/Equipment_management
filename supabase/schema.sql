-- INEGI UMEC Equipment Manager — Supabase Schema
-- Safe to run against the shared database used by team-planning.
-- Contains NO DROP statements — purely additive.
--
-- Run in: Supabase dashboard → SQL Editor → New query → paste → Run

-- ── 1. Create table (only if it doesn't exist yet) ───────────────────────────
CREATE TABLE IF NOT EXISTS public.app_storage (
  app_id     TEXT        NOT NULL DEFAULT '',
  key        TEXT        NOT NULL,
  value      TEXT        NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (app_id, key)
);

-- ── 2. Add app_id column to an existing single-key table ─────────────────────
--    No-op when the column already exists.
ALTER TABLE public.app_storage
  ADD COLUMN IF NOT EXISTS app_id TEXT NOT NULL DEFAULT '';

-- ── 3. Upgrade primary key from (key) → (app_id, key) if still on old schema ─
--    Does nothing when the composite PK already exists.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.key_column_usage
    WHERE table_schema    = 'public'
      AND table_name      = 'app_storage'
      AND constraint_name = 'app_storage_pkey'
      AND column_name     = 'app_id'
  ) THEN
    ALTER TABLE public.app_storage DROP CONSTRAINT app_storage_pkey;
    ALTER TABLE public.app_storage ADD PRIMARY KEY (app_id, key);
  END IF;
END $$;

-- ── 4. Tag existing team-planning rows so they keep working unchanged ─────────
UPDATE public.app_storage
  SET app_id = 'team-planning'
  WHERE app_id = '';

-- ── 5. Enable RLS ─────────────────────────────────────────────────────────────
ALTER TABLE public.app_storage ENABLE ROW LEVEL SECURITY;

-- ── 6. Create policy only if it doesn't exist yet ────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename  = 'app_storage'
      AND policyname = 'public_readwrite'
  ) THEN
    EXECUTE '
      CREATE POLICY "public_readwrite" ON public.app_storage
        FOR ALL TO anon, authenticated
        USING (true) WITH CHECK (true)
    ';
  END IF;
END $$;
