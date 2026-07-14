# Agent Instructions

Medicines for Children is an offline-first Flutter application that helps carers manage children's medicines, schedules, reminders, administrations, backups, and time-bounded sharing. It records and presents carer-entered information; it is not a prescribing system, a source of dose recommendations, or a substitute for professional advice.

This file is the entry point for AI coding agents. Read it before changing anything.

## Read First

- [README.md](README.md) - project status, setup, and common commands.
- [spec/README.md](spec/README.md) - product specification and roadmap reading order.
- [SAFETY.md](SAFETY.md) - current clinical safety status and known hazards.
- [~/code/house-style/AGENTS.md](~/code/house-style/AGENTS.md) - cross-repository engineering standards.

## Core Invariants

- Primary carer workflows and locally stored schedules must remain usable without network access.
- Every medicine, schedule, administration, export, and share must remain scoped to the intended profile and child.
- Scanned or imported medicine data is untrusted input. Validate it, show its source, and require carer confirmation before saving it.
- Reminders are advisory. The stored schedule is the source of truth, and reminder failures must not silently alter it.
- Do not log patient-identifiable data, medicine schedules, administration details, passphrases, API keys, or share tokens.
- Backups and QR transfers must be versioned, authenticated, bounded in size, and parsed without partially mutating local data.
- Do not hand-edit generated `*.freezed.dart` or `*.g.dart` files. Regenerate them with `dart run build_runner build`.

## Workflow

- `s/lint` - check Dart formatting and run static analysis.
- `s/test` - run unit and widget tests; pass additional `flutter test` arguments through this script.
- `s/deps-upgrade --outdated` - inspect dependency status.
- `s/android-build`, `s/ios-build`, `s/linux-build`, `s/macos-build`, `s/web-build`, and `s/windows-build` - platform builds.

## Before Every Commit

```sh
s/lint
s/test
```

For dependency or generated-model changes, also run:

```sh
dart run build_runner build
git diff --exit-code -- '**/*.freezed.dart' '**/*.g.dart'
```

## Approval Required

Ask before publishing releases, deploying builds, changing secrets or signing material, deleting data or branches, force-pushing, changing the project licence, or making externally visible GitHub changes.
