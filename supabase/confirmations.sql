-- INEGI UMEC — Equipment Confirmations Table
-- Run in: Supabase dashboard → SQL Editor → New query → paste → Run

CREATE TABLE IF NOT EXISTS public.equipment_confirmations (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  pc                TEXT        NOT NULL,
  utilizador        TEXT,
  confirmed_at      TIMESTAMPTZ DEFAULT now(),
  is_user_confirmed BOOLEAN     DEFAULT true,
  ubicacao          TEXT,
  ano_compra        INTEGER,
  estado_reportado  TEXT,       -- 'ok' | 'minor' | 'major' | 'broken'
  disponibilidade   TEXT,       -- 'ocupado' | 'disponivel'
  periph_notes      TEXT,
  notes             TEXT
);

ALTER TABLE public.equipment_confirmations ENABLE ROW LEVEL SECURITY;

-- Anon users can insert (submit the form) but cannot read other people's responses
CREATE POLICY "anon_insert" ON public.equipment_confirmations
  FOR INSERT TO anon WITH CHECK (true);

-- Authenticated users (admins) can read all responses
CREATE POLICY "auth_read" ON public.equipment_confirmations
  FOR SELECT TO authenticated USING (true);

-- Index for fast lookup by PC name
CREATE INDEX IF NOT EXISTS idx_confirmations_pc ON public.equipment_confirmations (pc);
CREATE INDEX IF NOT EXISTS idx_confirmations_at ON public.equipment_confirmations (confirmed_at DESC);
