# Flutter Implementation Roadmap (Technical)

Legend: [x] done, [~] in progress or partially done, [ ] not started. New work uses stable `SCAN-*`, `QRX-*`, and `OPS-*` identifiers; existing historical milestones retain their original wording.

## Milestone 0 – Repository Bootstrap

- [x] Initialize Flutter project (`flutter create medicines_for_children`) with sound null safety, Riverpod/Bloc-ready structure, and separate `lib/app`, `lib/features`, `lib/core` directories.
- [x] Add core dependencies (dio/http client, intl, freezed/json_serializable, flutter_local_notifications, go_router, shared_preferences, device_info_plus, cryptography, file_selector) and configure build flavors (`dev`, `staging`, `prod`).
- [x] Set up Melos or mono-repo tooling if needed, add Makefile/justfile with commands for `analyze`, `test`, `format`, `lint`.
- [x] Configure CI pipeline (GitHub Actions) to run `flutter analyze`, `flutter test`, `flutter build apk --debug` on every pull request.

- **Gate**: `main` branch build passes CI with green analyze/test status; repo contains README explaining run/build steps.

## Milestone 1 – Local Profiles + Environment Wiring

- [x] Implement secure config loader for API keys (shared-schedule API key, backend base URL) using `flutter_dotenv` + per-flavor `.env` files kept out of git.
- [x] Implement local profile storage (JSON blob per profile) with optional passcode hashing.
- [x] Add encrypted export/import (passphrase-based) for user-controlled backups.
- [x] Build mocked data sources for unit testing (in-memory repos returning fake child/medicine/schedule data).

- **Gate**: Running `flutter test` executes data-layer unit tests; app boots to the home dashboard without any backend configured on both iOS simulator and Android emulator.

## Milestone 2 – Local Profiles & App Shell

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

  - [x] Model local documents (`PrimaryCarer`, `Child`, `Medicine`, `Schedule`, `Administration`, `AsNeededSchedule`) using freezed data classes and converters.
  - [x] Implement repository layer with local JSON persistence and caching (offline-first).
  - [x] Build Home dashboard UI (calendar strip, time-of-day bins) driven by domain view models that merge schedules + administrations; include skeleton loaders and empty states.
  - [x] Implement Medicines list/detail screens with local photo gallery support and read-only child profile view.
  - [x] Add analytics instrumentation (screen events, auth events) via a pluggable telemetry provider.

- **Gate**: Scenario test (offline) shows authenticated user seeing accurate schedule/medicine info from local storage; automated golden tests cover Home and Medicines states (loading/empty/data).

## Milestone 4 – Data Authoring & Notifications

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

  - [x] Implement HTTP client for shared schedule endpoints (`/sharedSchedule`, `/mySharedSchedules`, `/exportSchedulePdf`, `/auth/:token`, `/administration/:apiId` etc.) with ApiKey/token headers.
  - [x] Add shared schedule confirm/decline + administration recording endpoints.
  - [x] Build Sharing UI: list of shares, detail view, create/extend/end flows, PDF export, digital link presentation (including native share sheet integration).
  - [x] Add Sharing list, create form, detail management, and link copy actions.
  - [x] Implement secondary-carer experience inside Flutter as WebView or Flutter web target: token-based auth, pending confirmation, schedule view, record/append administration note flows using backend endpoints.
  - [x] Add secure link ingestion (App Links / Universal Links) to route invite tokens directly into the secondary-carer flow.
  - [x] Record all share actions (creation, approval, decline) in analytics breadcrumbs.

- **Gate**: End-to-end test with mocked HTTP verifies carer can create digital share, invitee opens link on mobile browser/Flutter web, approves, records administration, and both parties see updates; regression suite includes API error handling cases.

## Milestone 6 – Quality, Compliance, and Release Readiness

  - [x] Implement accessibility pass (semantic labels, large text support, high-contrast themes, screen-reader flows) and add automated `flutter_gherkin` or `integration_test` scripts covering critical journeys.
  - [x] Add privacy/legal surfaces (consent modals, privacy policy links) and telemetry opt-in settings.
  - [x] Add dark theme support aligned to brand palette and accessibility guidance.
  - [x] Harden offline behaviour (cache last N days of schedules/medicines, queue mutations for retry) and add background sync service.
  - [x] Configure performance monitoring, error reporting, and in-app update prompts.
  - [x] Finalize CI/CD: automated beta builds (Fastlane) to TestFlight/Internal App Sharing, artifact signing, release checklist automation, and monitoring dashboards.

- **Gate**: Release candidate build passes full regression + accessibility audit, automated integration suite, penetration/security review, and is accepted by pilot carers; monitoring dashboard shows zero critical crashes over pilot week.

## Milestone 7 – Open Source Contribution & Community Engagement

  - [x] Prepare contribution guidelines, code of conduct, and issue/PR templates.
  - [x] Add open source license (GPL3)

## Milestone 8 – Snagging & Review Fixes

  - [x] Fix Android flavor run issue by using explicit flavor entrypoints and document the commands.
  - [x] Enable Android core library desugaring for flutter_local_notifications builds.
  - [x] Add background sync processing for queued share actions with tests.
  - [x] Extend accessibility coverage for schedule semantics in integration tests.
  - [x] Update coverage badge after running standard coverage tool.
  - [x] Improve child date-of-birth picker defaults (year-first view, under-18 bounds).
  - [x] Add an About page in the overflow menu (app version, platform, external links).
  - [x] Share schedule text amended to "there are no shared schedules" when none exist.
  - [x] remove the confirmation checkbox when onboarding - there's no need for it.
  - [x] put the "anonymous analytics" dialog behind a feature flag, we don't need it yet.
  - [x] Import: on importing a backup, the dialog asks for the passphrase three times, I'm not sure why. It should ask once, and if it's wrong, show an error and ask again.
  - [x] Import: It should be made clear that import creates a new profile.
  - [x] Import: The Profile Name (optional) should make it clear that this "Import As <Profile Name>" or the original profile name will be used.
  - [x] Document platform permissions in the roadmap and user guide.

## Milestone 9 – iOS/Webapp Parity (Non-Firebase)

  - [x] Secondary-carer "Important information" view that mirrors the webapp (condition, notes, allergies, care period summary, download schedule).
  - [x] Secondary-carer guidance banner with dismiss state (webapp guidance copy parity).
  - [x] Secondary-carer schedule download action that can generate PDF if one is not already available.
  - [x] Sharing export flow for medicine summary PDF (iOS Export Medicine view parity).
  - [x] Local/offline schedule PDF export option for primary carers when backend is unavailable (iOS local PDF share parity).

## Milestone 10 – Printing Enhancements

  - [x] Add a Print button for exported PDFs.

## Milestone 11 – Camera Capture & QR Scan

  - [x] Add medicine packaging photo capture with camera/gallery support.
  - [x] Add QR code scanning flow to create a medicine entry from packaging data.
  - [x] Support all Medicines for Children QR poster codes with quick-add medicine data.
  - [x] Include Medicines for Children advice-guide QR codes and open them in the browser.
  - [x] Normalize QR URLs so trailing slashes and scheme differences still resolve.
  - [x] Add QR scan parser tests covering medicines, advice guides, and unknown codes.
  - [x] Detect camera capability; if unavailable, show a message advising to use a camera-enabled device.

## Milestone 12 – Profile Settings & Personalisation

  - [x] Add a profile settings section in-app with biometric unlock toggle.
  - [x] Add appearance settings (theme mode and text size).
  - [x] Add global notifications on/off control and make scheduling respect it.
  - [x] Update user guide to explain the new settings controls.

## Milestone 13 – UI/UX & Bug Fixes

  - [x] Use Quicksand Rounded Semi-bold for headings and Montserrat for body text throughout the app.
  - [x] Refine color palette to draw from RCPCH official colour set.
  - [x] Text size should be adjustable via settings (small/default/large/extra large) and persist.
  - [x] Create user testing scripts to gather feedback on usability and accessibility.
  - [x] BUG: Changing the Current Child in the Home view does not change which child is shown.


## Milestone 14 – QA and Release Prep

  - [x] Ensure the app can be built for Linux and AVD emulators without errors.
  - [x] Test build of an APK to allow installation on physical Android devices.
  - [x] Final review of codebase for any included files which constitute a security risk (e.g., hardcoded API keys).
  - [ ] Extend test coverage
  - [ ] Improve granularity of comments in codebase for maintainability.
  - [ ] Set up CI workflow (based on the DGC app workflow ) to automate build and Play Store upload.

## Milestone 15 – Documentation & Community Building

  - [x] Finalize README with setup instructions, contribution guidelines, and project overview.
  - [x] Create a dedicated documentation site or wiki for detailed developer and user guides.
  - [ ] Plan and announce community engagement activities (forums, chat channels, regular updates).

## Stretch Goals – Significant Additions Beyond Baseline Spec

- **Medicine name suggestions (UK datasets)**:
- [ ] Identify a suitable open UK medicine list (e.g., NHS dm+d or OpenPrescribing datasets) with an appropriate licence (likely OGL).
- [ ] Define a lightweight local search index (prefix + fuzzy matching) for fast, offline suggestions.
- [ ] Add ranked suggestions in the medicine name field, with clear attribution to the data source.
- [ ] Add tests covering matching accuracy, ranking, and empty/edge cases.

## Milestone 16 - Pack Identification And Therapeutic Classification

This milestone depends on `sct` roadmap item `R69`. The Flutter app should consume a small, versioned lookup contract backed by the `sct` library or `sct serve`; it must not bundle or redistribute licensed dm+d source releases. The existing static Medicines for Children URL catalogue remains a separate advice-content flow.

- [ ] **SCAN-1 - Define the cross-repository lookup contract.** Accept canonical GTIN-14 and return the matched AMPP plus available AMP, VMPP, VMP, VTM, ingredient, BNF, and ATC identifiers and display terms. Include dm+d, SNOMED CT, BNF, and ATC release identifiers; mapping provenance; match status; ambiguity; and warnings. Publish conformance fixtures in both repositories before UI integration.
- [ ] **SCAN-2 - Complete the `sct` terminology path.** Deliver `sct` `R69`: ingest NHSBSA dm+d GTIN XML and supplementary BNF/ATC mapping files, normalise GTIN-8/12/13/14, preserve AMPP-to-GTIN provenance, traverse the medicines graph without name-based inference, and expose the lookup through a reusable Rust API and a narrow server endpoint suitable for the app.
- [ ] **SCAN-3 - Parse real pack codes.** Extend `mobile_scanner` handling beyond QR URLs to EAN-8, UPC-A, EAN-13, GTIN-14, and GS1 DataMatrix. Parse GS1 application identifiers including `(01)` GTIN, `(10)` batch, `(17)` expiry, and `(21)` serial where present; validate lengths and check digits; normalise to GTIN-14; and never send batch or serial values to lookup services unless a separately approved use requires them.
- [ ] **SCAN-4 - Add a product lookup boundary.** Introduce an injected repository with an `sct`-backed implementation and a deterministic fake. Keep optional Ampoule/drug-data API enrichment behind the same boundary, but use `sct` as the terminology and therapeutic-class source of truth. Cache successful responses with release metadata for offline review and provide a clear offline/manual-entry fallback.
- [ ] **SCAN-5 - Extend the Medicine model without conflating terminology levels.** Store the scanned GTIN, dm+d identifiers by level, sourced BNF/ATC classes, lookup provenance, and last-validated release separately from the carer-editable display name, dose, route, and schedule. Provide migration defaults for existing Medicine JSON and encrypted backups.
- [ ] **SCAN-6 - Build a confirm-before-save workflow.** Show the pack match, formulation, strength, pack size, identifiers, therapeutic class, source date, ambiguity, and warnings. Require explicit confirmation against the box; never populate dose, route, frequency, or schedule from therapeutic classification; support "not this medicine" and manual correction.
- [ ] **SCAN-7 - Add safety and conformance evidence.** Cover valid and invalid check digits, leading-zero normalisation, GS1 separators, malformed and oversized payloads, unknown GTINs, one-to-many mappings, inactive concepts, stale releases, offline lookup, API failure, and fixtures agreed with `sct`. Link the evidence to `HAZ-004` and complete clinical review before pilot use.

- **Gate**: The same shared fixtures prove GTIN -> AMPP -> VTM -> BNF/ATC results in `sct` and Flutter; no result is saved without confirmation; unknown, ambiguous, stale, malformed, and offline states are understandable and safe.

## Milestone 17 - Offline Schedule Transfer By QR

Schedule transfer is distinct from whole-profile `.mfc` Backup and online Share. The transfer contains one Child's medicine plan and deliberately excludes profile credentials, carer details, photos, API keys, share tokens, notification IDs, and queued actions.

- [ ] **QRX-1 - Specify a canonical versioned payload.** Define a deterministic schema containing transfer version, export ID, creation time, minimal Child identity for human matching, Medicines, regular and as-needed Schedules, and an Administration-history mode of `none`, `dateRange`, or `all`. Record timezone semantics explicitly and use stable fixture IDs only within the payload.
- [ ] **QRX-2 - Define the privacy and cryptographic envelope.** Default Administration history to excluded. Show a content summary and shoulder-surfing warning before displaying codes. Support authenticated encryption with a passphrase shared out of band; for intentionally unencrypted transfers, provide corruption detection while making clear that a checksum does not establish trust.
- [ ] **QRX-3 - Design for QR capacity rather than assuming one code.** Measure the canonical payload, compress before text encoding, set strict compressed and expanded size/count limits, and use one QR only when it fits at a robust error-correction level. Otherwise emit a numbered multi-part or animated sequence carrying export ID, part count, part index, and whole-payload digest. Photos are always excluded.
- [ ] **QRX-4 - Implement export selection and preview.** Let the carer select the active Child and Administration-history mode, including date bounds where applicable. Preview included child details, medicine and schedule counts, administration count, encryption state, number of QR parts, and expiry if the envelope adopts one.
- [ ] **QRX-5 - Implement defensive scanning and assembly.** Reuse the scanner with a distinct Schedule-transfer discriminator. Accept parts in any order, detect duplicates and mixed export IDs, permit resuming an interrupted scan only without persisting clear health data, enforce limits before decompression, authenticate/decrypt before parsing, and reject unsupported versions without mutation.
- [ ] **QRX-6 - Preview and atomically import.** Validate every reference and date before writing. Show additions and conflicts, require the user to choose a destination profile, and default to creating a new Child. Remap all local IDs and references; do not silently merge or replace an existing Child. Commit all records in one operation or none.
- [ ] **QRX-7 - Define duplicate and update semantics before offering merge.** Decide whether a later transfer can update a previously imported Child, how transfer identity is retained, and how conflicting Medicines, Schedules, and Administrations are reconciled. Until this is specified and reviewed, only new-Child import is supported.
- [ ] **QRX-8 - Add conformance, privacy, and safety tests.** Include golden payloads and round trips for each Administration-history mode, maximum supported content, Unicode, timezone/DST boundaries, out-of-order and missing parts, duplicate scans, wrong passphrases, tampering, decompression bombs, identifier collisions, repeated imports, and unsupported future versions. Link evidence to `HAZ-001`, `HAZ-005`, and `HAZ-007`.

- **Gate**: A schedule created on one offline device can be transferred to another with an exact, reviewable round trip; Administration history is absent unless explicitly selected; malformed or hostile input causes no partial write; and multi-part recovery is proven on representative devices.

## Milestone 18 - Repository And Release Operations

- [~] **OPS-1 - Standardise the development toolchain.** Flutter `3.44.4` and Dart `3.12.2` are pinned in CI under the one-week cooldown policy; direct constraints and the audited lockfile are updated; code generation, analysis, tests, web release build, Android production-flavour release build, and Linux debug build pass. Remaining: representative iOS, macOS, and Windows builds on their supported hosts.
- [x] **OPS-2 - Adopt baseline repository guidance.** Add vendor-neutral agent instructions, a specification index and glossary, security reporting guidance, an editor configuration, and root clinical safety entry point.
- [x] **OPS-3 - Harden routine dependency and CI automation.** Pin GitHub Actions to verified SHAs, use the same Flutter version in CI and deployment workflows, and configure weekly Dependabot updates with cooldown and grouping.
- [ ] **OPS-4 - Resolve licensing policy.** Confirm whether the existing GPLv3 project is `GPL-3.0-only` or `GPL-3.0-or-later`, whether RCPCH contributors permit any move to the house-standard AGPL licence, and how written content, branding, fonts, generated files, and third-party terminology data are covered before adding SPDX/REUSE enforcement.
- [ ] **OPS-5 - Complete safety governance.** Appoint the clinical safety owner, agree the risk matrix, score and review the hazard log, and link release evidence before pilot or production use.
- [ ] **OPS-6 - Migrate to Android built-in Kotlin.** Remove the temporary `android.builtInKotlin=false` and `android.newDsl=false` compatibility flags once the app and `mobile_scanner` support Flutter's built-in Kotlin migration, then prove all Android flavours still build.
