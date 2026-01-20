# Backups (export/import .mfc)

## Goal

Validate creating an encrypted `.mfc` backup and restoring it as a new local profile.

## Preconditions

- At least one profile has meaningful data (child + a medicine + a schedule).
- Your device/emulator can save and pick files.

## Test data

- Backup passphrase: use something memorable (>= 8 chars), e.g. `correct horse`
- Wrong passphrase (for negative test): `wrong horse`
- Import as profile name: `Imported Profile`
- Optional import passcode: set a 4–8 digit value (if prompted)

## Steps (with expected outcomes)

### A. Export backup

1. From any main screen (e.g. Home or Medicines), open the top-right menu.
   - Expected: A menu includes **Settings**, **Export backup**, **Import backup**, **Sign out**.

2. Select **Export backup**.
   - Expected: Dialog titled **“Create a backup passphrase”** appears.
   - Expected: Entering < 8 characters shows validation: **“Use at least 8 characters”**.

3. Enter a valid passphrase and confirm it.
   - Expected: If the confirmation doesn’t match, you see **“Passphrases do not match”**.

4. Continue.
   - Expected: A file is saved named like `mfc-backup-YYYYMMDD_HHmm.mfc`.
   - Expected: Snackbar: **“Backup exported. Store it somewhere safe.”**

### B. Import backup (happy path)

5. On the same device, select **Import backup**.
   - Expected: A file picker opens filtered to `.mfc`.

6. Pick the exported backup file.
   - Expected: You are prompted for import details (profile name, and passcode if supported).

7. Enter a new profile name (e.g. `Imported Profile`) and continue.
   - Expected: You are prompted for the backup passphrase.

8. Enter the correct passphrase.
   - Expected: Snackbar: **“Backup imported as a new profile.”**

9. Sign out and verify the new profile exists.
   - Action: Top-right menu → **Sign out**.
   - Expected: Profile picker shows the newly imported profile.

### C. Import backup (wrong passphrase)

10. Start **Import backup** again and pick the same file.

11. When asked for passphrase, enter the wrong passphrase.
   - Expected: Snackbar: **“Incorrect passphrase. Try again.”**
   - Expected: You remain in the passphrase loop and can try again or cancel.

## Notes / evidence to capture

- Exact behaviour of the “import details” prompt (which fields appear, passcode length rules).
- Where the exported `.mfc` file is saved on each platform.
