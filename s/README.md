# `s/`

The `s/` directory contains the repository's repeatable development and build commands. Run them from any directory inside the checkout.

## Quality And Dependencies

- `s/lint` - check Dart formatting and run Flutter static analysis.
- `s/test` - run unit and widget tests; additional arguments are passed to `flutter test`.
- `s/coverage` - regenerate coverage and print overall line coverage.
- `s/analyze` - run Flutter static analysis only.
- `s/deps-upgrade --outdated` - report outdated packages.
- `s/deps-upgrade` - update within current constraints.
- `s/deps-upgrade --major` - update constraints across major versions; review release dates and maintain the cooldown policy first.
- `s/gen-icons` - regenerate launcher icons.

## Run And Build

- `s/avd-run` - select or start an Android emulator and run the app.
- `s/linux-run` - run the Linux desktop app.
- `s/android-build` - build a production-flavour Android APK.
- `s/ios-build` - build an unsigned iOS release.
- `s/linux-build` - build the Linux desktop app.
- `s/macos-build` - build the macOS app.
- `s/web-build` - build the web app.
- `s/windows-build` - build the Windows app.
- `s/generate-release-checklist` - create `build/release-checklist.md`.
