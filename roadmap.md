# Flutter Implementation Roadmap (Technical)

## Milestone 0 – Repository Bootstrap
- **Technical steps**:
	- [x] Initialize Flutter project (`flutter create medicines_for_children`) with sound null safety, Riverpod/Bloc-ready structure, and separate `lib/app`, `lib/features`, `lib/core` directories.
	- [x] Add core dependencies (dio/http client, intl, freezed/json_serializable, flutter_local_notifications, go_router, shared_preferences, device_info_plus, cryptography, file_selector) and configure build flavors (`dev`, `staging`, `prod`).
	- [x] Set up Melos or mono-repo tooling if needed, add Makefile/justfile with commands for `analyze`, `test`, `format`, `lint`.
	- [x] Configure CI pipeline (GitHub Actions) to run `flutter analyze`, `flutter test`, `flutter build apk --debug` on every pull request.
- **Gate**: `main` branch build passes CI with green analyze/test status; repo contains README explaining run/build steps.

## Milestone 1 – Local Profiles + Environment Wiring
- **Technical steps**:
	- [x] Implement secure config loader for API keys (shared-schedule API key, backend base URL) using `flutter_dotenv` + per-flavor `.env` files kept out of git.
	- [x] Implement local profile storage (JSON blob per profile) with optional passcode hashing.
	- [x] Add encrypted export/import (passphrase-based) for user-controlled backups.
	- [x] Build mocked data sources for unit testing (in-memory repos returning fake child/medicine/schedule data).
- **Gate**: Running `flutter test` executes data-layer unit tests; app boots to placeholder home without any backend configured on both iOS simulator and Android emulator.

## Milestone 2 – Local Profiles & App Shell
- **Technical steps**:
	- [x] Implement local profile repository (create/select/unlock via passcode).
	- [x] Build authentication controller (Riverpod/Bloc) with states: `unauthenticated`, `authenticating`, `authenticated`, `error`.
	- [x] Create routing shell using `go_router` with guarded branches for onboarding/login, primary app tabs, and secondary-carer deep links.
	- [x] Ship profile selection + create profile flows with validation, loading states, and Riverpod wiring.
	- [x] Implement onboarding + signup flows using shared form widgets, Riverpod wiring, and local persistence for draft profiles.
	- [x] Persist auth session and user metadata in shared preferences so the home shell boots with cached context.
- **Gate**: Manual QA demonstrates profile create/select/unlock flows on both platforms; automated widget tests cover validation and error messaging; deep link to `/secondary?token=mock` routes to pending state screen.

## Milestone 3 – Read-Only Primary Carer Experience
- **Technical steps**:
	- [x] Model local documents (`PrimaryCarer`, `Child`, `Medicine`, `Schedule`, `Administration`, `AsNeededSchedule`) using freezed data classes and converters.
	- [x] Implement repository layer with local JSON persistence and caching (offline-first).
	- [x] Build Home dashboard UI (calendar strip, time-of-day bins) driven by domain view models that merge schedules + administrations; include skeleton loaders and empty states.
	- [x] Implement Medicines list/detail screens with local photo gallery support and read-only child profile view.
	- [x] Add analytics instrumentation (screen events, auth events) via a pluggable telemetry provider.
- **Gate**: Scenario test (offline) shows authenticated user seeing accurate schedule/medicine info from local storage; automated golden tests cover Home and Medicines states (loading/empty/data).

## Milestone 4 – Data Authoring & Notifications
- **Technical steps**:
	- [x] Implement mutations for medicines (create/update/archive).
	- [x] Implement schedule CRUD mutations (create/update/delete) with optimistic UI updates.
	- [x] Implement as-needed administrations with optimistic UI updates.
	- [x] Build forms: AddMedicine, EditMedicine with validation (dosage, frequency).
	- [x] Build forms: AddSchedule, EditSchedule with validation (dosage, frequency, dates).
	- [x] Build form: AsNeededRecord; include contextual help and validation.
	- [x] Integrate `flutter_local_notifications` + timezone package to schedule reminders per recurrence; persist metadata in local store so reminders survive restarts.
	- [x] Add undo actions for mark-as-given/skipped actions; optionally sync changes if a backend is configured.
	- [x] Expand unit tests to cover mutation success/failure.
	- [ ] Add integration tests for CRUD flows and notification scheduling.
	- [ ] Add unit tests for notification scheduling logic.
- **Gate**: QA script proves user can add medicine, create schedule, receive local reminder, mark administration; automated integration test (using `integration_test`) passes for CRUD flows.

## Milestone 5 – Sharing Centre & Backend API Integration
- **Technical steps**:
	- Implement HTTP client for shared schedule endpoints (`/sharedSchedule`, `/mySharedSchedules`, `/exportSchedulePdf`, `/auth/:token`, `/administration/:apiId` etc.) with ApiKey/token headers.
	- Build Share Centre UI: list of shares, detail view, create/extend/end flows, PDF export, digital link presentation (including native share sheet integration).
	- Implement secondary-carer experience inside Flutter as WebView or Flutter web target: token-based auth, pending confirmation, schedule view, record/append administration note flows using backend endpoints.
	- Add secure link ingestion (App Links / Universal Links) to route invite tokens directly into the secondary-carer flow.
	- Record all share actions (creation, approval, decline) in analytics breadcrumbs.
- **Gate**: End-to-end test with mocked HTTP verifies carer can create digital share, invitee opens link on mobile browser/Flutter web, approves, records administration, and both parties see updates; regression suite includes API error handling cases.

## Milestone 6 – Quality, Compliance, and Release Readiness
- **Technical steps**:
	- Implement accessibility pass (semantic labels, large text support, high-contrast themes, screen-reader flows) and add automated `flutter_gherkin` or `integration_test` scripts covering critical journeys.
	- Add privacy/legal surfaces (consent modals, privacy policy links, data deletion request entry point) and telemetry opt-in settings.
	- Harden offline behaviour (cache last N days of schedules/medicines, queue mutations for retry) and add background sync service.
	- Configure performance monitoring, error reporting, and in-app update prompts.
	- Finalize CI/CD: automated beta builds (Fastlane) to TestFlight/Internal App Sharing, artifact signing, release checklist automation, and monitoring dashboards.
- **Gate**: Release candidate build passes full regression + accessibility audit, automated integration suite, penetration/security review, and is accepted by pilot carers; monitoring dashboard shows zero critical crashes over pilot week.
