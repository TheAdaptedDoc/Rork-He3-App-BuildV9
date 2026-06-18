-- =============================================================================
-- HE3 / THE INTEGRATED MAN  ·  Lesson catalog  ·  additive migration
-- Runs AFTER 0001_core_schema.sql. Adds the streaming lesson catalog only.
-- Entitlement, profiles, RLS, and get_entitlement() all live in 0001.
-- =============================================================================

-- The 31 video manifest from the Filming Architecture. One row per video.
-- mux_playback_id is the SIGNED Mux playback id, filled in after upload.
-- The stream itself is gated by the signed token (see the edge function),
-- which is only minted for a man whose get_entitlement() says program_access.
create table if not exists public.lessons (
  id               uuid primary key default gen_random_uuid(),
  slug             text not null unique,         -- equals the in app section id for core lessons
  kind             text not null default 'core', -- core | practice | connective | keystone
  pillar_id        int,                          -- 1..4, null for Day 0 and connective
  day_index        int,
  sort             int  not null default 0,
  title            text not null,
  subtitle         text,
  duration_seconds int  not null default 0,
  mux_playback_id  text,
  is_published     boolean not null default true,
  created_at       timestamptz default now()
);

create index if not exists lessons_pillar_idx on public.lessons (pillar_id, sort);

alter table public.lessons enable row level security;

-- The lesson LIST is readable by any entitled, signed in man. The 90 day window
-- expiry is honored here too, matching get_entitlement().
drop policy if exists "lessons_entitled_read" on public.lessons;
create policy "lessons_entitled_read"
  on public.lessons
  for select
  to authenticated
  using (
    is_published = true
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.program_access = true
        and (p.access_end is null or now() < p.access_end)
    )
  );

-- Only the service role writes the catalog. No client write policy on purpose.
