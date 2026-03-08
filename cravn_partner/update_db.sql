-- Run this in your Supabase SQL Editor to enable Pickup Times

ALTER TABLE public.food_listings
ADD COLUMN IF NOT EXISTS pickup_start timestamp with time zone,
ADD COLUMN IF NOT EXISTS pickup_end timestamp with time zone;
