-- COPA · Multiplayer Draft table
-- Run in Supabase SQL Editor (in addition to the earlier copa_saves setup)

create table if not exists public.copa_draft (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  status text not null default 'waiting',      -- waiting | drafting | match | done
  is_public boolean not null default false,
  p1_token text, p2_token text,
  p1_name text, p2_name text,
  seed bigint,
  p1_picks jsonb not null default '[]',
  p2_picks jsonb not null default '[]',
  p1_moves jsonb not null default '{}',
  p2_moves jsonb not null default '{}',
  state jsonb,
  updated_at timestamptz default now(),
  created_at timestamptz default now()
);

alter table public.copa_draft enable row level security;

-- Casual-game policy: the anon key may read and write lobbies.
-- Access control is app-level via per-player tokens; no personal data is stored.
create policy "draft read" on public.copa_draft for select using (true);
create policy "draft insert" on public.copa_draft for insert with check (true);
create policy "draft update" on public.copa_draft for update using (true);

-- Optional housekeeping: clear finished/abandoned lobbies older than a day.
-- Run manually now and then, or schedule it with pg_cron if you enable that extension:
--   delete from public.copa_draft where created_at < now() - interval '1 day';
