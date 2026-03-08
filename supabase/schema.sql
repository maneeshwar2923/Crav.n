-- Supabase schema for Crav'n mobile app
-- Create tables in dependency order (addresses -> listings -> orders)

-- Store multiple saved addresses per user for deliveries/pickups
create table if not exists user_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  label text not null,
  address_line1 text not null,
  address_line2 text,
  city text,
  latitude double precision,
  longitude double precision,
  is_default boolean default false,
  created_at timestamptz default now()
);

alter table user_addresses enable row level security;

create policy "Users manage their addresses" on user_addresses
for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Listings table (named food_listings to match existing code)
-- Adjust pricing currency or add indexes as needed.

create table if not exists food_listings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users(id) on delete set null,
  address_id uuid references user_addresses(id) on delete set null,
  title text not null,
  cuisine text,
  description text,
  price integer default 0, -- 0 means free
  isVeg boolean default true,
  image text, -- public URL to storage object
  lat double precision,
  lng double precision,
  status text default 'pending' check (status in ('pending', 'verified', 'rejected')),
  verified_at timestamptz,
  verifier_id uuid references auth.users(id) on delete set null,
  created_at timestamptz default now()
);

-- Optional: enforce geospatial index for proximity queries
create extension if not exists postgis;
do $$
begin
  if not exists (
    select 1
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'food_listings'
      and indexname = 'food_listings_location_idx'
  ) then
    execute 'create index food_listings_location_idx on food_listings using gist (ST_SetSRID(ST_MakePoint(lng, lat), 4326));';
  end if;
end $$;

-- Enable RLS
alter table food_listings enable row level security;

-- Policies: owners can insert their own listings
create policy "Users can insert their own listings" on food_listings
for insert to authenticated with check (auth.uid() = owner_id);

-- Anyone (authenticated) can read listings
create policy "Authenticated can select listings" on food_listings
for select using (true);

-- Owners can update/delete their listings
create policy "Owners can modify their listings" on food_listings
for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "Owners can delete their listings" on food_listings
for delete using (auth.uid() = owner_id);

-- NOTE: create an admin verification policy in the Supabase dashboard
-- by granting a role (service role or custom JWT claim) permission to
-- update the status/verified fields above.

-- Orders table for profile insights and food-saved tally
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  listing_id uuid references food_listings(id) on delete set null,
  status text default 'pending' check (status in ('pending', 'accepted', 'declined', 'completed')),
  quantity integer default 1,
  saved_food_grams integer default 0,
  contact_email text,
  placed_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table orders enable row level security;

create policy "Users can read their orders" on orders
for select to authenticated using (auth.uid() = user_id);

create policy "Users can insert their orders" on orders
for insert to authenticated with check (auth.uid() = user_id);

create policy "Users can update their orders" on orders
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Hosts can see and manage orders tied to their listings
create policy "Hosts can read orders for their listings" on orders
for select to authenticated using (
  auth.uid() = user_id
  or exists (
    select 1 from food_listings
    where food_listings.id = orders.listing_id
      and food_listings.owner_id = auth.uid()
  )
);

create policy "Hosts can update orders for their listings" on orders
for update to authenticated using (
  auth.uid() = user_id
  or exists (
    select 1 from food_listings
    where food_listings.id = orders.listing_id
      and food_listings.owner_id = auth.uid()
  )
) with check (
  auth.uid() = user_id
  or exists (
    select 1 from food_listings
    where food_listings.id = orders.listing_id
      and food_listings.owner_id = auth.uid()
  )
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

do $$
begin
  if not exists (
    select 1 from pg_trigger
    where tgname = 'orders_set_updated_at'
  ) then
    create trigger orders_set_updated_at
      before update on orders
      for each row
      execute procedure public.set_updated_at();
  end if;
end $$;


-- Storage bucket for listing images (create via dashboard if not exists):
-- Name: listing_images (make it public or add signed URL flow)
-- Folder structure: <owner_id>/<uuid>.jpg

-- ---------------------------------------------------------------------------
-- Profiles metadata and host onboarding
-- ---------------------------------------------------------------------------

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  role text default 'consumer' check (role in ('consumer', 'host', 'admin')),
  phone_number text,
  host_status text default 'none' check (host_status in ('none', 'pending', 'approved', 'rejected')),
  host_verified boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table profiles enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
      and polname = 'Users can manage their profile'
  ) then
    create policy "Users can manage their profile" on profiles
      for all to authenticated using (auth.uid() = id) with check (auth.uid() = id);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_trigger
    where tgname = 'profiles_set_updated_at'
  ) then
    create trigger profiles_set_updated_at
      before update on profiles
      for each row
      execute procedure public.set_updated_at();
  end if;
end $$;

-- Ensure new columns exist if table was previously created
alter table profiles add column if not exists phone_number text;
alter table profiles add column if not exists role text;
alter table profiles add column if not exists host_status text;
alter table profiles add column if not exists host_verified boolean;

-- ---------------------------------------------------------------------------
-- Host verification workflow
-- ---------------------------------------------------------------------------

create table if not exists host_verifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
  submitted_at timestamptz default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  business_name text,
  contact_name text,
  contact_phone text,
  kitchen_address text,
  document_urls text[],
  notes text
);

alter table host_verifications enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'host_verifications'
      and polname = 'Hosts manage their verification'
  ) then
    create policy "Hosts manage their verification" on host_verifications
      for select using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'host_verifications'
      and polname = 'Hosts can submit verification'
  ) then
    create policy "Hosts can submit verification" on host_verifications
      for insert with check (auth.uid() = user_id);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'host_verifications'
      and polname = 'Hosts can update their pending verification'
  ) then
    create policy "Hosts can update their pending verification" on host_verifications
      for update using (auth.uid() = user_id and status = 'pending')
      with check (auth.uid() = user_id);
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Food safety attestations tied to listings
-- ---------------------------------------------------------------------------

create table if not exists food_safety_checks (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references food_listings(id) on delete cascade,
  submitted_by uuid not null references auth.users(id) on delete cascade,
  status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
  prepared_on date,
  expires_on date,
  ingredients text,
  hygiene_notes text,
  photo_urls text[],
  submitted_at timestamptz default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewer_notes text
);

alter table food_safety_checks enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'food_safety_checks'
      and polname = 'Hosts manage safety checks for their listings'
  ) then
    create policy "Hosts manage safety checks for their listings" on food_safety_checks
      for select using (
        auth.uid() = submitted_by
        or exists (
          select 1 from food_listings
          where food_listings.id = food_safety_checks.listing_id
            and food_listings.owner_id = auth.uid()
        )
      )
      with check (
        auth.uid() = submitted_by
      );
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'food_safety_checks'
      and polname = 'Hosts submit safety checks'
  ) then
    create policy "Hosts submit safety checks" on food_safety_checks
      for insert with check (auth.uid() = submitted_by);
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Order pickup confirmations and extended state handling
-- ---------------------------------------------------------------------------

alter table orders add column if not exists contact_phone text;
alter table orders add column if not exists pickup_confirmed_at timestamptz;
alter table orders add column if not exists pickup_confirmed_by uuid references auth.users(id) on delete set null;
alter table orders add column if not exists pickup_confirmation_method text;
alter table orders add column if not exists pickup_code text;

alter table orders drop constraint if exists orders_status_check;
alter table orders add constraint orders_status_check
  check (status in ('pending', 'accepted', 'declined', 'ready_for_pickup', 'collected', 'completed', 'cancelled'));

-- ---------------------------------------------------------------------------
-- Reviews and ratings for listings
-- ---------------------------------------------------------------------------

create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  listing_id uuid not null references food_listings(id) on delete cascade,
  reviewer_id uuid not null references auth.users(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text,
  is_public boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table reviews enable row level security;

create unique index if not exists reviews_unique_order on reviews(order_id);

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'reviews'
      and polname = 'Users manage their reviews'
  ) then
    create policy "Users manage their reviews" on reviews
      for all using (auth.uid() = reviewer_id) with check (auth.uid() = reviewer_id);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'reviews_set_updated_at'
  ) then
    create trigger reviews_set_updated_at
      before update on reviews
      for each row
      execute procedure public.set_updated_at();
  end if;
end $$;

-- Aggregated view for listing metrics (non-materialized for now)
create or replace view listing_review_stats as
  select
    listing_id,
    avg(rating)::numeric(10,2) as average_rating,
    count(*) as review_count,
    max(created_at) as last_review_at
  from reviews
  group by listing_id;

-- ---------------------------------------------------------------------------
-- Notification infrastructure
-- ---------------------------------------------------------------------------

create table if not exists user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text,
  device_token text not null,
  metadata jsonb,
  last_seen_at timestamptz default now()
);

alter table user_devices enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'user_devices'
      and polname = 'Users manage their devices'
  ) then
    create policy "Users manage their devices" on user_devices
      for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;
end $$;

create unique index if not exists user_devices_token_idx on user_devices(device_token);

create table if not exists notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null,
  enabled boolean default true,
  updated_at timestamptz default now()
);

alter table notification_preferences enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'notification_preferences'
      and polname = 'Users manage notification preferences'
  ) then
    create policy "Users manage notification preferences" on notification_preferences
      for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;
end $$;

create unique index if not exists notification_preferences_user_category
  on notification_preferences(user_id, category);

-- ---------------------------------------------------------------------------
-- Host analytics helper view (orders + reviews per listing)
-- ---------------------------------------------------------------------------

create or replace view host_listing_metrics as
  select
    fl.owner_id,
    fl.id as listing_id,
    fl.title,
    count(o.id) filter (where o.status in ('accepted','ready_for_pickup','collected','completed')) as total_orders,
    sum(o.quantity) as total_portions,
    sum(coalesce(o.saved_food_grams, 0)) as total_saved_food_grams,
    sum(coalesce(o.quantity, 0) * coalesce(fl.price, 0)) as gross_revenue,
    coalesce(lrs.average_rating, 0) as average_rating,
    coalesce(lrs.review_count, 0) as review_count
  from food_listings fl
  left join orders o on o.listing_id = fl.id
  left join listing_review_stats lrs on lrs.listing_id = fl.id
  group by fl.owner_id, fl.id, fl.title, lrs.average_rating, lrs.review_count;
