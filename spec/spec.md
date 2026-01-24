# Functional Specification: Medicines for Children (Flutter Port)

## Universal navigation and structure

- M4C logo in top-left corner as a home button
- Navigation row at the bottom of the screen with tabs for:
  - Home (daily schedule overview)
  - Medicines (list of medicines)
  - Child (child and carer profile, settings)
  - Guide (in-app user guide and FAQs)

## Branding and theming

- Follow RCPCH brand guidelines for colors, fonts, and logos.
- Additional Medicines For Children logos.
- Support light, dark, and system themes.
- Allow text size scaling (Small, Default, Large, Extra large).
- Consistent use of icons and imagery aligned with RCPCH style.

## Integrations

- iCloud, Google Drive and Dropbox integration for backup import/export.
- QR Code scanning of medication packaging to obtain drug, unit size, quantity data via https://github.com/chriswilson1982/drug-data-api, https://api.ampoule.app/v2/docs
- In the UK, all medical product packs will have an EAN13 barcode, which provides the GTIN. Many packs will also have a 2D data matrix code, which usually encodes the GTIN as well as batch number and expiry date.
---


## Top-level screens

### Splash screen

- Shown on startup (all platforms)
- Displays Medicines For Children branding (logo + app name)
- Clearly indicates: **PRE-ALPHA Evaluation Release**

### 'Home' screen

- Dismissible 'welcome' banner at login
- Displays the current Child

### 'Medicines' screen

- Lists all medicines for the current Child
- Filter toggle for "Everyday" and "As-needed" medicines
- Button to add a new medicine
- Button to add medicine by QR code

### 'Child' screen

- Displays Child profile information
- Button to add a new Child (top right corner)

### 'Guide' screen

This area brings the 'user guide' inside the app for easier access

- In-app user guide and FAQs
- Privacy policy and terms of service links
- Feedback via GitHub Issues (with pre-filled Issue template which includes app version and device info)

### Settings screen

- Accessed via top-right 'three dots' menu
- Contains:
  - Biometric authentication toggle
  - Change passcode option
  - Theme selection (Light, Dark, System)
  - Text size adjustment (Small, Default, Large, Extra large)
  - Notifications reminders toggle

### About screen

- Accessed via top-right 'three dots' menu
- Shows app name, version, and platform
- Links out to:
  - GitHub repository
  - Medicines for Children website



---

## Product scope

Medicines for Children is an **offline-first** medicine management app for carers.

- Primary carer features run fully offline on a device using locally stored data.
- Optional sharing features allow a primary carer to share a time-bounded schedule with another carer.

## Roles

### Primary carer

- Creates and manages one or more local profiles on a device.
- Manages children, medicines, schedules, reminders, and exports.
- Can create sharing invitations (digital link or PDF) for secondary carers.

### Secondary carer (invited)

- Uses a share invitation (typically a link) to view a shared schedule for a specific date range.
- Can record administrations (given/skipped) within that shared period.
- Can download the schedule (e.g. as PDF) where available.

## Core principles

### Offline-first storage

- Profile, child, medicine, schedule, and administration data is stored locally.
- The app must remain usable without connectivity.
- Data moves between devices via encrypted backups (import/export).

### Privacy and data ownership

- The user controls their data on their device.
- Primary carer data is stored locally on the device (no cloud account required).
- If sharing is enabled, a backend may store only the minimum information required to deliver the shared schedule for the chosen period.
- To delete their data, users can delete exported backups and uninstall the app from all devices.

## Feature set

### Profiles & security

- Create/select local profiles.
- Optional passcode per profile.
- Optional biometric unlock (when supported) gated behind a passcode.
- Sign out / switch profile.

### Carer and child profiles

- Primary carer profile details (name and relationship to the child).
- Create and manage one or more children.
- Switch active child and have the UI update accordingly.
- Store medical context for the child (e.g. condition, allergies, important notes).

### Medicines

- Add, view, edit, and retire medicines.
- Support everyday and as-needed medicines (and a medicine that is both).
- Filter medicines by everyday/as-needed.
- Optional medicine photos to help identification.
- Optional scan barcode to add medication by EAN13 GTIN using https://api.ampoule.app/v2/docs.
- Optional M4C QR Code poster scan flow to add medicine details.
- Track stock level per medicine (e.g. number of tablets or units on hand).
- Allow users to set a low-stock threshold and receive reorder alerts.
- Allow updates to stock levels after scheduled and as-needed administrations.

### Schedules (regular)

- Create and edit schedules for medicines.
- Define schedule timing (days and times) and active date range.
- View a day-by-day schedule with grouped time-of-day sections.
- Indicate when a medicine will need reordering based on upcoming doses and current stock.

### As-needed administrations

- Record as-needed administrations against a medicine.
- Capture timestamp and optional notes.
- Show as-needed activity for a selected day.

### Administration tracking

- For scheduled doses: mark as **Given** or **Skipped**.
- Allow undo for recent changes.
- Display status clearly (Due/Upcoming/Given/Skipped).

### Home (daily overview)

- Show the selected day’s schedule summary.
- Provide quick navigation to manage schedules and record as-needed administrations.
- Provide a calendar strip to move between dates.

### Sharing (optional online feature)

- Share Centre: view existing shares and create new ones.
- Create a share for a specific child and date range.
- Choose share type:
  - Digital share link for a secondary carer.
  - PDF share for printing/sending.
- Share lifecycle:
  - Secondary carer can accept/decline.
  - Primary carer can end a share early.
- Secondary carer shared schedule:
  - View schedule and important child information.
  - Record administrations during the shared period.
  - Download the schedule.

### Exports & backups

- Export schedule as PDF.
- Export medicine summary as PDF.
- Export an encrypted backup file for safekeeping.
- Import a backup to create a new local profile.

### Notifications & reminders

- Per-device toggle to enable/disable reminders.
- Schedule notifications for upcoming doses when reminders are enabled.
- Clear/refresh notifications when schedules change or expire.
- Low-stock alerts per medicine using the configured threshold (X number of days left, or X number of tablets left)

### Settings

- Theme: system/light/dark.
- Text size scaling.
- Notifications reminders toggle.
- Medication stock alerts toggle, threshold (X number of working days left, or X number of tablets left)
- Analytics/telemetry toggle (where enabled) and consent prompt on first run.

### In-app guide

- Built-in guide and FAQs.
- Links to privacy policy and terms.
- Includes “Deleting your data” guidance.

## Non-goals (for this spec)

- Detailed backend endpoint documentation.
- Platform-specific implementation details (e.g. iOS controller names, internal storage keys).
