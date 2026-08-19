-- ============================================================
-- LUMINA FLIPS — Properties table + Admin access
-- Run this in the SAME Supabase project you already set up
-- (the one used for the investor portal).
-- ============================================================

create table properties (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,              -- used in the URL, e.g. "190k-flip"
  name text not null,                     -- "The 190K Flip"
  location text,                          -- "Orlando, FL area"
  status text default 'available',        -- available | contract | sold
  beds int,
  baths int,
  sqft text,
  timeline text,                          -- "~90 days"
  purchase_price numeric,
  sale_price numeric,
  story text,
  passcode text,                          -- what unlocks the address/full gallery
  real_address text,
  zillow_url text,
  public_photos text[],                   -- array of photo URLs, shown to everyone
  gated_photos text[],                    -- array of photo URLs, shown after passcode
  is_published boolean default false,     -- only published properties show on the site
  created_at timestamptz default now()
);

alter table properties enable row level security;

-- Anyone can VIEW published properties (this is your public website)
create policy "public can view published properties" on properties
  for select using (is_published = true);

-- Only YOU (logged into the admin panel) can add/edit/delete
create policy "admin can manage properties" on properties
  for all using (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL_HERE')
  with check (auth.jwt() ->> 'email' = 'YOUR_ADMIN_EMAIL_HERE');

-- ============================================================
-- IMPORTANT: Before running this, replace YOUR_ADMIN_EMAIL_HERE
-- (both places) with the actual email you'll log into the admin
-- panel with. This is what locks editing to just you.
-- ============================================================
