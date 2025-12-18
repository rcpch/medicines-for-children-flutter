# Copilot Instructions

## Big picture
- This repo is the Flutter client for the Medicines for Children platform. Functional behaviour and UX intent live in [`spec.md`](../spec.md); delivery sequencing is tracked in [`roadmap.md`](../roadmap.md). Keep features aligned with those documents before introducing new flows.
- The app targets both primary carers (full management experience) and invited secondary carers (shared schedules). Assume Firebase (Auth, Firestore, Storage, Functions) is the backend plus REST endpoints defined in the legacy backend repo.

## Architecture & conventions
- `lib/bootstrap.dart` wraps `runApp`; always integrate global initialization (Firebase, env loading, DI) there instead of `main.dart` directly.
- App shell lives under `lib/app/` (see `app.dart` + `router/app_router.dart`). Use `go_router` for navigation; add routes via `createAppRouter()` and keep paths declarative.
- Cross-cutting pieces (theme, env, analytics) belong in `lib/core/`. Features go under `lib/features/<feature>/presentation|application|domain|data` as they emerge (see `features/splash` stub for folder naming).
- State management will use Riverpod/StateNotifier—prefer providers over global singletons. Co-locate providers with feature modules.
- Data models should be `freezed` + `json_serializable` ready. Run `make gen` (build_runner) whenever you add/update models.
- Follow `analysis_options.yaml` (flutter_lints v5). Prefer fixing lint warnings; only suppress with justification.

## Tooling & workflows
- Use the provided `Makefile`: `make get`, `make analyze`, `make test`, `make gen`, `make run-dev`. These should stay green before opening PRs.
- CI is enforced via `.github/workflows/flutter-ci.yml` (runs `flutter pub get`, `flutter analyze`, `flutter test --coverage`). Avoid adding steps that require secrets unless you also update the workflow.
- Default flavor is `dev`; staging/prod flavours will be added in Milestone 1. Keep environment-specific logic behind an eventual config service (planned via `flutter_dotenv`).
- For local notifications/timezone, rely on the dependencies already declared in `pubspec.yaml`—don’t reintroduce duplicates.

## Testing expectations
- Update `test/` whenever you touch UI flows or utilities (e.g., extend `test/widget_test.dart` or add feature-specific tests).
- Prefer widget or provider tests for navigation/state logic; integration tests should target Firebase emulator setups once Milestone 1 is in place.
- When introducing new routes or screens, add at least a smoke test asserting key copy/widgets so CI guards regressions.

## External integrations
- Backend contracts are defined in the Firebase Functions repo (e.g., `/sharedSchedule`, `/administration/:apiId`). Mirror request/response shapes from there—do not invent new endpoints without backend alignment.
- Keep sensitive config (API keys, project IDs) out of source; they will be injected via per-flavor `.env` files and native configs (`google-services.json`, `GoogleService-Info.plist`). Document any new required keys in README + onboarding docs.

## When in doubt
- Cross-check behaviour with the native iOS app (`medicines-for-children-ios/WellChild`) and the web app (`medicines-for-children-webapp`) to ensure feature parity.
- Document non-obvious decisions inside the relevant module README or code comments so future agents have context.
- If something seems missing, mention it in your PR notes and update this file so the next agent benefits.
