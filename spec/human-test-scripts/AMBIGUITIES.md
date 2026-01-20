# Ambiguities & open questions

This file tracks areas where product intent, UI copy, or platform behaviour is unclear or likely to vary.

## QR scanning

- How should “unknown” QR scans be presented (snackbar vs dedicated screen), and what copy do we want?
- Should QR scanning accept non-URL payloads (e.g. medicine codes) in future, or only known MFC URLs?
- Do we provide an official set of printable QR codes for QA, or do testers generate them ad-hoc?

## Profile creation / selection

- What is the exact entry point + copy for creating a new local profile on a fresh install?
- Are there any constraints for profile names (length, characters, duplicates)?

## Passcode and biometric unlock

- Passcode requirements (length, digits-only vs any text) and whether they differ by platform.
- What is the expected flow when biometrics are unavailable or permission is denied?

## Notifications

- What is the expected UX when notification permission is denied (copy + where to enable)?
- Should schedule creation default reminders ON per schedule if global reminders are enabled?
- Should schedule reminders be re-created if the user toggles reminders OFF then ON globally?

## Share centre

- “New share” creation flow: what is the intended minimum viable sharing capability on each milestone?
- Expected behaviour on platforms without printing support.

## PDFs

- Where should exported PDFs be saved on each platform, and should the app show the exact path?
- Do we need watermarking or redaction options for PDFs?

## Accessibility

- Are there specific WCAG targets or audit tooling requirements for this app?
- Which semantics labels are contractual (must not change) vs flexible?

## Data & reset

- Is there an in-app way to reset/clear local data for QA, or should testers uninstall/reinstall?
- Expected behaviour when importing a backup that conflicts with existing local profiles.
