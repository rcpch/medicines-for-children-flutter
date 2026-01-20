# Onboarding & profiles

## Goal

Validate creating a local profile, completing onboarding (carer + first child), and basic navigation once onboarded.

## Preconditions

- App installed / runnable.
- You can delete app data (or uninstall/reinstall) to simulate a clean start.

## Test data

- Carer name: `Test Carer`
- Relationship: `Parent`
- Phone number: `07000 000000`
- Child name: `Alex Test`
- Child condition: `Asthma` (optional)

## Steps (with expected outcomes)

1. Launch the app on a clean install / cleared app data.
   - Expected: You see the initial profile selection / sign-in experience (no previously selected profile).

2. Create/select a local profile.
   - Expected: A profile is selected and you are taken into onboarding if the profile is incomplete.

3. On the onboarding screen titled **“Complete your profile”**, complete step 1 (carer details).
   - Action: Enter first name, last name, relationship, and phone.
   - Expected: Continue advances to the next step. Missing required fields show validation errors.

4. Complete step 2 (child details).
   - Action: Enter child first/last name and pick **Date of birth** using the date picker.
   - Expected: Date picker opens in year selection mode, and DOB is constrained to the last 18 years.

5. Complete the final step.
   - Expected: On submission, you see a snackbar: **“Profile saved. Welcome to Medicines for Children.”**

6. Confirm tab navigation.
   - Action: Use the bottom tabs to visit **Home**, **Medicines**, **Child**, and **Guide**.
   - Expected: Each screen loads without errors and the current child is reflected consistently.

7. (Optional) Add a second child.
   - Action: Go to **Child** tab → tap the **Add child** action → complete the **Add child** form.
   - Expected: A snackbar appears: **“Child added.”**

8. Switch active child.
   - Action: Use the child switcher (top app bar action) to select the other child.
   - Expected: Home/Medicines/Child screens now show the newly selected child’s data.

## Notes / evidence to capture

- Screenshots of any validation error states that look wrong.
- If child switching does not update all tabs, record which tab stayed stale.
