# Medicines for Children · Flutter Port

This repository hosts the Flutter implementation of the Medicines for Children mobile and web client. The build now targets **Milestone 2 (Authentication & App Shell)**: Milestones 0–1 (bootstrap + Firebase wiring) are complete, the auth domain/controller stack is implemented, and guarded navigation with placeholder screens is available for iterative UX work.

## Current status

- ✅ Tooling, env management, and Firebase configuration hooks are live.
- ✅ Auth repository (Firebase + mock), Riverpod controller, and GoRouter guard redirect users between splash/login/onboarding/home.
- ✅ Splash, onboarding, and home placeholders exercise the auth state machine, while the login screen now includes validated forms, loading states, and a built-in password reset trigger.
- ✅ Dedicated signup and multi-step onboarding flows capture primary carer + first-child context, persist onboarding data locally, and promote users into the authenticated shell once complete.
- ✅ Dev flavor auto-authenticates against the mock repository so you can work on inner UI without real credentials.
- ✅ Remember-me credential caching and biometric quick login are wired via secure storage/local_auth for parity with the iOS baseline.
- ✅ Primary carer data now hydrates from secure local cache so the home shell can render immediately while remote data refreshes in the background.
- 🚧 Remaining Milestone 2 work: deeper Firebase-backed auth/data wiring plus secondary-carer deep links.

## Prerequisites

- Flutter 3.27.0+ with Dart 3.8+
- Xcode 15 / Android Studio Iguana+ for platform builds
- Firebase CLI (optional for emulator work)

## Quick start

```bash
# install dependencies
make get

# (re)generate freezed/json_serializable outputs
make gen

# run format, analyzer and tests
make format
make analyze
make test

# launch the dev flavor (uses lib/main_dev.dart)
make run-dev

# launch staging/prod flavors
make run-staging
make run-prod
```

## Project layout

- `lib/app/` – app shell, router, configuration
- `lib/core/` – cross-cutting utilities (theme, environment helpers, etc.)
- `lib/features/` – feature modules (splash, auth/login/onboarding/home placeholders, future pods)
- `lib/bootstrap.dart` – top-level initialization entry point
- `test/` – widget/unit tests seeded with a splash smoke test

## Environment configuration

Environment variables live under `env/.env.<flavor>`. Sample files with placeholder values are already committed:

- `env/.env.dev`
- `env/.env.staging`
- `env/.env.prod`

Replace the placeholder values with your Firebase project IDs, storage buckets, and backend URLs (never commit secrets). Flavor-specific entrypoints in `lib/main_<flavor>.dart` load the corresponding file.

- `ENABLE_FIREBASE` can be set to `false` (default for the dev file) to skip Firebase initialization so the shell runs before credentials are available. When disabled, the mock auth repository automatically signs in a placeholder carer so guarded navigation and inner screens can be exercised end-to-end.

### Firebase config

- Run `flutterfire configure` per environment and update `lib/firebase_options.dart` with the generated values.
- Place the matching `google-services.json` under `android/app/src/<flavor>/` and `GoogleService-Info.plist` under `ios/Runner/` flavor folders once those are provisioned.

### API keys

- `SHARED_SCHEDULE_API_BASE_URL` and `SHARED_SCHEDULE_API_KEY` map to the Firebase Functions backend described in `spec.md`.
- The Dio client attaches the `ApiKey` header automatically via `securedApiClientProvider`.

## Tooling

- `Makefile` shortcuts for common tasks (`get`, `gen`, `analyze`, `test`, `run-dev`)
- `analysis_options.yaml` uses `flutter_lints` 5.x; prefer fixing lint violations over suppressing them.
- `roadmap.md` tracks milestone definitions; `spec.md` contains the functional spec used to shape upcoming work.

## Next steps

- Finish Milestone 2 polish focused on Firebase-backed data hydration, session edge cases, and secondary-carer deep-link handling.
- Add deep-link handling for secondary-carer tokens and expand tests per `roadmap.md`.
- Move into Milestone 3 (read-only primary experience) once the auth shell is complete.
