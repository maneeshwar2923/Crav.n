-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. PROFILES
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  description text,
  role text default 'user', 
  host_status text default 'pending',
  host_verified boolean default false,
  phone text, -- Added column
  opening_time text,
  closing_time text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Ensure phone exists if table already existed
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;


-- 2. FOOD LISTINGS
create table if not exists public.food_listings (
  id uuid default uuid_generate_v4() primary key,
  owner_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  description text,
  price numeric not null,
  quantity integer default 0,
  portions_available integer default 0,
  image text,
  pickup_start timestamp with time zone,
  pickup_end timestamp with time zone,
  isVeg boolean default false,
  status text default 'active',
  lat double precision,
  lng double precision,
  address text,
  address_id uuid,
  weight_grams numeric default 0, -- Added column
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Ensure weight_grams exists
ALTER TABLE public.food_listings ADD COLUMN IF NOT EXISTS weight_grams NUMERIC DEFAULT 0;


-- 3. ORDERS
create table if not exists public.orders (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete set null, 
  listing_id uuid references public.food_listings(id) on delete set null,
  quantity integer not null,
  total_price numeric not null,
  status text default 'pending', 
  contact_email text, -- Added column
  saved_food_grams numeric default 0, -- Added column
  placed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Ensure new columns exist
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS contact_email TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS saved_food_grams NUMERIC DEFAULT 0;


-- 4. REVIEWS
create table if not exists public.reviews (
  id uuid default uuid_generate_v4() primary key,
  order_id uuid references public.orders(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade, 
  listing_id uuid references public.food_listings(id) on delete cascade,
  rating numeric not null,
  comment text,
  host_reply text,
  replied_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- 5. FOOD SAFETY CHECKS
create table if not exists public.food_safety_checks (
  id uuid default uuid_generate_v4() primary key,
  listing_id uuid references public.food_listings(id) on delete cascade,
  status text default 'pending', 
  submitted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  reviewed_at timestamp with time zone
);


-- 6. USER ADDRESSES
create table if not exists public.user_addresses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  address_line1 text not null,
  address_line2 text,
  city text,
  state text,
  zip_code text,
  lat double precision,
  lng double precision,
  is_default boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- 7. HOST LISTING METRICS VIEW
create or replace view public.host_listing_metrics as
select
  fl.id as listing_id,
  fl.owner_id,
  fl.title,
  coalesce(sum(o.total_price), 0) as gross_revenue,
  count(o.id) as total_orders,
  coalesce(sum(o.quantity), 0) as total_portions,
  coalesce(sum(o.quantity) * 400, 0) as total_saved_food_grams,
  coalesce(avg(r.rating), 0) as average_rating,
  count(r.id) as review_count
from public.food_listings fl
left join public.orders o on fl.id = o.listing_id and o.status = 'completed'
left join public.reviews r on fl.id = r.listing_id
group by fl.id;


-- 8. POLICIES (Idempotent - checks if policy exists before creating to avoid errors would be complex in SQL, 
-- but 'IF NOT EXISTS' for policies isn't standard Postgres. 
-- We will just drop and recreate specifically or assume they exist if tables exist.)

-- Simplest approach for policies:
-- Only create if not exists
DO $$ 
BEGIN
  -- PROFILES
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public profiles are viewable by everyone.') THEN
    create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can insert their own profile.') THEN
    create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own profile.') THEN
    create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);
  END IF;

  -- LISTINGS
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Listings are viewable by everyone.') THEN
        create policy "Listings are viewable by everyone." on public.food_listings for select using (true);
  END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Hosts can insert their own listings.') THEN
        create policy "Hosts can insert their own listings." on public.food_listings for insert with check (auth.uid() = owner_id);
  END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Hosts can update their own listings.') THEN
        create policy "Hosts can update their own listings." on public.food_listings for update using (auth.uid() = owner_id);
  END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Hosts can delete their own listings.') THEN
        create policy "Hosts can delete their own listings." on public.food_listings for delete using (auth.uid() = owner_id);
  END IF;

  -- ORDERS
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view their own orders.') THEN
     create policy "Users can view their own orders." on public.orders for select using (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Hosts can view orders for their listings.') THEN
     create policy "Hosts can view orders for their listings." on public.orders for select using (
      exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
    );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can create orders.') THEN
     create policy "Users can create orders." on public.orders for insert with check (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Hosts can update order status.') THEN
     create policy "Hosts can update order status." on public.orders for update using (
      exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
    );
  END IF;

END $$;

-- FORCE SCHEMA CACHE RELOAD (Fixes PGRST204)
NOTIFY pgrst, 'reload config';
