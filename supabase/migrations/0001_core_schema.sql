-- =============================================================================
-- HE3 / THE INTEGRATED MAN  ·  Supabase schema  ·  v1
-- Run top to bottom in the Supabase SQL editor.
--
-- Model: the app only READS entitlement. Stripe is the source of truth.
-- A Stripe webhook (Edge Function, service role) WRITES to the profiles table.
-- The app calls get_entitlement() to gate its screens.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. profiles table  (one row per signed-in man, keyed to the auth user)
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id                  uuid primary key references auth.users (id) on delete cascade,
  email               text,
  stripe_customer_id  text,

  -- program ($297, one time, 90 day window)
  program_access      boolean not null default false,
  access_start        timestamptz,
  access_end          timestamptz,

  -- recurring tiers
  standard_active     boolean not null default false,   -- The Standard, $19/mo
  brotherhood_active  boolean not null default false,   -- The Brotherhood, $147/mo (enforced in Circle, mirrored here)

  -- Vanguard tags, copied from Stripe checkout metadata
  referrer_id         text,
  pod_id              text,
  standard_bearer_id  text,

  updated_at          timestamptz not null default now()
);

-- indexes the webhook uses to find the right man
create index if not exists profiles_stripe_customer_id_idx on public.profiles (stripe_customer_id);
create index if not exists profiles_email_idx              on public.profiles (lower(email));


-- -----------------------------------------------------------------------------
-- 2. Row level security
--    A man can read ONLY his own row. No client can write.
--    The webhook writes with the service role key, which bypasses RLS.
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "read own profile" on public.profiles;
create policy "read own profile"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

-- Note: intentionally NO insert / update / delete policies for users.
-- Only the service role (the Stripe webhook) writes to this table.


-- -----------------------------------------------------------------------------
-- 3. Auto-create a profile row when a new auth user signs up
--    (fires on Sign in with Apple / Google first time)
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- -----------------------------------------------------------------------------
-- 4. Keep updated_at fresh on every write
-- -----------------------------------------------------------------------------
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();


-- -----------------------------------------------------------------------------
-- 5. get_entitlement()  ·  the ONLY thing the app calls
--    Returns the computed entitlement for the signed-in user.
--    program_access already accounts for the 90 day window expiring.
--    Call from the app:  supabase.rpc('get_entitlement')
-- -----------------------------------------------------------------------------
create or replace function public.get_entitlement()
returns table (
  program_access      boolean,
  access_end          timestamptz,
  standard_active     boolean,
  brotherhood_active  boolean
)
language sql
security definer
set search_path = public
as $$
  select
    (p.program_access and (p.access_end is null or now() < p.access_end)) as program_access,
    p.access_end,
    p.standard_active,
    p.brotherhood_active
  from public.profiles p
  where p.id = auth.uid();
$$;

grant execute on function public.get_entitlement() to authenticated;
revoke execute on function public.get_entitlement() from anon;


-- =============================================================================
-- 6. WHAT THE STRIPE WEBHOOK WRITES  (reference only, runs in the Edge Function
--    with the service role key; verify the Stripe signature first; be idempotent)
--
--    Match order: client_reference_id (= the app user id passed at checkout),
--    then stripe_customer_id, then lower(email).
-- =============================================================================

-- checkout.session.completed  ($297 program purchase)
--   update public.profiles set
--     program_access     = true,
--     access_start       = now(),
--     access_end         = now() + interval '90 days',
--     stripe_customer_id  = :customer,
--     referrer_id        = coalesce(:referrer_id, referrer_id),
--     pod_id             = coalesce(:pod_id, pod_id),
--     standard_bearer_id = coalesce(:standard_bearer_id, standard_bearer_id)
--   where id = :client_reference_id;

-- customer.subscription.created / updated  (The Standard or The Brotherhood)
--   -- if the price id is The Standard:
--   update public.profiles set standard_active = (:status in ('active','trialing'))
--   where stripe_customer_id = :customer;
--   -- if the price id is The Brotherhood:
--   update public.profiles set brotherhood_active = (:status in ('active','trialing'))
--   where stripe_customer_id = :customer;

-- customer.subscription.deleted
--   update public.profiles set standard_active = false      where stripe_customer_id = :customer; -- (or brotherhood_active)

-- charge.refunded / refund.created  (revoke + flag Vanguard clawback)
--   update public.profiles set program_access = false where stripe_customer_id = :customer;

-- =============================================================================
-- End of schema.
-- =============================================================================
