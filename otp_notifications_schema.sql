-- Phone OTP, Partner Onboarding & Notification Preferences Schema Updates
-- Run this in Supabase SQL Editor

-- 1. Add phone verification columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified_at TIMESTAMPTZ;

-- 2. Add partner onboarding columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS kitchen_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_partner_onboarded BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS partner_onboarded_at TIMESTAMPTZ;

-- 3. Create notification preferences table
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

-- Enable RLS
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Users can view own notification preferences" 
  ON notification_preferences FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification preferences" 
  ON notification_preferences FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification preferences" 
  ON notification_preferences FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create default notification preferences on user signup (trigger)
CREATE OR REPLACE FUNCTION create_default_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created_notification_prefs ON auth.users;
CREATE TRIGGER on_auth_user_created_notification_prefs
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_default_notification_preferences();
