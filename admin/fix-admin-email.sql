-- ============================================================
-- Run this in Supabase SQL Editor to fix/confirm the admin email.
-- Safe to run even if you already ran the first schema script —
-- this just replaces the old policy with the correct email.
-- ============================================================

drop policy if exists "admin can manage properties" on properties;

create policy "admin can manage properties" on properties
  for all using (auth.jwt() ->> 'email' = 'javierflmx@gmail.com')
  with check (auth.jwt() ->> 'email' = 'javierflmx@gmail.com');
