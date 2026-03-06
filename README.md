# Crav.n
# 🍞 Crav'n — Food Waste Reduction App

**Crav'n** is a mobile application designed to reduce food waste by connecting local bakeries and food outlets in Auroville with conscious consumers. Unsold food items are listed at discounted prices, helping businesses minimize waste while offering affordable options to buyers.

> Built with Flutter • Powered by Supabase • Designed in Figma

---

## ✨ Features

- **Browse & Discover** — Explore nearby bakeries and food outlets on an interactive Google Map
- **Real-Time Listings** — View available surplus food items with live stock updates
- **User Authentication** — Secure sign-up/login via Supabase Auth & Firebase
- **Order & Reserve** — Place orders for discounted items before they're gone
- **Push Notifications** — Get notified about new deals via Firebase Cloud Messaging
- **Profile Management** — Manage your account, orders, and preferences
- **Partner Dashboard** — Separate web panel for food outlets to manage listings
- **Admin Dashboard** — Web-based admin panel for platform management

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Mobile App** | Flutter (Dart) |
| **Backend** | Supabase (PostgreSQL, Auth, Storage) |
| **Auth** | Supabase Auth + Firebase Auth |
| **Notifications** | Firebase Cloud Messaging |
| **Maps** | Google Maps Flutter |
| **Admin Panel** | React + Vite (web) |
| **Partner Panel** | React + Vite (web) |
| **Design** | Figma → Flutter conversion |

---

## 📁 Project Structure

```
Crav'n/
├── lib/                    # Flutter app source code
│   ├── core/               # Services, models, providers, theme
│   ├── features/           # Feature modules (home, auth, orders, etc.)
│   ├── routes/             # App routing
│   ├── shared/             # Shared widgets
│   └── main.dart           # App entry point
├── cravn_admin/            # Admin dashboard (React + Vite)
├── cravn_partner/          # Partner dashboard (React + Vite)
├── assets/                 # Images, fonts, map styles
├── supabase/               # Supabase config & migrations
├── android/                # Android platform files
├── ios/                    # iOS platform files
├── *.sql                   # Database schema & migration scripts
└── pubspec.yaml            # Flutter dependencies
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (≥2.18.0)
- Dart SDK
- Node.js & npm (for admin/partner panels)
- Supabase project (with API keys)
- Firebase project (for push notifications)
- Google Maps API key

### Flutter App Setup

```bash
# Install Flutter dependencies
flutter pub get

# Create a .env file from the example
cp .env.example .env
# Fill in your Supabase URL, API keys, and Google Maps key

# Run the app
flutter run
```

### Admin Panel

```bash
cd cravn_admin
npm install
npm run dev
```

### Partner Panel

```bash
cd cravn_partner
npm install
npm run dev
```

---

## 🗄 Database

SQL schema files are included in the root directory:

- `complete_schema.sql` — Full database schema
- `fix_missing_columns.sql` — Migration patches
- `otp_notifications_schema.sql` — OTP & notifications tables
- `clear_data.sql` — Data cleanup script

---

## 📸 Design

Original Figma design: [Crav'n App Design](https://www.figma.com/design/svxJWzKmA0Pa2x4EqsZ129/Crav-n-App-Design-Updates)

---

## 📄 License

This project is for academic/personal use.
