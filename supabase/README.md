# Supabase setup for Crav'n

This app uses Supabase for auth (email/password + Google OAuth), data (food_listings), and storage (listing images).

## 1) Project credentials

Create a Supabase project and note your:

- Project URL
- anon (public) API key

In code, these are currently set in `lib/core/services/supabase_config.dart`.
Replace these with your own values or refactor to load from env using `flutter_dotenv`.

## 2) Enable Google OAuth

In the Supabase Dashboard > Authentication > Providers:

- Enable Google
- Add a Redirect URL:
  - `io.supabase.flutter://login-callback`

On mobile, the app is configured to handle this URL via:

- Android: intent-filter in `android/app/src/main/AndroidManifest.xml`
- iOS: URL scheme in `ios/Runner/Info.plist` (CFBundleURLTypes)

If you choose a different scheme/host, keep them consistent across the dashboard and the two files above.

## 3) Create tables & policies

Run the SQL in `supabase/schema.sql` (e.g., Supabase SQL editor) to create:

- `food_listings` table
- RLS policies

The app writes with the currently authenticated user as `owner_id`. Ensure you are logged in to insert.

## 4) Storage bucket for images

Create a public storage bucket named `listing_images`.

- Path convention: `<owner_id>/<uuid>.jpg`
- If you prefer a private bucket, switch the code to generate signed URLs instead of using `getPublicUrl`.

## 5) Google Maps API Keys

The Android project has a Google Maps API key configured in `AndroidManifest.xml`.
Ensure you also configure iOS if you plan to run on iOS (see Google Maps Flutter docs).

## 6) Data shape used by the app

The app expects these columns in `food_listings`:

- id (uuid, default)
- owner_id (uuid)
- title (text)
- cuisine (text)
- description (text, optional)
- price (int, 0 = free)
- isVeg (bool)
- image (text) – public URL to image
- lat (double)
- lng (double)
- created_at (timestamptz)

Markers on the map only appear when `lat` and `lng` are present.

## 7) Security note

Do not commit your anon key to public repos. Consider moving secrets to a config file ignored by git, or use `flutter_dotenv`.
