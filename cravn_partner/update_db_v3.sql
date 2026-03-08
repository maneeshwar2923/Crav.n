-- Add weight_grams column to food_listings table
ALTER TABLE public.food_listings 
ADD COLUMN IF NOT EXISTS weight_grams NUMERIC DEFAULT 0;

-- Update Request: User wants "save phone number option... add phone number section in profile"
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS phone TEXT;

-- FIX: Add missing columns to orders table to prevent PGRST204 error
ALTER TABLE public.orders
ADD COLUMN IF NOT EXISTS contact_email TEXT,
ADD COLUMN IF NOT EXISTS saved_food_grams NUMERIC DEFAULT 0;
