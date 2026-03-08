-- 1. Ensure the missing columns exist
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS contact_email TEXT;

ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS saved_food_grams NUMERIC DEFAULT 0;

-- 2. Force PostgREST to refresh its schema cache
-- This is critical for the API to "see" the new columns immediately.
NOTIFY pgrst, 'reload config';
