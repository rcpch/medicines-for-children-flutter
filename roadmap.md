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
- **Gate**: Running `flutter test` executes data-layer unit tests; app boots to the home dashboard without any backend configured on both iOS simulator and Android emulator.

## Milestone 2 – Local Profiles & App Shell
- **Technical steps**:
	- [x] Implement local profile repository (create/select/unlock via passcode).
	- [x] Build authentication controller (Riverpod/Bloc) with states: `unauthenticated`, `authenticating`, `authenticated`, `error`.
	- [x] Create routing shell using `go_router` with guarded branches for onboarding/login, primary app tabs, and secondary-carer deep links.
	- [x] Add multi-child support foundations (child picker, per-child storage/selection, shared schedule scoping, and UI routing updates).
	- [x] Add child picker UI with per-profile child selection persistence.
	- [x] Ship profile selection + create profile flows with validation, loading states, and Riverpod wiring.
	- [x] Implement onboarding + signup flows using shared form widgets, Riverpod wiring, and local persistence for draft profiles.
	- [x] Persist auth session and user metadata in shared preferences so the home shell boots with cached context.
- **Gate**: Manual QA demonstrates profile create/select/unlock flows on both platforms; automated widget tests cover validation and error messaging; deep link to `/auth/:token` routes to pending state screen.

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
	- [x] Add integration tests for CRUD flows and notification scheduling.
	- [x] Add integration test for medicine + schedule creation flow (notifications disabled).
	- [x] Add integration test for schedule creation with notification metadata.
	- [x] Add integration test for medicine edit and schedule delete flows.
	- [x] Add unit tests for notification scheduling logic.
- **Gate**: QA script proves user can add medicine, create schedule, receive local reminder, mark administration; automated integration test (using `integration_test`) passes for CRUD flows.

## Milestone 5 – Sharing Centre & Backend API Integration
- **Technical steps**:
	- [x] Implement HTTP client for shared schedule endpoints (`/sharedSchedule`, `/mySharedSchedules`, `/exportSchedulePdf`, `/auth/:token`, `/administration/:apiId` etc.) with ApiKey/token headers.
	- [x] Add shared schedule confirm/decline + administration recording endpoints.
	- [x] Build Share Centre UI: list of shares, detail view, create/extend/end flows, PDF export, digital link presentation (including native share sheet integration).
	- [x] Add Share Centre list, create form, detail management, and link copy actions.
	- [x] Implement secondary-carer experience inside Flutter as WebView or Flutter web target: token-based auth, pending confirmation, schedule view, record/append administration note flows using backend endpoints.
	- [x] Add secure link ingestion (App Links / Universal Links) to route invite tokens directly into the secondary-carer flow.
	- [x] Record all share actions (creation, approval, decline) in analytics breadcrumbs.
- **Gate**: End-to-end test with mocked HTTP verifies carer can create digital share, invitee opens link on mobile browser/Flutter web, approves, records administration, and both parties see updates; regression suite includes API error handling cases.

## Milestone 6 – Quality, Compliance, and Release Readiness
- **Technical steps**:
	- [x] Implement accessibility pass (semantic labels, large text support, high-contrast themes, screen-reader flows) and add automated `flutter_gherkin` or `integration_test` scripts covering critical journeys.
	- [x] Add privacy/legal surfaces (consent modals, privacy policy links, data deletion request entry point) and telemetry opt-in settings.
	- [x] Add dark theme support aligned to brand palette and accessibility guidance.
	- [x] Harden offline behaviour (cache last N days of schedules/medicines, queue mutations for retry) and add background sync service.
	- [x] Configure performance monitoring, error reporting, and in-app update prompts.
	- [x] Finalize CI/CD: automated beta builds (Fastlane) to TestFlight/Internal App Sharing, artifact signing, release checklist automation, and monitoring dashboards.
- **Gate**: Release candidate build passes full regression + accessibility audit, automated integration suite, penetration/security review, and is accepted by pilot carers; monitoring dashboard shows zero critical crashes over pilot week.

## Milestone 7 – Open Source Contribution & Community Engagement
- **Technical steps**:
	- [x] Prepare contribution guidelines, code of conduct, and issue/PR templates.
	- [x] Add open source license (GPL3)

## Milestone 8 – Snagging & Review Fixes
- **Technical steps**:
	- [x] Fix Android flavor run issue by using explicit flavor entrypoints and document the commands.
	- [x] Enable Android core library desugaring for flutter_local_notifications builds.
	- [x] Add background sync processing for queued share actions with tests.
	- [x] Extend accessibility coverage for schedule semantics in integration tests.
	- [x] Update coverage badge after running standard coverage tool.
	- [x] Improve child date-of-birth picker defaults (year-first view, under-18 bounds).
	- [x] Share schedule text amended to "there are no shared schedules" when none exist.
	- [x] remove the confirmation checkbox when onboarding - there's no need for it.
	- [x] put the "anonymous analytics" dialog behind a feature flag, we don't need it yet.
	- [x] Import: on importing a backup, the dialog asks for the passphrase three times, I'm not sure why. It should ask once, and if it's wrong, show an error and ask again.
	- [x] Import: It should be made clear that import creates a new profile.
	- [x] Import: The Profile Name (optional) should make it clear that this "Import As <Profile Name>" or the original profile name will be used.

## Milestone 9 – iOS/Webapp Parity (Non-Firebase)
- **Technical steps**:
	- [x] Secondary-carer "Important information" view that mirrors the webapp (condition, notes, allergies, care period summary, download schedule).
	- [x] Secondary-carer guidance banner with dismiss state (webapp guidance copy parity).
	- [x] Secondary-carer schedule download action that can generate PDF if one is not already available.
	- [x] Share centre export flow for medicine summary PDF (iOS Export Medicine view parity).
	- [x] Local/offline schedule PDF export option for primary carers when backend is unavailable (iOS local PDF share parity).
