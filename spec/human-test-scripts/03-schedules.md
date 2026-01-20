# Schedules (add/edit/delete)

## Goal

Validate schedule creation, list display, editing, deletion, and the related Home view.

## Preconditions

- A profile exists and onboarding is complete.
- At least one active medicine exists (see [02-medicines.md](02-medicines.md)).

## Test data

- Medicine: use an existing active medicine (e.g. `Ibuprofen`).
- Start date: today.
- End date: today + 7 days.
- Times: `08:00` (and optionally add `20:00`).
- Weekdays: all selected.

## Steps (with expected outcomes)

### A. Create a schedule

1. Go to **Home** tab.
   - Expected: Home shows the selected child and a schedule section.

2. Tap **Add schedule** (or go to the Schedules management screen via **Manage schedules**).
   - Expected: You see a form titled **“Add schedule”**.

3. Confirm the form shows:
   - **Medicine** dropdown
   - **Start date** and **End date** pickers
   - **Weekdays** chips
   - **Times per day** chips and an **Add time** action
   - **Enable reminders** toggle

4. Set the dates and times per the test data and submit **Add schedule**.
   - Expected: Schedule saves successfully (no error snackbar).

### B. Verify schedules list

5. Navigate to the schedules list.
   - Expected: Screen title is **“Schedules”**.
   - Expected: Each schedule card shows medicine name, a date range (“From … to …”), and times.

### C. Edit a schedule

6. In the schedules list, open the overflow menu for a schedule and choose **Edit**.
   - Expected: You see **“Edit schedule”** with the existing values selected.

7. Add a second time (e.g. `20:00`) via **Add time**, then **Save schedule**.
   - Expected: Returning to the schedules list, the schedule subtitle now includes both times.

### D. Delete a schedule

8. In the schedules list, open the overflow menu and choose **Delete**.
   - Expected: Confirmation dialog titled **“Delete schedule?”**.
   - Expected: Copy mentions removing future doses.

9. Confirm **Delete**.
   - Expected: Snackbar shows **“Schedule deleted.”**
   - Expected: The schedule no longer appears in the list.

### E. Verify Home reflects the schedule

10. Return to **Home** tab and select today’s date.
   - Expected: The schedule entry appears in the relevant time-of-day section.
   - Expected: If you switch child via the child switcher, Home reflects that child’s schedules.

## Notes / evidence to capture

- If **Enable reminders** is disabled because notifications are disabled in Settings, note the Settings state.
- Capture screenshots for any date validation issues (e.g. end date before start date).
