# Bo‘ston Go — Android MVP starter

Flutter starter for a local multi-service platform in Bo‘ston, Uzbekistan.

## Included
- Premium cream / charcoal / champagne-gold interface
- Supabase email sign-up and sign-in
- Home, services, orders and profile navigation
- Supabase SQL starter schema with row-level security
- GitHub Actions workflow to build a release APK

## Configure Supabase
1. Copy `lib/config.example.dart` to `lib/config.dart`.
2. Add your Supabase project URL and publishable/anon key.
3. Never place a service-role key in the mobile app.

Run `flutter pub get` and `flutter run`.

## Build APK
Push to `main` to run GitHub Actions, or start the workflow manually from the Actions tab. Download the `boston-go-android-apk` artifact after a successful run.

## Important
This is an initial MVP starter, not a finished production marketplace. Store onboarding, live product catalogue, cart/checkout, courier/taxi dispatch, payment processing, and admin tools still need implementation and testing.

Author: Abdulboriy Mo‘minjonov
