# Reminders & notifications

## Goal

Validate settings-level reminders toggle and schedule-level “Enable reminders” behaviour.

## Preconditions

- A profile exists and onboarding is complete.
- At least one medicine and one schedule exist.
- Device supports local notifications.

## Steps (with expected outcomes)

### A. Global reminders setting

1. Open **Settings** (via the top-right menu → **Settings**, or via **Child** tab → **Settings**).
   - Expected: You see a **Notifications** section.

2. Toggle **Enable reminders** OFF.
   - Expected: Subtitle indicates reminders are off and existing notifications are cleared.

3. Go to **Add schedule** or **Edit schedule**.
   - Expected: The schedule-level **Enable reminders** control is disabled and shows a subtitle like **“Notifications are disabled in Settings.”**

4. Toggle **Enable reminders** ON in Settings.
   - Expected: Schedule-level **Enable reminders** is enabled again.

### B. Schedule-level reminders toggle

5. Edit an existing schedule and toggle **Enable reminders** OFF, then save.
   - Expected: Save succeeds.

6. Edit the same schedule again.
   - Expected: **Enable reminders** remains OFF for this schedule.

7. Toggle **Enable reminders** ON and save.
   - Expected: Save succeeds.

### C. Notification fire behaviour (manual)

8. Create a schedule with a time 2–3 minutes in the future and reminders enabled.
   - Expected: A local notification fires at the scheduled time.

## Notes / evidence to capture

- Platform permission prompts (iOS/Android) and whether denying permission is handled gracefully.
- If notifications fire at the wrong time, capture timezone/device clock settings.
