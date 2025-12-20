# Medicines for Children · Flutter Port
![Coverage](https://img.shields.io/badge/coverage-32.7%25-yellow)

This repository hosts the Flutter implementation of the Medicines for Children mobile and web client. The build now targets **Milestone 5 (Sharing Centre & Backend API Integration)** with secondary-carer flows and share management delivered.

## Current status

- ✅ Tooling and offline-first profile storage are live.
- ✅ Local profile repository + Riverpod controller + GoRouter guard redirect users between splash/login/onboarding/home.
- ✅ Splash, onboarding, and home placeholders exercise the auth state machine, with profile selection + optional passcode gating.
- ✅ Dedicated signup and multi-step onboarding flows capture primary carer + first-child context, persist onboarding data locally, and promote users into the authenticated shell once complete.
- ✅ Primary carer data hydrates from local storage so the home shell can render immediately.
- ✅ Encrypted export/import supports offline backups that can be stored in personal cloud/USB/email.
- ✅ Multi-child selection, offline CRUD, and notification scheduling are in place.
- 🚧 Remaining Milestone 5 work: harden secondary-carer info view and finish backend-driven deep link hosting.

## Prerequisites

- Flutter 3.27.0+ with Dart 3.8+
- Xcode 15 / Android Studio Iguana+ for platform builds

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

- `Makefile` shortcuts for common tasks (`get`, `gen`, `analyze`, `test`, `run-dev`)
- `analysis_options.yaml` uses `flutter_lints` 5.x; prefer fixing lint violations over suppressing them.
- `roadmap.md` tracks milestone definitions; `spec.md` contains the functional spec used to shape upcoming work.

## Release automation

- `fastlane/` contains TestFlight and Play internal lanes (see `fastlane/README.md` for required env vars).
- `scripts/generate_release_checklist.sh` generates `build/release_checklist.md`.
- Monitoring dashboard guidance lives in `docs/monitoring.md`.

## Next steps

- Finish Milestone 2 polish focused on offline data editing, session edge cases, and secondary-carer deep-link handling.
- Add deep-link handling for secondary-carer tokens and expand tests per `roadmap.md`.
- Move into Milestone 3 (read-only primary experience) once the auth shell is complete.
