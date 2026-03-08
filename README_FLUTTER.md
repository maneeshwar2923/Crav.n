Crav'n — Figma React -> Flutter conversion

What this workspace contains

- A converted `lib/` folder containing Flutter equivalents for the React/Figma export under `src/`.
- Theme and core widgets under `lib/core/`.
- Feature screens under `lib/features/` grouped by feature (home, host, shared widgets).
- Routes are registered in `lib/routes/app_routes.dart`.

Quick mapping (high level)

- React `src/screens/*` -> `lib/features/<feature>/presentation/screens/*`

  - `SplashScreen.tsx` -> `lib/features/home/presentation/screens/splash_screen.dart`
  - `OnboardingScreens.tsx` -> `lib/features/home/presentation/screens/onboarding_screens.dart`
  - `HomeScreen.tsx` -> `lib/features/home/presentation/screens/home_screen.dart`
  - `FoodDetailScreen.tsx` -> `lib/features/home/presentation/screens/food_detail_screen.dart`
  - `CreateListingScreen.tsx` -> `lib/features/host/presentation/screens/create_listing_screen.dart`
  - `MapViewScreen.tsx` -> `lib/features/home/presentation/screens/map_view_screen.dart`
  - `ChatScreen.tsx` -> `lib/features/home/presentation/screens/chat_screen.dart`
  - `OrdersScreen.tsx` -> `lib/features/home/presentation/screens/orders_screen.dart`
  - `ProfileScreen.tsx` -> `lib/features/home/presentation/screens/profile_screen.dart`

- Reusable components in `src/components/` and `src/components/ui/` -> `lib/core/widgets/*` or `lib/features/shared/widgets/*`.

What I created/converted (high level)

- `lib/core/theme/` — colors and Material 3 theme using primary #006D3B.
- `lib/core/widgets/` — many placeholder and implemented widgets (buttons, cards, logo, appbar, bottom nav, etc.).
- `lib/features/.../presentation/screens/` — screen scaffolds for all app screens.
- `lib/routes/app_routes.dart` — routes registration.
- `lib/main.dart` — app entrypoint; starts at splash screen.
- `pubspec.yaml` — minimal Flutter manifest (add assets and fonts as needed).

How to run locally (PowerShell, Windows)

1. Install Flutter (if not already): https://flutter.dev/docs/get-started/install

2. Create or open a Flutter project and copy this `lib/` into it. If starting fresh:

```powershell
flutter create cravn_flutter
cd cravn_flutter
# Replace lib/ with the lib/ created in this workspace
```

3. Copy `pubspec.yaml` entries (or replace project's `pubspec.yaml`) and run:

```powershell
flutter pub get
flutter analyze
flutter run -d <device-id>
```

Notes and next steps

- Visual polish: I created placeholders and simple implementations; to match Figma exactly we'll need exported fonts and assets (logo, images, SVGs). Provide them and I will wire them into `pubspec.yaml` and replace placeholders.
- Platform integrations: MapView uses a placeholder; if you want real maps, I can integrate `google_maps_flutter` or `flutter_map` and wire API keys.
- Behavior: I scaffolded navigation and widgets but didn't implement network/data logic—those need to be added according to your backend.
- Tests: I didn't add unit/widget tests yet; I can add basic tests for key widgets.

If you want me to continue, pick one:

- "Refine visuals" — I'll apply exact spacing, fonts and asset wiring.
- "Wire functionality" — I'll implement navigation, forms, and sample state management (Provider or Riverpod).
- "Add CI / build" — I'll create GitHub Actions config to build Android/iOS.
