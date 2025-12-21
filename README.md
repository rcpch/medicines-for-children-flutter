# Medicines for Children · Flutter Port
![Coverage](https://img.shields.io/badge/coverage-32.7%25-yellow)

This repository hosts the Flutter implementation of the Medicines for Children mobile and web client. The app delivers the sharing centre, secondary-carer flows, offline-first storage, and release readiness milestones.

## Current status

- ✅ Tooling and offline-first profile storage are live.
- ✅ Local profile repository + Riverpod controller + GoRouter guard redirect users between splash/login/onboarding/home.
- ✅ Onboarding flows capture primary carer + first-child context, persist onboarding data locally, and promote users into the authenticated shell once complete.
- ✅ Primary carer data hydrates from local storage so the home shell can render immediately.
- ✅ Encrypted export/import supports offline backups that can be stored in personal cloud/USB/email.
- ✅ Multi-child selection, offline CRUD, and notification scheduling are in place.
- ✅ Share centre, secondary-carer experience, and deep-link routing are implemented.
- ✅ QR scan import covers Medicines for Children poster codes, and medicines can store packaging photos.
- ✅ PDF exports can be printed directly from the share centre.

## Prerequisites

- Flutter 3.32.0+ with Dart 3.8+
- Xcode 15 / Android Studio Iguana+ for platform builds

## Quick start

```bash
# install dependencies
flutter pub get

# (re)generate freezed/json_serializable outputs
dart run build_runner build --delete-conflicting-outputs

# run format, analyzer and tests
dart format lib test
flutter analyze
flutter test --coverage

# launch the dev flavor (uses lib/main_dev.dart)
flutter run --flavor dev --target lib/main_dev.dart

# launch staging/prod flavors
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor prod --target lib/main_prod.dart
```

## Project layout

- `lib/app/` – app shell, router, configuration
- `lib/core/` – cross-cutting utilities (theme, environment helpers, etc.)
- `lib/features/` – feature modules (auth, onboarding, home, medicines, schedules, sharing, settings)
- `lib/bootstrap.dart` – top-level initialization entry point
- `test/` – widget/unit tests seeded with a splash smoke test

## Backups

Backups are encrypted. Importing a backup creates a new local profile; you can optionally rename it during import.

## Environment configuration

Shared-schedule API configuration is optional. The app boots without env files (values default to empty strings). If you need the backend integration:

- Add `env/.env.dev`, `env/.env.staging`, and/or `env/.env.prod` locally (do not commit secrets).
- Register those files under the `assets` section in `pubspec.yaml`.
- The flavor entrypoints in `lib/main_<flavor>.dart` load the matching file via `dotenv`.

### API keys

- `SHARED_SCHEDULE_API_BASE_URL` and `SHARED_SCHEDULE_API_KEY` map to the shared schedule backend described in `spec.md`.
- The Dio client attaches the `ApiKey` header automatically via `securedApiClientProvider`.
- Optional update prompt config:
  - `LATEST_APP_VERSION` and `MINIMUM_APP_VERSION` control update prompts.
  - `APP_UPDATE_URL` is copied to clipboard for update instructions.
- Optional telemetry prompt config:
  - `TELEMETRY_CONSENT_ENABLED` set to `true` to show the analytics consent dialog.

## Deep links (App Links / Universal Links)

The app routes secondary-carer links to `/auth/:token` and `/shared-schedule/:apiId`. Configure platform link domains:

- Android: update `appLinkHost` in `android/app/build.gradle.kts` to your link host.
- iOS: update `applinks:example.com` in `ios/Runner/Runner.entitlements`.

## Tooling

- `analysis_options.yaml` uses `flutter_lints` 5.x; prefer fixing lint violations over suppressing them.
- `roadmap.md` tracks milestone definitions; `spec.md` contains the functional spec used to shape upcoming work.

## Release automation

- `fastlane/` contains TestFlight and Play internal lanes (see `fastlane/README.md` for required env vars).
- `scripts/generate_release_checklist.sh` generates `build/release_checklist.md`.
- Monitoring dashboard guidance lives in `docs/monitoring.md`.

## Next steps

- Expand integration coverage for multi-child flows and backup import validation.
- Harden platform deep-link configuration for production hosts.
- Continue iteration from `roadmap.md` as new milestones are added.
