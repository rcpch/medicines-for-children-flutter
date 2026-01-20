# Medicines (add/edit/archive + QR)

## Goal

Validate the Medicines list, filters, add/edit flows, archive behaviour, and QR scan flow.

## Preconditions

- A profile exists and onboarding is complete (at least 1 child).
- You are on a device that supports image picking (camera/gallery), if you want to test photos.

## Test data

Create a medicine with:
- Medicine name: `Ibuprofen`
- Known as: `Nurofen` (optional)
- Dose: `5`
- Unit: `ml`
- Route: `Oral`
- Frequency: `Twice daily`
- Type: start with `Everyday`

## Steps (with expected outcomes)

### A. Medicines list and filters

1. Go to **Medicines** tab.
   - Expected: Title is **“Medicines”** and you can see the segmented filter **Everyday / As-needed**.

2. With no medicines created yet:
   - Expected: The list area shows **“No medicines match this filter.”**

### B. Add a medicine (manual)

3. Tap **“Add medicine”**.
   - Expected: You see a form titled **“Add medicine”**.

4. Try to submit with required fields empty.
   - Expected: Validation messages appear (e.g. **“Enter a medicine name”**, **“Enter the dose amount”**, **“Enter the unit”**, **“Enter the route”**, **“Enter the frequency”**).

5. Fill the form using the test data and save.
   - Expected: A snackbar appears: **“Medicine added.”**
   - Expected: You return to the Medicines list and the new medicine tile is visible.

6. Tap the medicine tile.
   - Expected: You see the medicine detail screen, including sections like **Overview** and **Dose**.

### C. Edit the medicine

7. Tap the **Edit medicine** action in the app bar.
   - Expected: You see **“Edit medicine”** with fields pre-populated.

8. Change the dose (e.g. from `5 ml` to `7.5 ml`) and save.
   - Expected: A snackbar appears: **“Medicine updated.”**
   - Expected: The medicine detail screen now shows the updated dose.

### D. Archive the medicine

9. From the medicine detail screen, tap **Archive medicine**.
   - Expected: A confirmation dialog appears titled **“Archive medicine?”** with buttons **Cancel** and **Archive**.

10. Confirm archive.
   - Expected: A snackbar appears: **“Medicine archived.”** and you return to the Medicines list.
   - Expected: The archived medicine no longer appears in the active list.

### E. Add by QR code (happy path)

11. Go to **Medicines** tab → tap **“Add by QR code”**.
   - Expected: Camera scanning UI opens.

12. Scan a QR code that encodes this URL exactly:

   `https://www.medicinesforchildren.org.uk/medicines/ibuprofen-for-pain-and-inflammation/`

   - Expected: The scan is recognized as a known medicine.
   - Expected: You are taken into an add-medicine flow with details prefilled from the QR mapping.

### F. Add by QR code (unknown)

13. Scan a QR code with an unrelated URL (or random text).
   - Expected: The app reports an unknown scan result (exact UI copy may vary) and does not create a medicine.

## Notes / evidence to capture

- If archived medicines still appear under filters, note which filter and provide screenshot.
- QR scanning behaviour depends on camera permissions; capture the permission prompt behaviour on each platform.
