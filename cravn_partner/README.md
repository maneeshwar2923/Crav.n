# Crav'n Partner

Host console for managing Crav'n listings, orders, and verification.

## Local setup

1. Copy `assets/env/.env.example` to `assets/env/.env` and paste your Supabase `SUPABASE_URL` and `SUPABASE_ANON_KEY` values. Alternatively pass them at runtime with `--dart-define`.
2. Install dependencies with `flutter pub get`.
3. Run the app: `flutter run` (append `--dart-define` values if you did not create the `.env`).

## Troubleshooting

- A yellow notice on the login screen means fallback Supabase credentials are in use; double-check the `.env` file or `--dart-define` flags.
- `SocketException: Failed host lookup` indicates the Supabase domain could not be reached. Confirm the project ref is correct and the device has network access.
- Regenerate launcher icons after updating the logo by running `flutter pub run flutter_launcher_icons`.
