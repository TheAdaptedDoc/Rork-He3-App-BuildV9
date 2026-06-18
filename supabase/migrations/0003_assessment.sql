-- =============================================================================
-- HE3 assessment results · v2 metrics + re-calibration
-- Runs after 0001_core_schema.sql. Idempotent.
-- Stores every take (day 0 baseline and the day 30 re-calibration) so the app
-- can plot Voice Spread falling and Integration Index climbing.
-- =============================================================================

create table if not exists public.assessment_results (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references public.profiles (id) on delete cascade,
  phase             text not null default 'day0',   -- day0 | day30
  ego_score         int  not null,
  self_score        int  not null,
  innate_score      int  not null,
  integration_score int  not null default 21,       -- 7..35, measured directly
  voice_spread      int  not null default 0,        -- highest voice minus lowest
  dominant          text not null,
  suppressed        text not null,
  archetype         text,                           -- the routed profile
  created_at        timestamptz default now()
);

-- For databases provisioned before v2, add the new columns if missing.
alter table public.assessment_results
  add column if not exists integration_score int not null default 21,
  add column if not exists voice_spread      int not null default 0,
  add column if not exists phase             text not null default 'day0',
  add column if not exists archetype         text;

create index if not exists assessment_results_user_idx
  on public.assessment_results (user_id, created_at);

alter table public.assessment_results enable row level security;

-- A man reads and writes only his own results.
drop policy if exists "assessment_self_read" on public.assessment_results;
create policy "assessment_self_read"
  on public.assessment_results for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "assessment_self_insert" on public.assessment_results;
create policy "assessment_self_insert"
  on public.assessment_results for insert
  to authenticated
  with check (auth.uid() = user_id);
