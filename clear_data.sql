-- ============================================
-- CLEAR ALL DATA (Keep User Logins)
-- Run AFTER complete_schema.sql if you want to reset
-- ============================================

-- Clear in order (respecting foreign keys)
DELETE FROM messages;
DELETE FROM reviews;
DELETE FROM favorites;
DELETE FROM orders;
DELETE FROM food_listings;
DELETE FROM addresses;
DELETE FROM notification_preferences;

-- Reset profile data but keep the record
-- Only reset columns that exist
UPDATE profiles SET
  full_name = NULL,
  phone_verified = FALSE,
  phone_verified_at = NULL,
  avatar_url = NULL,
  host_status = NULL,
  host_verified = FALSE,
  kitchen_name = NULL,
  is_partner_onboarded = FALSE,
  partner_onboarded_at = NULL;

SELECT 'All data cleared! User accounts preserved.' AS status;
