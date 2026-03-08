-- Add verified_at column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'food_listings' AND column_name = 'verified_at') THEN
        ALTER TABLE public.food_listings ADD COLUMN verified_at timestamp with time zone;
    END IF;
END $$;

-- Add images array column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'food_listings' AND column_name = 'images') THEN
        ALTER TABLE public.food_listings ADD COLUMN images text[];
    END IF;
END $$;
