# Settings & user guide

## Goal

Validate Settings controls (theme, text size, analytics toggle) and User guide navigation.

## Preconditions

- A profile exists and onboarding is complete.

## Steps (with expected outcomes)

### A. Settings

1. Open **Settings** (top-right menu → **Settings**, or **Child** tab → **Settings**).
   - Expected: Screen title is **“Settings”** and sections include **Profile**, **Appearance**, **Notifications**, **Privacy**.

2. Change **Theme**.
   - Action: Set Theme to **Light**, then **Dark**, then **System**.
   - Expected: The app theme updates immediately.

3. Change **Text size**.
   - Action: Move the slider between each labeled step.
   - Expected: The label updates between **Small / Default / Large / Extra large**.
   - Expected: Text across screens visibly scales (e.g. app bars and body text).

4. Toggle **Share anonymous analytics**.
   - Expected: Toggle state persists when navigating away and back.

5. Open **Privacy policy** and **Request data deletion**.
   - Expected: Each opens a new screen without crashing, and back navigation returns to Settings.

### B. User guide

6. Go to **Guide** tab.
   - Expected: Screen title is **“User guide”**.
   - Expected: A header card appears titled **“Medicines for Children”**.

7. Open a guide section.
   - Action: Tap any section card.
   - Expected: You see the guide detail screen for that section.

8. Navigate back to the guide list.
   - Expected: You return to the list and can open a different section.

## Notes / evidence to capture

- Any text that truncates badly at **Extra large** text size.
- Any theme contrast issues (especially on error cards and disabled controls).
