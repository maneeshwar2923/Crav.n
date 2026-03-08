-- ============================================
-- CRAV'N COMPLETE DATABASE SCHEMA
-- Run this ONCE in Supabase SQL Editor to set up everything
-- ============================================

-- ============================================
-- 1. PROFILES TABLE (extends auth.users)
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  phone_number TEXT,
  phone_verified BOOLEAN DEFAULT FALSE,
  phone_verified_at TIMESTAMPTZ,
  avatar_url TEXT,
  host_status TEXT,
  host_verified BOOLEAN DEFAULT FALSE,
  kitchen_name TEXT,
  is_partner_onboarded BOOLEAN DEFAULT FALSE,
  partner_onboarded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add missing columns if table exists
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified_at TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS kitchen_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_partner_onboarded BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS partner_onboarded_at TIMESTAMPTZ;

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Anyone can view profiles" ON profiles;

CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. FOOD LISTINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS food_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cuisine TEXT,
  price DECIMAL(10,2) DEFAULT 0,
  quantity INTEGER DEFAULT 1,
  image_url TEXT,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  address TEXT,
  is_veg BOOLEAN DEFAULT FALSE,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE food_listings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active listings" ON food_listings;
DROP POLICY IF EXISTS "Owners can manage listings" ON food_listings;

CREATE POLICY "Anyone can view active listings" ON food_listings FOR SELECT USING (true);
CREATE POLICY "Owners can manage listings" ON food_listings FOR ALL USING (auth.uid() = owner_id);

-- ============================================
-- 3. ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES food_listings(id) ON DELETE SET NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  host_id UUID,
  quantity INTEGER DEFAULT 1,
  total_price DECIMAL(10,2),
  status TEXT DEFAULT 'pending',
  pickup_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add missing columns if table exists
ALTER TABLE orders ADD COLUMN IF NOT EXISTS host_id UUID;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS pickup_time TIMESTAMPTZ;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own orders" ON orders;
DROP POLICY IF EXISTS "Users can create orders" ON orders;
DROP POLICY IF EXISTS "Participants can update orders" ON orders;

CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id OR auth.uid() = host_id);
CREATE POLICY "Users can create orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Participants can update orders" ON orders FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = host_id);

-- ============================================
-- 4. FAVORITES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID REFERENCES food_listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, listing_id)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own favorites" ON favorites;
CREATE POLICY "Users manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 5. REVIEWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  listing_id UUID REFERENCES food_listings(id) ON DELETE SET NULL,
  reviewer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  host_id UUID,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view reviews" ON reviews;
DROP POLICY IF EXISTS "Users can create reviews" ON reviews;

CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- ============================================
-- 6. MESSAGES TABLE (Chat)
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Participants can view messages" ON messages;
DROP POLICY IF EXISTS "Users can send messages" ON messages;
DROP POLICY IF EXISTS "Receiver can mark as read" ON messages;

CREATE POLICY "Participants can view messages" ON messages FOR SELECT 
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send messages" ON messages FOR INSERT 
  WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Receiver can mark as read" ON messages FOR UPDATE 
  USING (auth.uid() = receiver_id);

-- ============================================
-- 7. NOTIFICATION PREFERENCES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  order_updates BOOLEAN DEFAULT TRUE,
  new_listings_nearby BOOLEAN DEFAULT TRUE,
  promotional BOOLEAN DEFAULT FALSE,
  chat_messages BOOLEAN DEFAULT TRUE,
  partner_order_alerts BOOLEAN DEFAULT TRUE,
  partner_review_alerts BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own notification preferences" ON notification_preferences;
CREATE POLICY "Users manage own notification preferences" ON notification_preferences 
  FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 8. ADDRESSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  label TEXT,
  address_line TEXT NOT NULL,
  city TEXT,
  state TEXT,
  postal_code TEXT,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own addresses" ON addresses;
CREATE POLICY "Users manage own addresses" ON addresses FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 9. AUTO-CREATE PROFILE ON SIGNUP (Trigger)
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  
  INSERT INTO public.notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT 'Database schema created successfully!' AS status;
