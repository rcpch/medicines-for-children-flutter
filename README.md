# Medicines for Children

![Coverage](https://img.shields.io/badge/coverage-39.8%25-red)

This repository hosts the Flutter implementation of the Medicines for Children mobile and web client. The app delivers the sharing centre, secondary-carer flows, offline-first storage, and release readiness milestones.

## Features
- Offline-first local profile storage with encrypted import/export backups.
- Onboarding flows for primary carers and first children.
- Multi-child support with offline CRUD for medicines and schedules.
- Notification scheduling for medicine administrations.
- Sharing options for secondary carers to access shared schedules.
- QR code import for Medicines for Children poster codes.
- PDF exports of medicine schedules.
- Deep-link routing for secondary carers and shared schedules.
- Cross-platform support: iOS, Android, Web, macOS, Windows, Linux.
- State management with Riverpod for scalability and testability.

## User Documentation

All user documentation is within the app itself, accessible via the Guide tab on the home screen.

## Developer Documentation


### New laptop prerequisites

- Flutter `3.44.4`, which includes Dart `3.12.2`. This is the newest stable Flutter release at least seven full days old at the time of the 2026-07-13 dependency review.
- Android Studio with the Android SDK, platform tools, command-line tools, and an emulator image. Run `flutter doctor --android-licenses` after installation. Android Studio is optional if the equivalent SDK command-line tools are installed and configured.
- Chrome or Chromium for web development.
- Linux desktop builds: Clang, CMake, Ninja, pkg-config, GTK 3 development headers, and the standard C++ development libraries listed by the Flutter Linux setup guide.
- macOS/iOS builds: a current supported Xcode and CocoaPods on a Mac.
- Store and Play deployment only: Ruby/Bundler, Fastlane, and project signing credentials. These are not needed for normal development or tests.

Flutter supplies Dart, so a separate Dart SDK installation is not required. Verify the setup before fetching project dependencies:

```bash
flutter --version
dart --version
flutter doctor -v
```

### Quick start

```bash
# clone the repo
git clone https://github.com/rcpch/medicines-for-children-flutter.git

# install dependencies
flutter pub get

# (re)generate freezed/json_serializable outputs
dart run build_runner build

# run the same format, analyzer and test gates as CI
s/lint
s/test --coverage

# launch the dev flavor (uses lib/main_dev.dart)
flutter run --flavor dev --target lib/main_dev.dart

# launch staging/prod flavors
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor prod --target lib/main_prod.dart
```

### Project layout

- `lib/app/` – app shell, router, configuration
- `lib/core/` – cross-cutting utilities (theme, environment helpers, etc.)
- `lib/features/` – feature modules (auth, onboarding, home, medicines, schedules, sharing, settings)
- `lib/bootstrap.dart` – top-level initialization entry point
- `test/` – widget/unit tests seeded with a splash smoke test

### Backups

Backups are encrypted. Importing a backup creates a new local profile; you can optionally rename it during import.

### Environment configuration
Shared-schedule API configuration is optional. The app boots without env files (values default to empty strings). If you need the backend integration:

- Add `env/.env.dev`, `env/.env.staging`, and/or `env/.env.prod` locally (do not commit secrets).
- Register those files under the `assets` section in `pubspec.yaml`.
- The flavor entrypoints in `lib/main_<flavor>.dart` load the matching file via `dotenv`.

### Deep links (App Links / Universal Links)

The app routes secondary-carer links to `/auth/:token` and `/shared-schedule/:apiId`. Configure platform link domains:

- Android: update `appLinkHost` in `android/app/build.gradle.kts` to your link host.
- iOS: update `applinks:example.com` in `ios/Runner/Runner.entitlements`.

### Import/Export file format

Backup files use the `.mfc` extension.

They are **UTF-8 encoded JSON files** containing an encrypted payload. You can inspect the outer structure without the passphrase, but the profile data itself is encrypted.

#### Outer file structure (unencrypted)

Top-level JSON object:

```json
{
	"formatVersion": 1,
	"createdAt": "2026-01-20T12:34:56.789Z",
	"kdf": {
		"salt": "<base64>",
		"iterations": 100000
	},
	"cipher": {
		"nonce": "<base64>",
		"cipherText": "<base64>",
		"mac": "<base64>"
	}
}
```

Field notes:

- `formatVersion`: currently `1`.
- `createdAt`: ISO-8601 timestamp string.
- `kdf`: PBKDF2 parameters.
	- `salt`: 16 random bytes, base64-encoded.
	- `iterations`: currently `100000`.
- `cipher`: AES-GCM outputs.
	- `nonce`: 12 random bytes, base64-encoded.
	- `cipherText`: encrypted bytes, base64-encoded.
	- `mac`: authentication tag bytes, base64-encoded.

#### Key derivation and encryption

- KDF: PBKDF2-HMAC-SHA256, 100000 iterations, output size 256 bits.
- Cipher: AES-GCM with a 256-bit key.
- The user-provided passphrase is used as the PBKDF2 input (UTF-8 bytes).

#### Decrypted payload structure (encrypted)

After decryption, the payload is JSON with:

- `profile`: metadata used during restore.
	- `name`: profile name.
	- `displayName`: user display name (if present).
- `primaryCarer`: the full primary-carer document (includes children, medicines, schedules, administrations, etc.).
- `onboardingProfile` (optional): onboarding draft data.

Restore behavior:

- Importing a backup **always creates a new local profile**.
- The “Import As” name (if provided) overrides the payload’s `profile.name`.

### Platform permissions

- iOS: camera and photo library usage strings are defined in `ios/Runner/Info.plist`.
- macOS: camera and photo library usage strings are defined in `macos/Runner/Info.plist`.
- Android: camera + photo permissions are defined in `android/app/src/main/AndroidManifest.xml`.
- Windows: no extra permissions are required; camera access falls back to a friendly “camera not available” message when unsupported.
- Linux: no extra permissions are required; camera access falls back to a friendly “camera not available” message when unsupported.
- Web: camera access is requested via browser prompt when needed.

### Release automation

- `fastlane/` contains TestFlight and Play internal lanes (see `fastlane/README.md` for required env vars).
- `s/generate-release-checklist` generates `build/release-checklist.md`.

### Contributing

Contributions are welcome! Please open issues or pull requests as needed. See `CONTRIBUTING.md` for guidelines.

## Safety, security, and licence

- Read [SAFETY.md](SAFETY.md) before changing schedules, reminders, administrations, scans, imports, exports, or sharing.
- Report vulnerabilities privately using [SECURITY.md](SECURITY.md), never through a public issue containing health data or credentials.
- The repository currently contains the GNU General Public License version 3 in [LICENSE](LICENSE). The precise `only` versus `or later` policy and any future relicensing require project-owner confirmation; house-style relicensing has therefore not been applied mechanically.
