-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- DROP TABLES (Clean Slate)
drop view if exists public.host_listing_metrics;
drop table if exists public.reviews cascade;
drop table if exists public.orders cascade;
drop table if exists public.food_safety_checks cascade;
drop table if exists public.food_listings cascade;
drop table if exists public.user_addresses cascade;
drop table if exists public.profiles cascade;

-- Profiles Table (Hosts/Users)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  description text,
  role text default 'user', -- 'host' or 'user'
  host_status text default 'pending', -- 'pending', 'approved', 'rejected'
  host_verified boolean default false,
  phone text,
  opening_time text,
  closing_time text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Food Listings Table
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
  status text default 'active', -- 'active', 'inactive', 'sold_out'
  lat double precision,
  lng double precision,
  address text,
  address_id uuid, -- Optional link to user_addresses
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Orders Table
create table if not exists public.orders (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete set null, -- Customer
  listing_id uuid references public.food_listings(id) on delete set null,
  quantity integer not null,
  total_price numeric not null,
  status text default 'pending', -- 'pending', 'confirmed', 'ready_for_pickup', 'completed', 'cancelled'
  placed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Reviews Table
create table if not exists public.reviews (
  id uuid default uuid_generate_v4() primary key,
  order_id uuid references public.orders(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade, -- Reviewer
  listing_id uuid references public.food_listings(id) on delete cascade,
  rating numeric not null,
  comment text,
  host_reply text,
  replied_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Food Safety Checks Table
create table if not exists public.food_safety_checks (
  id uuid default uuid_generate_v4() primary key,
  listing_id uuid references public.food_listings(id) on delete cascade,
  status text default 'pending', -- 'pending', 'approved', 'rejected'
  submitted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  reviewed_at timestamp with time zone
);

-- User Addresses Table (Optional but good to have)
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

-- Host Listing Metrics View (Optional, for simplified querying)
create or replace view public.host_listing_metrics as
select
  fl.id as listing_id,
  fl.owner_id,
  fl.title,
  coalesce(sum(o.total_price), 0) as gross_revenue,
  count(o.id) as total_orders,
  coalesce(sum(o.quantity), 0) as total_portions,
  coalesce(sum(o.quantity) * 400, 0) as total_saved_food_grams, -- Assuming 400g per portion
  coalesce(avg(r.rating), 0) as average_rating,
  count(r.id) as review_count
from public.food_listings fl
left join public.orders o on fl.id = o.listing_id and o.status = 'completed'
left join public.reviews r on fl.id = r.listing_id
group by fl.id;

-- Enable Row Level Security (RLS)
alter table public.profiles enable row level security;
alter table public.food_listings enable row level security;
alter table public.orders enable row level security;
alter table public.reviews enable row level security;
alter table public.food_safety_checks enable row level security;
alter table public.user_addresses enable row level security;

-- Create Policies (Simplified for development - allow all access for authenticated users)
-- PROFILES
create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);

-- FOOD LISTINGS
create policy "Listings are viewable by everyone." on public.food_listings for select using (true);
create policy "Hosts can insert their own listings." on public.food_listings for insert with check (auth.uid() = owner_id);
create policy "Hosts can update their own listings." on public.food_listings for update using (auth.uid() = owner_id);
create policy "Hosts can delete their own listings." on public.food_listings for delete using (auth.uid() = owner_id);

-- ORDERS
create policy "Users can view their own orders." on public.orders for select using (auth.uid() = user_id);
create policy "Hosts can view orders for their listings." on public.orders for select using (
  exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
);
create policy "Users can create orders." on public.orders for insert with check (auth.uid() = user_id);
create policy "Hosts can update order status." on public.orders for update using (
  exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
);

-- REVIEWS
create policy "Reviews are viewable by everyone." on public.reviews for select using (true);
create policy "Users can create reviews." on public.reviews for insert with check (auth.uid() = user_id);
create policy "Hosts can reply to reviews." on public.reviews for update using (
  exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
);

-- SAFETY CHECKS
create policy "Hosts can view their safety checks." on public.food_safety_checks for select using (
  exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
);
create policy "Hosts can create safety checks." on public.food_safety_checks for insert with check (
  exists (select 1 from public.food_listings fl where fl.id = listing_id and fl.owner_id = auth.uid())
);

-- USER ADDRESSES
create policy "Users can view their own addresses." on public.user_addresses for select using (auth.uid() = user_id);
create policy "Users can insert their own addresses." on public.user_addresses for insert with check (auth.uid() = user_id);
create policy "Users can update their own addresses." on public.user_addresses for update using (auth.uid() = user_id);
create policy "Users can delete their own addresses." on public.user_addresses for delete using (auth.uid() = user_id);
