-- ============================================
-- FIX MISSING COLUMNS IN PROFILES TABLE
-- Run this first to ensure all columns exist
-- ============================================

-- Add all potentially missing columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_number TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS host_status TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS host_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS kitchen_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_partner_onboarded BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS partner_onboarded_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Add missing columns to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS host_id UUID;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pickup_time TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Add missing columns to food_listings
ALTER TABLE food_listings ADD COLUMN IF NOT EXISTS is_veg BOOLEAN DEFAULT FALSE;
ALTER TABLE food_listings ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

SELECT 'All missing columns added!' AS status;
