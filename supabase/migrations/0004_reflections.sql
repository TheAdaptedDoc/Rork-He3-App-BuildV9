-- =============================================================================
-- HE3 Council reflections  ·  stores each AI reflection so a man can revisit it
-- Runs after the other migrations. Idempotent.
-- =============================================================================

create table if not exists public.reflections (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  pillar      text,
  situation   text not null,
  ego         text not null,
  self_voice  text not null,
  innate      text not null,
  synthesis   text not null,
  created_at  timestamptz default now()
);

create index if not exists reflections_user_idx
  on public.reflections (user_id, created_at desc);

alter table public.reflections enable row level security;

-- A man reads and writes only his own reflections.
drop policy if exists "reflections_self_read" on public.reflections;
create policy "reflections_self_read"
  on public.reflections for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "reflections_self_insert" on public.reflections;
create policy "reflections_self_insert"
  on public.reflections for insert
  to authenticated
  with check (auth.uid() = user_id);
