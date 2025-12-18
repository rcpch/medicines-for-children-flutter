# Flutter Implementation Roadmap (Technical)

## Milestone 0 – Repository Bootstrap
- **Technical steps**:
	- Initialize Flutter project (`flutter create medicines_for_children`) with sound null safety, Riverpod/Bloc-ready structure, and separate `lib/app`, `lib/features`, `lib/core` directories.
	- Add core dependencies (Firebase core/auth/firestore/storage/functions, dio/http client, intl, freezed/json_serializable, flutter_local_notifications, go_router, shared_preferences, device_info_plus) and configure build flavors (`dev`, `staging`, `prod`).
	- Set up Melos or mono-repo tooling if needed, add Makefile/justfile with commands for `analyze`, `test`, `format`, `lint`.
	- Configure CI pipeline (GitHub Actions) to run `flutter analyze`, `flutter test`, `flutter build apk --debug` on every pull request.
- **Gate**: `main` branch build passes CI with green analyze/test status; repo contains README explaining run/build steps.

## Milestone 1 – Firebase + Environment Wiring
- **Technical steps**:
	- Create Firebase project(s), add iOS/Android app IDs, download `GoogleService-Info.plist` and `google-services.json`, wire platform build scripts (Gradle, Xcode) for flavor-based config.
	- Implement secure config loader for API keys (shared-schedule API key, backend base URL) using `flutter_dotenv` + per-flavor `.env` files kept out of git.
	- Write environment service exposing Firestore collections, Cloud Function endpoints, HTTP API clients with logging/interceptors.
	- Build mocked data sources for unit testing (in-memory repos returning fake child/medicine/schedule data).
- **Gate**: Running `flutter test` executes data-layer unit tests that hit mocked services, and app boots to placeholder home without crashing using real Firebase initialization (confirmed on both iOS simulator and Android emulator).

## Milestone 2 – Authentication & App Shell
- **Technical steps**:
	- Implement Firebase Auth service (email/password, password reset, token refresh, biometric credential caching via `local_auth` + secure storage).
	- Build authentication controller (Riverpod/Bloc) with states: `unauthenticated`, `authenticating`, `authenticated`, `error`.
	- Create routing shell using `go_router` with guarded branches for onboarding/login, primary app tabs, and secondary-carer deep links.
	- Implement onboarding, login, signup, password reset, and biometric login screens using shared form widgets and validation.
	- Persist auth session and user metadata in `hydrated` store / shared preferences to enable cold-start auto login.
- **Gate**: Manual QA demonstrates full login/logout/reset flows on both platforms; automated widget tests cover validation and error messaging; deep link to `/secondary?token=mock` routes to pending state screen.

## Milestone 3 – Read-Only Primary Carer Experience
- **Technical steps**:
	- Model Firestore documents (`PrimaryCarer`, `Child`, `Medicine`, `Schedule`, `Administration`, `AsNeededSchedule`) using freezed data classes and converters.
	- Implement repository layer with Firestore queries + caching (e.g., `StreamProvider` for live updates, local JSON cache fallback for offline view).
	- Build Home dashboard UI (calendar strip, time-of-day bins) driven by domain view models that merge schedules + administrations; include skeleton loaders and empty states.
	- Implement Medicines list/detail screens with photo gallery (Firebase Storage download URLs) and read-only child profile view.
	- Add analytics instrumentation (screen events, auth events) via Firebase Analytics.
- **Gate**: Scenario test (real backend) shows authenticated user seeing accurate schedule/medicine info synced with Firestore changes; automated golden tests cover Home and Medicines states (loading/empty/data).

## Milestone 4 – Data Authoring & Notifications
- **Technical steps**:
	- Implement mutations for medicines (create/update/archive) and schedules (CRUD + as-needed administrations) with optimistic UI updates and rollback on failure.
	- Build forms: AddMedicine, EditMedicine, AddSchedule, EditSchedule, AsNeededRecord; include contextual help and validation (dosage, frequency, dates).
	- Integrate `flutter_local_notifications` + timezone package to schedule reminders per recurrence; persist metadata in local store so reminders survive restarts.
	- Add undo/confirmation dialogs for mark-as-given/skipped actions; wire to Firestore/Cloud Functions.
	- Expand unit/integration tests to cover mutation success/failure, optimistic rollback, and notification scheduling logic.
- **Gate**: QA script proves user can add medicine, create schedule, receive local reminder, mark administration, and see Firestore updated; automated integration test (using `integration_test` + Firebase emulator) passes for CRUD flows.

## Milestone 5 – Sharing Centre & Backend API Integration
- **Technical steps**:
	- Implement HTTP client for Cloud Function endpoints (`/sharedSchedule`, `/mySharedSchedules`, `/exportSchedulePdf`, `/auth/:token`, `/administration/:apiId` etc.) with ApiKey/token headers.
	- Build Share Centre UI: list of shares, detail view, create/extend/end flows, PDF export, digital link presentation (including native share sheet integration).
	- Implement secondary-carer experience inside Flutter as WebView or Flutter web target: token-based auth, pending confirmation, schedule view, record/append administration note flows using backend endpoints.
	- Add secure link ingestion (App Links / Universal Links + Firebase Dynamic Links) to route invite tokens directly into the secondary-carer flow.
	- Record all share actions (creation, approval, decline) in analytics + Crashlytics breadcrumbs.
- **Gate**: End-to-end test with Firebase emulator + mocked HTTP verifies carer can create digital share, invitee opens link on mobile browser/Flutter web, approves, records administration, and both parties see updates; regression suite includes API error handling cases.

## Milestone 6 – Quality, Compliance, and Release Readiness
- **Technical steps**:
	- Implement accessibility pass (semantic labels, large text support, high-contrast themes, screen-reader flows) and add automated `flutter_gherkin` or `integration_test` scripts covering critical journeys.
	- Add privacy/legal surfaces (consent modals, privacy policy links, data deletion request entry point) and telemetry opt-in settings.
	- Harden offline behaviour (cache last N days of schedules/medicines, queue mutations for retry) and add background sync service.
	- Configure performance monitoring, Crashlytics, and in-app update prompts.
	- Finalize CI/CD: automated beta builds (Fastlane) to TestFlight/Internal App Sharing, artifact signing, release checklist automation, and monitoring dashboards.
- **Gate**: Release candidate build passes full regression + accessibility audit, automated integration suite, penetration/security review, and is accepted by pilot carers; monitoring dashboard shows zero critical crashes over pilot week.
