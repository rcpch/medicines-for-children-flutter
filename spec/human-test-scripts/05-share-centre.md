# Share centre (PDF export/print + shares)

## Goal

Validate Share centre entry point, PDF export/print actions, and the shared schedule list.

## Preconditions

- A profile exists and onboarding is complete.
- At least one medicine and schedule exist (so PDFs are meaningful).
- Device supports file saving (for export) and printing UI (for print).

## Steps (with expected outcomes)

1. Go to **Child** tab → open **Share centre**.
   - Expected: Screen title is **“Share centre”**.

2. In the **Medicines list** card, tap **Export medicines**.
   - Expected: A PDF is generated and saved.
   - Expected: Snackbar: **“Medicines PDF saved.”**

3. Tap **Print medicines**.
   - Expected: Platform print dialog appears.

4. In the **Schedule** card, tap **Export schedule**.
   - Expected: A schedule PDF is generated and saved.
   - Expected: Snackbar: **“Schedule PDF saved.”**

5. Tap **Print schedule**.
   - Expected: Platform print dialog appears.

6. If there are no shared schedules yet:
   - Expected: The list area shows **“There are no shared schedules.”**

7. Tap **New share**.
   - Expected: You are taken to the share creation flow.

## Notes / evidence to capture

- Where exported PDFs land on each platform (Downloads, Files app, etc.).
- Any errors shown in the red error card on this screen.
