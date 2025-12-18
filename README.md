# Medicines for Children · Flutter Port

This repository hosts the Flutter implementation of the Medicines for Children mobile and web client. The project is currently at **Milestone 0 (bootstrap)** with Firebase-ready dependencies, baseline routing, and tooling in place for future feature work.

## Prerequisites

- Flutter 3.27.0+ with Dart 3.8+
- Xcode 15 / Android Studio Iguana+ for platform builds
- Firebase CLI (optional for emulator work)

## Quick start

```bash
# install dependencies
make get

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
- `lib/features/` – feature modules (currently splash placeholder)
- `lib/bootstrap.dart` – top-level initialization entry point
- `test/` – widget/unit tests seeded with a splash smoke test

## Environment configuration

Environment variables live under `env/.env.<flavor>`. Sample files with placeholder values are already committed:

- `env/.env.dev`
- `env/.env.staging`
- `env/.env.prod`

Replace the placeholder values with your Firebase project IDs, storage buckets, and backend URLs (never commit secrets). Flavor-specific entrypoints in `lib/main_<flavor>.dart` load the corresponding file.

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

Milestone 1 will focus on wiring Firebase environments, flavor configuration, and higher-level navigation scaffolding based on the specification in `roadmap.md`.
