# Functional Specification: Medicines for Children (Flutter Port)

## User Roles and Authentication

- **Primary carer (account owner)**
  - Uses the native iOS app and Flutter app to manage one or more children, their medicines, schedules, and care network.
  - Authenticates locally via a device profile with an optional passcode (no mandatory backend).
  - Can:
    - Create a local profile and onboard their child’s profile.
    - Add/edit medicines and schedules.
    - Set up secondary carers and shared schedules.
    - Export schedules as PDFs or digital links.
    - Export an encrypted backup file for personal cloud/USB/email storage.

- **Secondary carer (invited carer)**
  - Accesses a web-based schedule and information view via a unique link sent by the primary carer.
  - Does not have a password-based login; instead uses a one-time/action token embedded in the URL.
  - After token verification, receives a short-lived “auth token” to:
    - View the shared schedule (dates, medicines, per-day doses).
    - Accept or decline the care period.
    - Record administrations (scheduled and as-needed) against the shared schedule.
    - Download the shared schedule (PDF or view online), and see key child information.

- **System / backend roles**
  - **Backend API** enforces:
    - API key (“ApiKey” header) for primary-carer initiated operations (creating and listing shared schedules, exporting PDFs, etc.).
    - Token-based auth (“Authorization: token …”) for secondary-carer operations (viewing schedule, confirming, recording administrations).
  - **Action tokens** (one-time link tokens) are issued and validated by backend repositories for secure access to shared schedules.

- **Registration and onboarding (primary carer, Flutter app)**
  - **Signup flow**:
    - User creates a local profile (name + optional passcode).
    - A guided onboarding flow collects primary carer profile (name, relationship, contact numbers) and initial child data (name, DOB, condition, allergies, etc.).
    - Data is written into a local, offline-first JSON store scoped to the profile.
  - **Onboarding screens** explain app purpose and set up the first child before reaching the home screen.

- **Login / logout (Flutter)**
  - **Login**:
    - Profile picker lists local profiles on this device.
    - If a profile has a passcode, the user unlocks it locally.
    - On success, app loads locally stored profile data (primary carer, children, medicines, schedules).
  - **Logout**:
    - Clears the active profile selection and returns to the profile picker.

- **Secondary carer web auth flow**
  - Secondary carer receives a **link containing a token** parameter.
  - **Authorization step**:
    - Web app extracts the token from the query string.
    - Calls  on the backend.
    - Backend:
      - Verifies that token is valid, not revoked, within allowed timeframe, and bound to a specific shared schedule.
      - Returns a structure including:
        -  (the  of the schedule).
        -  for authenticated API use.
  - **Authenticated operations**:
    - Web app calls:
      -  with  to retrieve the schedule.
      -  to approve or decline the care period.
      -  and  to record or update medicine administrations.
      -  to generate a shared schedule PDF when authenticated.
  - If any authentication or authorization step fails, the user is redirected to an “unavailable” screen.

---

## Core Data Model

### PrimaryCarer

- **Represents**: The main account holder and legal guardian who manages the child’s medicines and care network.
- **Key fields (Flutter local model)**
  - Identification: local profile ID, optional email, optional profile image path.
  - Personal: , , `childRelationship` (e.g. parent, guardian).
  - Contact: `mobilenumber`, `homenumber`, `worknumber`.
  - Relationships:
    - : array of Child objects (on iOS, typically accessed via index 0).
    - `contacts`, `correspondence` records (additional contacts and communication).
- **Relationships**
  - One PrimaryCarer → many Children (though UI heavily focuses on one child at a time).

### Child

- **Represents**: A child whose medications and care schedule are being managed.
- **Key fields (Flutter local model)**
  - Personal: , , `dob`, , `ageMonths`, , .
  - Medical:  (main condition/diagnosis), , ,  (important notes),  (personal preferences/notes), `nhs_number`.
  - Media:  for child photo.
- **Relationships**
  - : list of Medicine records.
  - : dictionary keyed by schedule ID → Schedule (regular schedules).
  - `asNeededSchedules`: dictionary keyed by medicine ID → AsNeededSchedule.
  - `carers`: list of Carer entries (secondary carers who are part of the care network).
  - `sharedSchedules`: list of SharedSchedule objects representing sharing sessions with secondary carers.
  - Stored locally per profile; optional shared schedule backend uses a read-only subset.

### Medicine

- **Represents**: A specific medication the child takes.
- **Key fields (Flutter local model)**
  - Identification: locally generated ID, ,  (alias/brand/common name).
  - Classification:  (e.g. “Everyday”, “As-needed”, “Both”),  (what condition/symptom it treats).
  - Dosage/frequency:
    -  (numeric or textual dose),  (displayed unit portion),  (e.g. daily, weekly).
    -  (times per day).
    -  (e.g. oral, inhaled, injected).
    -  (measure description; in old model might map to ml, tablet, etc.).
    -  (e.g. mg/ml).
  - Status: `in_use`, `no_longer_used`,  (backend).
  - Notes:  (free text, instructions, special considerations).
  - Media: , ,  for visual identification (packaging, tablet, device).
- **Relationships**
  - A Child has many Medicines.
  - Schedules refer to medicines by ID, and the app re-hydrates full medicine details when loading schedules.
  - AsNeededSchedules link directly to a medicine.

### Schedule (regular)

- **Represents**: A repeating medication schedule for a given medicine (e.g. “Amoxicillin twice a day for 7 days”).
- **Key fields**
  - Identification:  (schedule document ID).
  - Associated medicine:  (full Medicine object on iOS; ID on backend).
  - Timing:
    - ,  (as strings in iOS; Dates on backend).
    - : array of times as strings in “hh:mma” format (e.g. “8:00am”).
    - : array of booleans length 7 for each weekday, indicating which days the schedule runs.
  - Administrations:
    - : dictionary keyed by “yyyy-MM-dd h:mma” → Administration (per-dose record).
- **Relationships**
  - Child → many Schedules.
  - Each Schedule belongs to exactly one Medicine.
  - Administrations record actual given/ skipped doses against each scheduled time.

### AsNeededSchedule and AsNeededAdministration

- **AsNeededSchedule**
  - Represents a medicine which is taken on an as-needed basis rather than by fixed schedule.
  - Fields:
    -  (often same as medicine ID).
    - : Medicine object.
    - `asNeededAdministrations`: dictionary keyed by “yyyy-MM-dd h:mma” → AsNeededAdministration.
- **AsNeededAdministration**
  - Represents a single recorded as-needed dose.
  - Fields:
    - `datetime` string (“yyyy-MM-dd h:mma”).
    -  (email of person administering).
    -  (optional comment).
- **Relationships**
  - Child → many AsNeededSchedules (one per as-needed medicine).
  - AsNeededSchedule → many AsNeededAdministrations.

### Administration (shared schedule / backend)

- **iOS local administration**
  - Simple record with:
    - `datetime` string, ,  (bool), .
- **Backend Administration**
  - More structured administration record used for shared schedules:
    -  (Date) and  (date normalized to midnight for grouping).
    -  (ID of schedule item or “ASNEEDED” special marker).
    -  (true for as-needed doses).
    -  (user ID or email).
    - , .
    -  (medicine reference, or “SCHEDULED”/“ASNEEDED” markers).
    -  (string representation used by frontend).
    - ,  (internal flags).
- **Relationships**
  - Associations to either:
    - A ScheduledItem (regular scheduled dose).
    - A medicine as as-needed, marked via  and .

### Carer / Secondary Carer

- **Represents**: People other than the primary carer who may care for the child.
- **Key fields**
  -  /  (for secondary carers who have user docs).
  - `firstName`, `lastName`.
  -  (e.g. grandparent, friend).
  - Contact: `emailAddress`, mobile/home phone, `photoURL`.
- **Data storage**
  - Secondary carers are stored in backend documents, with:
    - `addedBy` (primary user UID).
    -  flag for soft delete.
    - Relationship and contact details.
- **Relationships**
  - Child → many Carer entries.
  - SharedSchedule references one  and resolves to a corresponding user record.

### SharedSchedule

- **Represents**: A sharing period where a child’s medications and schedule are shared with a secondary carer for a defined time window.
- **Key fields (iOS + backend)**
  - Identification:
    -  (often  in backend).
    -  used as external ID for APIs and web client.
  - Time window:
    - ,  (Dates in backend; string + `dateFromObj`/`dateToObj` in iOS).
    - On backend,  /  are integer comparisons derived from / times.
  - Participants:
    - : email identifier for the invited carer.
    -  (Carer object with name, relationship, contact).
    - Backend view model includes , , .
  - Settings:
    - : true for digital (web-based) schedule; false for non-digital (PDF-only).
    - : indicates soft deletion or termination.
    - : values like “Pending”, “Approved”, “Declined” (and possibly other terminal statuses).
    - : optional explanation when a carer declines or a share is ended.
    - : general notes from the primary carer for this period.
  - Output:
    - `scheduleURL` (digital schedule link provided by backend).
    - `pdfURL` (for non-digital schedules where a PDF is generated).
- **View model**
  - The SharedScheduleViewModel enriches this with:
    - : array of SharedScheduleDay objects (one per date in the range).
    - : a MinChild with key information (allergies, condition, notes).
    -  and  arrays.
    -  captured in the shared context.
- **Relationships**
  - Links a single Child (by path) and a single PrimaryCarer / secondary carer pair.
  - Pulls underlying child data (medicines, schedule, administrations) into a share-specific snapshot.

### ScheduledItem

- **Represents**: A single recurring scheduled medication pattern in a shared schedule context.
- **Key fields**
  -  (identifier for the scheduled item).
  -  (medicine ID).
  - ,  (Date).
  -  (booleans per weekday).
  - : original AM/PM times as strings.
  - : numeric times used for comparison.
  - : earliest scheduled dose time (for business logic).
- **Relationships**
  - Part of a SharedScheduleDay’s .
  - Linked to administrations via .

### SharedScheduleDay

- **Represents**: A single calendar day within a shared schedule period.
- **Key fields**
  -  (Date).
  -  (index of weekday 0–6).
  -  (string for administration documents).
  - : array of ScheduledItem instances scheduled for that day.
  - : boolean marking the current day for UI emphasis.

### WcUser

- **Represents**: A generic user record in the backend (primary or secondary).
- **Key fields**
  - , , .
  - Contact: , , , .
  -  (to the child).
  - Optional  array (used for primary carers).
- **Relationships**
  - For secondary carers, used to augment SharedSchedule view model with carer details.
  - For primary carers, underlying data for the iOS app.

### ActionToken and newAdministration

- **ActionToken**
  - Encodes secure share invitation details:
    - Token string and encryption IV.
    - Associated shared schedule ID.
    - Deleted / revoked flag.
    - Additional metadata to support authorization checks.
- **newAdministration**
  - Payload for creating/updating an administration via backend:
    -  (shared schedule ID).
    - , , .
    -  (Date),  (Timestamp).
    -  or  depending on scheduled vs as-needed.
    -  linking to the primary carer.
    - Optional , ,  fields for internal use.

---

## Mobile App Features and Screens

### Onboarding and Signup

- **OnboardingViewController / OnboardingPage**
  - Purpose:
    - Introduce the app’s purpose (managing a child’s medicines and care).
    - Guide new users through high-level steps before account creation.
  - Key UI:
    - Scrollable, multi-page onboarding content.
    - Buttons to proceed to signup.
  - Navigation:
    - From Home if user not logged in and first use.
    - On completion, navigates to SignupViewController.

- **SignupViewController**
  - Purpose:
    - Register new primary carers and set up initial child data.
  - Key UI:
    - Profile name field and optional passcode entry.
    - Forms for primary carer details (name, relationship, contact).
    - Forms for first child’s details (name, DOB, condition, allergies, etc.).
    - WebView segments to show terms or guidance (via embedded web content).
  - Actions:
    - Create a local profile.
    - Write PrimaryCarer record to local JSON storage.
    - Create first Child record and attach to the profile.
  - Navigation:
    - Reached from Login or onboarding.
    - On success, transitions to main tab bar with HomeViewController.

### Authentication and Entry

- **LoginViewController**
  - Purpose:
    - Select a local profile and optionally unlock it with a passcode.
  - Key UI:
    - Profile list with selection.
    - Passcode prompt when required.
    - Buttons to create a new profile.
  - Behaviour:
    - Selects a local profile and unlocks it if passcode-protected.
    - Loads primary carer and child data from local storage.
    - On failure (wrong passcode), shows an error message.
  - Navigation:
    - Shown when user not logged in (from Home).
    - Can push to Signup and Onboarding.

### Home and Schedule Overview

- **HomeViewController**
  - Purpose:
    - Primary dashboard for the day’s medicines and shared care context.
    - Presents a calendar and per-day bins of scheduled and as-needed administrations.
  - Key UI and behaviour:
    - Calendar strip (JKCalendar) at top; scrolling/thumbnails for days.
    - Day header (“Monday 12 Dec 2025”) with segmented schedule view.
    - Time-of-day bins:
      - Morning (6am–12pm), Afternoon (12pm–5pm), Evening (5pm–11pm), Night (11pm–6am).
      - Each bin lists scheduled doses and as-needed administrations as cards with:
        - Medicine name, dose, strength, and image.
        - Time, status (Scheduled, Taken, Skipped), and notes.
        - Quick action buttons:
          - Mark as “Given” / “Skipped”.
          - Undo operations.
      - For shared schedules, cards visually highlight who is responsible (e.g. text “Due by [carer name]”) and include entry for shared start/end points.
    - “Add to schedule” popup:
      - Options to add recurring action or as-needed.
    - Share centre access:
      - Button to open a sharing hub/ShareCentre storyboard (for creating and managing shared schedules).
  - Data operations:
    - On appear:
      - If not logged in:
        - Clears content and pushes Login (and optionally Onboarding at first use).
      - If logged in:
        - Fetches shared schedules via backend API.
        - Fetches child’s schedules and regular administrations from local storage (or backend if sync is enabled).
        - Fetches as-needed administrations.
        - Builds and presents the schedule view for the currently selected date.
    - Local notifications:
      - Offers to “turn on notifications” for existing scheduled medicines.
      - Creates notifications for each schedule and time; stores metadata in UserDefaults.
      - Maintains notifications by removing entries past schedule end dates.
  - Navigation:
    - Central tab; other tabs likely include Medicines and Profile.
    - From Home, user can:
      - Open Share Centre.
      - Open schedule management screens (AddScheduleViewController, AsNeededViewController).
      - Navigate to medicine details via cards for quick access.

### Medicines Management

- **MedicinesViewController**
  - Purpose:
    - List a child’s medicines, filtered by type (everyday vs as-needed).
  - Key UI:
    - Segmented control to toggle between “Everyday” and “As-needed” medicines.
    - Table view listing medicines:
      - Name.
      - Strength.
      - Dose per administration.
      - Thumbnail image of the medicine (photo1 or fallback).
    - “Add medicine” button.
  - Behaviour:
    - On appear:
      - Loads medicines via local storage (or backend if sync is enabled).
      - Applies the last used filter (“Everyday” or “As-needed”) from app state.
    - Filter logic:
      - Shows medicines whose  matches filter or is “Both”.
    - Row selection:
      - Navigates to medicine details screen (MedicineViewController) with the selected medicine.
  - Navigation:
    - Tab bar entry or accessible via other flows (e.g. from child profile).

- **MedicineViewController**
  - Purpose:
    - Show and edit details of a single medicine.
  - Likely UI (inferred):
    - Detailed fields for name, dose, frequency, route, strength, measure, notes, who it’s for.
    - Multiple photos display with the ability to add or change images.
    - Buttons to edit medicine details and possibly to archive/mark no longer in use.
    - Links to schedules using this medicine.
  - Navigation:
    - From MedicinesViewController or schedule entries.
    - May allow editing and saving changes via NetworkHelper.

- **AddMedicineViewController**
  - Purpose:
    - Create a new medicine record for the child.
  - Key UI (inferred from delegates and NetworkHelper):
    - Form fields for:
      - Name, known-as, medicine-for, notes.
      - Dosage, amount, frequency, times-per-day, route, measure, strength, type (Everyday/As-needed/Both).
    - Image picker to capture or select medicine photos.
    - Picker view for selecting dose/unit combinations.
  - Behaviour:
    - On save:
      - Validates required fields.
      - Calls NetworkHelper.addChildData / addMedicineData to store the medicine under the child’s medicines collection.
  - Navigation:
    - Presented full screen from MedicinesViewController.

### Schedule and As-Needed Management

- **AddScheduleViewController**
  - Purpose:
    - Create or edit a recurring schedule for a selected medicine.
  - Key UI (inferred):
    - Table for picking one or more times per day.
    - Date pickers for start and end dates.
    - Weekday selector (booleans array for each day).
    - Toggle (notificationSwitch) for turning local notifications on/off for that schedule.
  - Behaviour:
    - On save:
      - Creates a schedule record with startDate, endDate, times, days, and medicine ID.
      - Calls NetworkHelper.createSchedule to persist it.
      - Configures local notifications if notifications are enabled.
    - Additional actions:
      - Option to “stop” a schedule (set endDate to yesterday).
  - Navigation:
    - Accessible from Home (“Add to schedule” popup) and possibly from MedicineViewController.

- **AsNeededViewController and AddAsNeededViewController**
  - Purpose:
    - Present as-needed medicines and allow recording as-needed administrations.
  - Key behaviour:
    - AsNeededViewController:
      - Summarizes as-needed medicines for the child and existing as-needed administrations.
      - Allows navigation to detailed as-needed flows.
    - AddAsNeededViewController:
      - Lets user pick a medicine and enter time and notes to record a new as-needed administration.
      - Uses NetworkHelper.createAsNeededAdministration to persist it.
      - Optionally displays history for the chosen medicine.
  - Navigation:
    - From Home (“Add as-needed” from popup) or dedicated screens/tab.

### Child Profile and Data

- **ChildViewController & ChildDataViewController**
  - Purpose:
    - View and edit child’s personal and medical profile.
  - Key UI (inferred):
    - Child photo, name, age, and summary blocks.
    - Sections for:
      - Condition and important notes.
      - Allergies.
      - Personal preferences.
      - NHS number and other identifiers (possibly less prominently).
  - Behaviour:
    - Shows existing data from appDelegate.primaryCarer.children[0].
    - Editing triggers local persistence (and optional backend sync if configured).
  - Navigation:
    - Part of profile or settings section.

### Care Network and Carers

- **CareNetworkViewController**
  - Purpose:
    - Manage the list of secondary carers (care network) for the child.
  - Key UI:
    - Table view listing existing carers with name, relationship, contact info, photo.
    - Actions for adding, editing, and deleting carers.
  - Behaviour:
    - Uses NetworkHelper.getCarers to load carers (based on `addedBy` filter).
    - Deletion triggers NetworkHelper.deleteCarer to set  flag.
    - Adding/editing uses NetworkHelper.addEditSecondaryCarer.
  - Navigation:
    - From Child or Profile sections; integrated with Share Centre flows.

- **CarerViewController & AddEditSecondaryCarerViewController**
  - Purpose:
    - Detailed view and editing of a single secondary carer’s information.
  - Key UI:
    - Carer name, relationship, email, phone, and photo.
    - Controls to update or remove the carer from the network.

### Sharing Centre and Shared Schedules

- **ShareCentreViewController**
  - Purpose:
    - Central hub for creating, viewing, and managing shared schedules.
  - Key UI (inferred):
    - Button(s) to set up a new share.
    - Table/list of existing shared schedules for the child, including:
      - Secondary carer’s name.
      - Date range.
      - Status (Pending/Approved/Declined/Ended).
      - Digital vs PDF icon.
  - Behaviour:
    - Uses NetworkHelper.getSharedSchedules to load the list (via backend API).
    - Allows entering flows for creating a new share, editing, ending, or deleting a share.
  - Navigation:
    - Accessed from Home (e.g. “Sharing Centre” button).

- **CreateShareViewController / SetupShareViewController / ConfirmShareViewController / LinkShareViewController**
  - Purpose:
    - Multi-step wizard to create a shared schedule:
      - Select existing secondary carer (or add a new one).
      - Choose dates and times for the sharing period.
      - Compose notes and choose digital or PDF mode.
      - Confirm details and send the invite or generate a PDF.
  - Behaviour:
    - CreateShareViewController:
      - Retrieves carers via NetworkHelper.getCarers.
      - Allows selection of one as the secondary carer for this share.
    - SetupShareViewController:
      - Gathers dateFrom/dateTo and notes + digital/non-digital choice into a SharedSchedule object on the app side.
    - ConfirmShareViewController:
      - Final confirmation of share details.
      - Calls NetworkHelper.createSharedSchedules to invoke POST /sharedSchedule on the backend.
      - Receives either:
        - For digital: a schedule URL to share.
        - For non-digital: a generated PDF URL.
      - May present LinkShareViewController to display the shareable URL or instructions, or trigger system sharing UI.
  - Navigation:
    - From ShareCentreViewController, through these steps, then back to the share centre.

- **SharedScheduleViewController / ViewScheduleSharesViewController**
  - Purpose:
    - View and manage specific shared schedules from the primary carer’s perspective.
  - Key features:
    - ViewScheduleSharesViewController:
      - Displays list of shared schedules with statuses and date ranges.
      - Allows selection for detail view.
    - SharedScheduleViewController:
      - Shows details for a chosen shared schedule, including:
        - Secondary carer’s name and relationship.
        - Date range, notes, whether digital or PDF.
        - Status and reason (e.g. reason for decline).
      - Actions:
        - Extend the schedule (calls NetworkHelper.extendSharedSchedules → PUT /sharedSchedule/:apiId).
        - End the schedule early (calls NetworkHelper.endSharedSchedules → GET /sharedSchedule/end/:apiId).
        - Delete the schedule (calls NetworkHelper.deleteSharedSchedules → PUT /sharedSchedule/:apiId with deleted flag).
        - Export the schedule as PDF (via ExportScheduleViewController).

- **ExportScheduleViewController / ExportMedicineViewController**
  - Purpose:
    - Export the child’s schedule (or medicine information) as a PDF for printing or offline use.
  - Behaviour:
    - ExportScheduleViewController:
      - Lets the primary carer select date range.
      - Calls NetworkHelper.ExportSchedule (POST /exportSchedulePdf with ApiKey) to generate and receive a PDF URL.
      - Presents result for download/sharing.
    - ExportMedicineViewController:
      - Likely outputs a summary of medicines; using similar patterns for display/export.

### Profile and Settings

- **ProfileViewController**
  - Purpose:
    - Present aggregated account and child information, with access to editing flows.
  - Key UI:
    - Profile header (ProfileHeaderView) with carer name, child name and photo.
    - Table sections linking to:
      - Child profile.
      - Care network.
      - Settings (e.g. notifications).
      - Privacy / information screens.
  - Behaviours:
    - Loads current primary carer and child data.
    - Triggers editing flows for user details and child data.

- **EditCarerDataViewController / EditChildDataViewController**
  - Purpose:
    - Edit primary carer and child profile details.
  - Behaviour:
    - On save:
      - Calls NetworkHelper.updatePrimaryCarer or updateChildData to persist.
      - Optionally uploads new profile photos via NetworkHelper.uploadImage.

---

## Web App Features

### Overall Web Flow

- The web app serves **secondary carers** who open a link for a specific shared schedule.
- A typical flow:
  1. Link with  opened in browser.
  2. ScheduleView mounted; it extracts the token and calls  (GET /auth/:token).
  3. If authorization returns  and , it calls  (GET /sharedSchedule/:apiId).
  4. Based on returned schedule :
     - If “Pending” → route to /confirm flow.
     - If approved → route to /schedule view.
  5. Secondary carer interacts with:
     - Confirmation (accept/decline).
     - Schedule view with per-day, per-dose operations.
     - Important info and download options.

### Routes and Views

- **/confirm –  (confirmation)**
  - Purpose:
    - Ask the secondary carer explicitly whether they agree to take on the care period.
  - UI:
    - Hero introducing them by name and outlining the care dates and context.
    - Date range summary: “You will be looking after [child] over these dates: [dateFromStr] to [dateToStr].”
    - Acceptance form (m-form-accept) to confirm they can look after the child.
  - Behaviour:
    - If they previously agreed ( in store), automatically route to /schedule.
    - On acceptance:
      - Likely sends a confirmation to backend ( with approved=true) and routes to /thanks or direct /schedule (implementation distributed across components).

- **/decline – **
  - Purpose:
    - Double-check whether the carer wants to decline.
  - UI:
    - Warning hero: “Are you sure you want to decline care for [child]?”
    - Two buttons via m-yes-no:
      - “Yes, please decline”.
      - “No, take me back”.
  - Behaviour:
    - On yes:
      - Calls  via scheduleService.
      - Routes to /thanks (decline acknowledgement).
    - On no:
      - Routes back to /confirm.

- **/thanks – ThanksView.vue**
  - Purpose:
    - Acknowledge the user’s response (accept or decline).
  - UI:
    - Friendly thank-you messaging; status-specific copy (either “thanks for confirming” or “thanks for letting us know you can’t help this time”).
  - Behaviour:
    - Static acknowledgement; does not change data.

- **/accept – ThanksAcceptView.vue**
  - Purpose:
    - Specific thank-you page used when user accepts care.
  - UI and behaviour:
    - Similar to /thanks but tailored to acceptance, possibly including next steps (“You can now view the schedule”).

- **/schedule – **
  - Purpose:
    - Main working screen for secondary carers to see and record medicine taking over the shared period.
  - UI:
    - Hero greeting secondary carer by name and thanking them for looking after the child.
    - Guidance section on how to use the schedule.
    - Info switcher control (m-info-switcher) toggling between “Schedule” and “Important info” views.
    - o-schedule component:
      - Shows per-day grid of “taking pills” entries.
      - Each entry:
        - Tied to a scheduled item or an as-needed administration.
        - Shows medicine name, dosage, time, and current administration status.
        - Provides UI to record new administrations (e.g., “Given” or “Skipped”) and add notes.
  - Behaviour:
    - On mount:
      - Performs auth and schedule loading as described above.
      - If schedule not found or user unauthorized, routes to /unavailable.
    - `syncSchedule`:
      - Fetches latest schedule data via getSchedule using stored  and .
      - Rebuilds takingPills lists and updates store.
    - Creates local “takingPills” structures with time-sorted entries for each day, integrating existing scheduled and as-needed administrations.

- **/info – **
  - Purpose:
    - Provide key medical and contextual information about the child during the care period.
  - UI:
    - Hero greeting secondary carer and child.
    - Info-switcher with schedule/info toggle.
    - Download schedule component (m-download-schedule) linking to a PDF or similar.
    - Dates component (m-looking-dates) showing care period with human-readable strings.
    - Important info blocks:
      - Period length summary (days, hours, minutes).
      - “Important notes” showing child condition and notes.
      - “Allergies” section listing allergies.
  - Behaviour:
    - Computes difference between  and  to show the run duration.

- **/record – **
  - Purpose:
    - Confirm recording of a specific medicine administration.
  - UI:
    - Warning hero: “Are you sure you want to record this medicine as given?”
    - Yes/No buttons via m-yes-no (currently stubbed; actual API call present or added elsewhere).
  - Behaviour:
    - Intended to:
      - On yes, post a new administration record to backend.
      - On no, navigate back to /schedule.
    - Implementation is partially stubbed in the current view.

- **/unavailable – Unavailable.vue**
  - Purpose:
    - Inform user the schedule is unavailable (invalid link, expired token, unauthorized, or backend error).
  - Behaviour:
    - Reached when:
      - Authorization fails.
      - Schedule retrieval via backend fails or returns no schedule.
      - Backend returns unauthorized/forbidden status.

---

## Backend and API Behaviour (Optional)

### Technologies and Setup

- **Platform**: Optional HTTP backend (implementation may vary; Flutter client treats it as an HTTP API).
- **Services used**:
  - Document database for shared schedule data.
  - Object storage for PDFs (if PDF export is enabled).
- **Deployment details**:
  - The backend exposes an Express-style API surface with API key + token-based auth.
  - Timezone is set to `Europe/London` for server-side date computations.

### Data Collections and Structure (Backend Store)

- **Primary carer and children**
  - Collection `user` (legacy backend schema):
    - Document ID: primary carer’s email.
    - Fields: personal and contact info, relationship, profile image, etc.
    - Subcollection :
      - Docs with string indices “0”, “1”, etc.
      - Fields: child personal and medical profile fields.
      - Subcollections:
        - : documents with Medicine fields.
        - `schedule`: documents representing regular schedules with:
          - , ,  array,  boolean array,  reference ID.
        - `administered`:
          - Document per schedule ID.
          - Subcollection :
            - Documents keyed by exact datetime string (“yyyy-MM-dd h:mma”).
            - Fields: , , , .
        - `asneeded`:
          - Document per medicine ID with  flag.
          - Subcollection :
            - Documents keyed by datetime string.
            - Fields: , , .

- **Shared schedules**
  - Collection group `sharedSchedule`:
    - Each document holds a SharedSchedule record:
      - , , ,  (email), , , , , , , , etc.
    - The parent path encodes the primary user and child path, allowing the backend to locate the underlying child doc.
  - `mySharedSchedules` is retrieved by querying relevant sharedSchedule docs filtered by .

- **Actions and tokens**
  - Action tokens stored in an actions-like collection (ActionsRepository):
    - Contain the action type (“view-shared-schedule”), token, encryption IV, deletion flags, etc.
    - Used to validate incoming  requests.

### HTTP Endpoints (mfcapi)

- **Service root**
  - `GET /`
    - Returns .

- **Shared schedule retrieval**
  - 
    - Auth:
      - Requires AuthRepository.authenticate(req) to verify .
      - Requires AuthRepository.authorize(req, apiId) to ensure token is associated with this specific shared schedule.
      - On failure: 401 Unauthorized or 403 Unauthorized (forbidden).
    - Behaviour:
      - Queries `sharedSchedule` group where  equals .
      - If matching document found:
        - Finds underlying child path from the schedule’s reference path.
        - Loads child document and its subcollections:
          - `administered` and `asneeded` to build Administration lists.
          - `schedule` to build ScheduledItem list.
          -  to build Medicine list.
        - Computes:
          -  and  from /.
          - All dates in range using DateRepository.
          - For each day:
            - Day index () and whether it is today.
            -  filtered by that weekday.
          - MinChild summary from child data.
          - Parent and secondary-carer WcUser records by email.
        - Constructs and returns:
          - If  is “Pending”:
            - A simpler pending view with config (no  array).
          - Otherwise:
            - Full SharedScheduleViewModel with , , , , , , etc.
      - Response:
        - 200 with array (either empty or containing one view model).
        - 500 on internal error.

- **Web auth for secondary carers**
  - 
    - Behaviour:
      - Looks up ActionToken with type “view-shared-schedule” by token.
      - If token not found, revoked ( true), or invalid:
        - 403 Unauthorized.
      - If token has :
        - Decrypts token to extract  (shared schedule ID).
        - Calls AuthRepository.authorizeActionToken to:
          - Validate action token for that shared schedule.
          - Possibly create a derived .
        - If successful: 200 with result including  and .
      - Errors: 500 with error message.

- **PDF exports**
  - `POST /exportSchedulePdf`
    - Auth:
      - Requires `ApiKey` header; uses AuthRepository.authApiKey to validate.
      - 401 Unauthorized if api key invalid.
    - Request:
      - JSON body with:
        -  and  as simple date/time strings.
        - .
    - Behaviour:
      - PdfRepository.generatePdf(dateFrom, dateTo, primaryCarerEmail).
      - On success: 200 with .
      - On failure: 500 with  and .

  - 
    - Auth:
      - Requires  and passes  + .
    - Request:
      - Body similar to above: , , .
    - Behaviour and responses similar to `exportSchedulePdf`, but scoped to a shared schedule.

- **Shared schedule creation and management (primary carer)**

  - `POST /sharedSchedule`
    - Auth:
      - Requires API key ().
    - Request body:
      -  and  as decomposed objects:
        - , , , , .
      - ,  flag (boolean), , .
    - Behaviour:
      - Constructs Date objects for from/to.
      - Validates that all necessary fields are present.
      - Builds NewScheduleConfig with date range, notes, digital and email addresses, sets  = “Pending” and  = "0" (to be replaced).
      - Calls SharedScheduleRepository.createSharedSchedule(config).
      - If :
        - Generates PDF using PdfRepository and attaches  to response.
      - Returns:
        - 200 with created shared schedule object (including , status, scheduleUrl or pdfUrl).
        - 500 if creation or PDF generation fails.

  - `POST /mySharedSchedules`
    - Auth:
      - Requires API key.
    - Request body:
      -  (required).
      - Optional filters: , , , .
    - Behaviour:
      - Builds MySchedulesFilter from provided fields.
      - Calls SharedScheduleRepository.getAllSharedSchedules(filter).
      - Returns 200 with list of schedules.

  - 
    - Auth:
      - Requires API key.
    - Behaviour:
      - Calls SharedScheduleRepository.endSharedSchedule(apiId) to:
        - Update schedule to indicate early termination (adjust dateTo and status).
      - On success: 200 with updated schedule.
      - On failure: 500 with error.

  - 
    - Auth:
      - Requires API key.
    - Request:
      - Similar dateFrom/dateTo structure as creation.
      - Fields: ,  (optional),  (optional), , .
    - Behaviour:
      - Builds NewScheduleConfig with  and new values.
      - Applies only provided digital/deleted flags.
      - Calls SharedScheduleRepository.updateSharedSchedule(config).
      - On success: 200 with updated schedule.
      - On failure: 500 with error.

- **Administration creation and updates (secondary carer)**

  - 
    - Auth:
      - Requires  and  for this apiId.
    - Request body:
      - For scheduled administration:
        -  = false.
        -  (ID of scheduled dose).
      - For as-needed administration:
        -  = true.
        -  (ID of medicine).
      - Both need:
        -  (ISO string), , , , .
    - Behaviour:
      - Normalizes Date/time zone.
      - Builds newAdministration object.
      - If  false:
        - Calls SharedScheduleRepository.createScheduledAdmininstration.
      - If  true:
        - Calls SharedScheduleRepository.createAsNeededAdmininstration.
      - On success: 200 with newly created admin record.
      - On failed create: 500 with  describing failure.

  - 
    - Auth:
      - Same as POST.
    - Request:
      - Similar to POST but with  field to append.
    - Behaviour:
      - Builds newAdministration object.
      - Calls SharedScheduleRepository.appendAdministraionNote.
      - On success: 200 with updated record.
      - On failure: 500 with error.

- **Confirmation of shared schedule (secondary carer)**

  - 
    - Auth:
      - Requires  and .
    - Request body:
      -  (boolean) – whether the carer can look after the child.
      -  (string) – optional reason, especially when declining.
    - Behaviour:
      - Builds ConfirmScheduleConfig with apiId, approved, reason.
      - Calls SharedScheduleRepository.confirmSharedSchedule.
      - On success: 200 with updated schedule (status changed to Approved or Declined).
      - On invalid input or errors: 500 with details.

---

## Cross-Cutting Concerns

- **Offline behaviour**
  - Flutter:
    - Offline-first by default; all primary-carer data is stored locally per profile.
    - Sign-in is local profile selection + optional passcode; no backend is required.
    - Shared schedule links still require backend access for secondary carers.
  - Web:
    - Local profile storage is persisted in IndexedDB/local storage (via shared_preferences for now).
    - Shared schedule view remains online-only.

- **Local storage and caching**
  - iOS:
    - Uses UserDefaults for:
      - , `password`, and `uid` for auto-login (legacy iOS behaviour).
      - `firstuse` flag to show/hide first-use popups and onboarding.
      - `notifications` list of schedule IDs with notifications applied.
      - Per-schedule lists of notification IDs and end dates.
    - Relies on backend fetches on view appearance (legacy iOS behaviour).
  - Web:
    - Uses Vuex store to retain:
      -  (shared schedule, carer, child, medicines, days, administrations).
      -  (implicitly part of state, though actual variable names differ).
      - , and simple UI flags like .

- **Notifications and background tasks**
  - iOS:
    - Requests notification permission at app startup (UNUserNotificationCenter).
    - Creates repeating local notifications per schedule time:
      - For daily and weekly frequencies, computed from start date and daily times.
      - Stores associated IDs and end dates to later clean up.
    - `checkForNotificationsToDelete` is run frequently (e.g., on Home appear) to:
      - Remove pending notifications past their end date.
      - Update IDs stored in UserDefaults.
    - `restoreNotifications`:
      - If notifications have never been created before, offers to recreate them from the existing schedule.
  - Web:
    - No push or local notification functionality is implemented.

- **Error handling and messaging**
  - Backend:
    - Consistently returns:
      - 401 for unauthorized (missing/invalid API key or auth token).
      - 403 for unauthorized/forbidden actions (invalid or revoked action tokens).
      - 500 with plain error messages for unexpected failures.
    - Some endpoints embed success booleans and error messages in JSON responses.
  - iOS:
    - Network errors (e.g. during schedule creation or export) are translated into user-facing error messages, often showing an alert with text like “Failed to connect to server” or the specific error string returned.
    - Authentication failures show an explicit “Incorrect email or password” message.
  - Web:
    - For auth and schedule fetch issues, user is redirected to /unavailable.
    - Some console logging but minimal user-facing error detail beyond unavailable messaging.

- **Security and privacy**
  - Primary carers:
    - Protected by local profiles with an optional passcode.
    - Encrypted backups require a user-defined passphrase and are safe to store in personal cloud storage.
    - Sensitive child details are stored locally; in shared contexts, only a subset is exposed.
  - Shared schedules:
    - Secondary carers access data via:
      - One-time action tokens ().
      - Backend verifies that the token is:
        - Not revoked ( flag).
        - Bound to a particular shared schedule.
        - Valid for the action type “view-shared-schedule”.
      - Backend issues a restricted  for continued access to that schedule only.
    - Authorization rules ensure:
      - Only the right combination of  and apiId can retrieve a given shared schedule or modify its data.
      - Action tokens are revocable (if a share is withdrawn or invalidated).
  - Shared data scope:
    - SharedSchedule view exposes only necessary child data:
      - Firstname, allergies, condition, notes.
      - Notably omits more sensitive identifiers (e.g., NHS number) from MinChild, indicating a deliberate privacy boundary.
    - Secondary carers can only see and act on the child and period they’ve been invited to.

- **Time zones and date handling**
  - Backend:
    - Uses `Europe/London` timezone for all schedule operations to align with UK-based use.
    - Uses 24-hour integer times to enforce start/end cutoff times within date ranges.
  - Web:
    - Adjusts for client timezone offset when parsing times from strings and when presenting times relative to user’s local timezone.
  - iOS:
    - Assumes UK locale (en_GB) and uses consistent `yyyy-MM-dd` and `hh:mma` string formats for schedule and administration keys.

---

## Gaps, Ambiguities, and Assumptions

- **Multiple children support**
  - Code supports multiple children (child indices “0”, “1”, …), but almost all operational logic explicitly references child index 0.
  - Assumption:
    - The product is effectively single-child per primary carer in practice, or multi-child support is partial and not actively used.
  - Implication for Flutter:
    - It is safest to design for at least one active child but treat proper multi-child support as a potential extension if requirements confirm it.

- **Logout and account management**
  - Explicit logout UI and behaviour aren’t fully visible.
  - Assumption:
    - There is a way to sign out (likely in Profile or Settings), clearing loggedIn flag and user defaults.
  - The Flutter spec should support a standard logout flow even if current app’s placement is not entirely clear.

- **Secondary carer interface for recording administrations (web)**
  - Backend provides full endpoints for creating and updating administrations, and Vuex store contains  mutation.
  - The views provided:
    - Schedule view (`o-schedule`) likely contains UI for adding administrations, but this implementation lies in components not included in the snippet.
    -  suggests a confirmation step for marking medicine as given but has stubbed code.
  - Assumptions:
    - The intended design is:
      - Secondary carers can record scheduled and as-needed administrations.
      - On confirmation, the front end calls POST or PUT /administration/:apiId and updates local state.
    - Flutter spec should treat “record medicine as given/skipped” as a key capability for secondary carers, even if some current web flows are only partially implemented.

- **Differences between iOS and web capabilities**
  - iOS (primary carer):
    - Fully manages medicines, schedules, carer network, and shared schedules.
    - Controls local notifications and exports generic schedule PDFs.
  - Web (secondary carer):
    - Only interacts with shared schedule data:
      - Accept/decline.
      - View key child info and schedule.
      - Record administrations within the shared period.
      - Download schedule.
    - Cannot edit child profile, medicines, or base schedule.
  - Backend:
    - Includes API for `exportSharedSchedulePdf`, which is not obviously used in iOS (iOS uses `/exportSchedulePdf` for primary PDF exports).
  - Assumption:
    - Flutter should maintain this separation:
      - Primary carers have full management powers.
      - Secondary carers have limited, invitation-scoped interaction.

- **Firestorm structure for shared schedules**
  - Logic deriving  from sharedSchedule doc path is somewhat opaque and fragile-looking.
  - There is an assumption embedded in path layout that a shared schedule is attached to a single child under a single primary.
  - For Flutter:
    - Treat this as a backend implementation detail:
      - All access is through documented HTTP endpoints.
      - Client should not inspect backend data paths directly.

- **Status states and lifecycle for shared schedules**
  - Observed statuses: “Pending”, “Approved”; “Declined” implied, as is an ended status after .
  - It’s not explicitly clear how statuses transition for all cases (e.g. if a schedule is “Ended” vs simply ).
  - Assumptions:
    - Typical lifecycle:
      - Creation: Pending.
      - Secondary carer approves: Approved.
      - Secondary carer declines: Declined with a reason.
      - Primary carer ends schedule: Ended/updated dateTo; may optionally have  set.
      - Primary carer deletes share:  and removed from primary UI list.
    - Flutter should support these states as separate conceptual statuses (Pending, Approved, Declined, Ended, Archived).

- **Offline mode behaviour**
  - Flutter is offline-first by design.
  - Assumptions:
    - Local data (child, medicines, schedules) is canonical for the primary carer profile on that device.
    - Users can export/import encrypted backups to move data across devices or store in personal cloud storage.
    - Shared schedule links remain online-only and may be unavailable without backend access.

- **Privacy and data sharing scope**
  - MinChild model for shared schedules explicitly limits child information to:
    - , , ,  and an ID.
  - Other personal identifiers (NHS number, full birthdate, etc.) are not passed into shared schedule responses.
  - Assumption:
    - This is intentional for privacy; Flutter should:
      - Mirror this by only exposing similar fields in secondary-carer views.
      - Keep sensitive identifiers within primary-carer-only views.

- **Carer network vs shared schedules**
  - Secondary Carer user records (care network) can exist even if no shared schedules are active.
  - Shared schedules reference carers primarily by email.
  - Ambiguity:
    - It’s not guaranteed every carer user in the backend store is visible in the care network list (filters based on `addedBy` and  apply).
  - Assumption:
    - Flutter “Care Network” should:
      - Show non-deleted carers added by the logged-in primary.
      - Treat shared schedules as separate entities referencing carers; removal of a carer should not retroactively invalidate historical shares (but may prevent new ones).

- ** text and placeholder content**
  - RecordView example text is placeholder “Lorem ipsum” style and the handler is commented out.
  - Assumption:
    - Final production copy and exact interaction patterns might differ.
    - Flutter spec should aim for:
      - A simple confirm-cancel step around recording administrations (particularly for sensitive changes), without tying itself to placeholder text.

- **Missing/partial views and controllers**
  - Tooling limitations prevented full loading of some iOS controllers and web views (e.g., MedicineViewController, ThanksView.vue, ThanksAcceptView.vue, Unavailable.vue).
  - Their behaviour has been inferred from naming, references, and call sites.
  - Assumption:
    - These screens primarily provide detail views or acknowledgements built from the data models and APIs already described.
    - The Flutter spec should capture their conceptual roles (detail views, thank-you/acknowledgement pages) rather than exact UI copy or layout.
