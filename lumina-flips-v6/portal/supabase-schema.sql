-- ============================================================
-- LUMINA FLIPS — Invite-Only Investor Portal
-- Run this once in Supabase: Project → SQL Editor → New Query → paste → Run
-- ============================================================

-- The list of your properties (matches the property pages on the public site)
create table portal_properties (
  id text primary key,
  name text not null
);

insert into portal_properties (id, name) values ('190k-flip', 'The 190K Flip');

-- Invite codes. One code = one use = access to one property.
-- You create these yourself and text/email the code directly to someone.
create table invite_codes (
  code text primary key,
  property_id text references portal_properties(id) not null,
  is_used boolean default false,
  used_by text,
  created_at timestamptz default now()
);

-- Example: create a code for the 190K flip. Change 'FIRSTLOOK25' to whatever
-- you want to hand out, then run this INSERT separately whenever you want
-- a new code (you can run this line by itself, any time).
insert into invite_codes (code, property_id) values ('FIRSTLOOK25', '190k-flip');

-- Who has access to which property, set automatically after a valid signup
create table investor_access (
  email text not null,
  property_id text references portal_properties(id) not null,
  primary key (email, property_id)
);

-- The project timeline you post updates to
create table project_updates (
  id uuid primary key default gen_random_uuid(),
  property_id text references portal_properties(id) not null,
  title text not null,
  body text,
  photo_url text,
  created_at timestamptz default now()
);

-- ============================================================
-- Security rules (RLS) — keeps this a closed circle, not open to everyone
-- ============================================================
alter table portal_properties enable row level security;
alter table invite_codes enable row level security;
alter table investor_access enable row level security;
alter table project_updates enable row level security;

create policy "anyone can see property names" on portal_properties
  for select using (true);

-- Only allows checking an UNUSED code — used codes are invisible to everyone
create policy "check unused invite code" on invite_codes
  for select using (is_used = false);

-- Allows the signup flow to mark a code used (soft rule — see note below)
create policy "mark code as used" on invite_codes
  for update using (is_used = false) with check (is_used = true);

-- Investors only see their OWN access rows, nothing else
create policy "investor sees own access" on investor_access
  for select using (email = auth.jwt() ->> 'email');

-- The signup flow needs to insert one row for the new investor
create policy "signup can grant access" on investor_access
  for insert with check (true);

-- Investors only see updates for properties they were actually granted
create policy "investor sees own project updates" on project_updates
  for select using (
    exists (
      select 1 from investor_access
      where investor_access.property_id = project_updates.property_id
      and investor_access.email = auth.jwt() ->> 'email'
    )
  );

-- ============================================================
-- HOW TO USE THIS DAY TO DAY (no SQL needed after setup):
--
-- Give someone access:
--   Table Editor → invite_codes → Insert row
--   code: anything memorable, property_id: '190k-flip', is_used: false
--   Then text/email them that code directly.
--
-- Post a project update:
--   Table Editor → project_updates → Insert row
--   property_id: '190k-flip', title: "Demo complete", body: "...", 
--   photo_url: (optional, a link to a photo)
-- ============================================================
