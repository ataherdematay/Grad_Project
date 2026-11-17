# Backend status and open decisions

Backend = **Supabase** (hosted PostgreSQL, free plan). Database files and setup guide: `database/` (start with `database/00_README_SETUP.md`).

## Done
- Database schema, business rules (functions), security rules (RLS), storage buckets, TR/EN categories. 78 automated checks pass on a local PostgreSQL (`database/test/run_all.sh`).
- Flutter data layer (this branch): `mobile/lib/core/supabase/`. The app keeps using mock data unless it is started with the Supabase keys:
  `flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon key>`
- **Not compiled or run yet** (written without a Flutter SDK). First step for whoever has Flutter: `flutter pub get`, `flutter analyze`, fix anything it reports.

## Open decisions (remind the team before these steps)
| # | Decision | Needed for | Owner |
|---|---|---|---|
| 1 | Payment provider (test mode). Until chosen, `acceptOffer` sends placeholder values | 3D Secure screens, `fn_accept_offer` | Alaa to share |
| 2 | Google login: create a Google Cloud OAuth client (and one client ID per platform) | "Continue with Google" | Alaa / Hakan |
| 3 | Does the app call Supabase directly or go through Hakan's backend? | Who calls the `fn_*` functions | Hakan |
| 4 | Where the admin site and landing page are hosted (free: Vercel / Netlify / GitHub Pages) | Admin portal, website | team |
| 5 | iOS builds without a Mac (CI such as GitHub Actions macOS or Codemagic; installing on a real iPhone needs an Apple Developer account) | iOS release | team |
| 6 | Login screens: the app still has phone number + SMS code screens (s02/s03), but the chosen login is Google or email + password. These screens must be redesigned (and the HTML prototype updated, plus the RAD). | Real login | Ata / Alaa |

## Known gaps in the app (not done yet)
- TR/EN: the Flutter app has no localization yet (only the HTML prototype is translated). Models also contain Turkish-only labels (`labelTr`).
- Photos: uploading to the `job-photos` bucket is not written yet (marked `TODO(photos)`).
- App has no "disputed" job state, appointment, notification, complaint or live-location features in the data layer yet. The database functions for them exist (see `database/06_App_and_API_Mapping.md`).
- Job descriptions must be at least 10 characters (database rule).
