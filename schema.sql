-- ============================================================
--  CASEWRIGHT — Supabase database schema
--  Run this once in the Supabase SQL Editor (see SETUP.md step 3)
-- ============================================================

-- Cases: one ISO 8800 assurance case per row, owned by a user.
create table if not exists public.cases (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  -- element / scope
  proj         text default '',
  name         text default '',
  func         text default '',
  asil         text default '',
  rtype        text default '',
  role         text default '',
  -- structured data stored as JSON (odd dimensions + evidence register)
  odd          jsonb default '[]'::jsonb,
  evidence     jsonb default '[]'::jsonb,
  -- computed snapshot (so a list view can show readiness without recompute)
  readiness    int  default 0,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Keep updated_at fresh on every change.
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_touch on public.cases;
create trigger trg_touch before update on public.cases
  for each row execute function public.touch_updated_at();

-- ============================================================
--  Row-Level Security: each user sees ONLY their own cases.
--  This is the core multi-tenant safety guarantee.
-- ============================================================
alter table public.cases enable row level security;

drop policy if exists "own_select" on public.cases;
create policy "own_select" on public.cases
  for select using (auth.uid() = user_id);

drop policy if exists "own_insert" on public.cases;
create policy "own_insert" on public.cases
  for insert with check (auth.uid() = user_id);

drop policy if exists "own_update" on public.cases;
create policy "own_update" on public.cases
  for update using (auth.uid() = user_id);

drop policy if exists "own_delete" on public.cases;
create policy "own_delete" on public.cases
  for delete using (auth.uid() = user_id);

-- Helpful index for listing a user's cases newest-first.
create index if not exists idx_cases_user_updated
  on public.cases(user_id, updated_at desc);
