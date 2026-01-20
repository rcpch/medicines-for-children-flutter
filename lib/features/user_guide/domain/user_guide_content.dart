// User guide content model and copy.
class UserGuideSection {
  const UserGuideSection({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> steps;
}

const userGuideSections = <UserGuideSection>[
  UserGuideSection(
    id: 'home',
    title: 'Home & today\'s schedule',
    summary: 'See today\'s plan and record doses as given or skipped.',
    steps: [
      'Tap Home in the bottom navigation to open today\'s schedule.',
      'Tap a schedule entry to open the medicine details and recent history.',
      'Tap Given to record a dose that was taken.',
      'Tap Skip to record a missed dose and confirm it in the dialog.',
      'Tap Back to return to the full schedule list.',
    ],
  ),
  UserGuideSection(
    id: 'medicines',
    title: 'Medicines',
    summary: 'Add, edit, and organize medicines for each child.',
    steps: [
      'Tap Medicines in the bottom navigation to open the medicines list.',
      'Tap Add medicine to start a new medicine entry.',
      'Tap each field to enter name, dose, route, and frequency details.',
      'Tap Add medicine at the bottom to save the medicine.',
      'Tap Scan QR to import a medicine from a Medicines for Children QR code.',
      'Tap Save on the prefilled medicine form after reviewing the details.',
      'Tap a medicine card to review details or tap Edit to update it.',
    ],
  ),
  UserGuideSection(
    id: 'schedules',
    title: 'Schedules',
    summary: 'Set up regular or as-needed schedules and track history.',
    steps: [
      'Tap Home, then tap Schedules to manage medicine schedules.',
      'Tap Add schedule to create a new schedule.',
      'Tap the time fields to add each daily time you need reminders for.',
      'Tap Save schedule to store the timetable.',
      'Tap a schedule card to review its history or tap Edit to change it.',
    ],
  ),
  UserGuideSection(
    id: 'children',
    title: 'Children & profiles',
    summary: 'Manage multiple children and switch between profiles.',
    steps: [
      'Tap Child in the bottom navigation to open the child profile.',
      'Tap Add child to create another child profile.',
      'Tap each field to enter name, date of birth, condition, and allergies.',
      'Tap Save to store the new child profile.',
      'Tap the child selector to switch between children.',
    ],
  ),
  UserGuideSection(
    id: 'share-centre',
    title: 'Sharing',
    summary: 'Create a share link or PDF for another carer.',
    steps: [
      'Tap Child, then tap Sharing to view existing shares.',
      'Tap New share to start a new shared schedule.',
      'Tap the date range fields to set the share period.',
      'Tap Digital share or PDF share to choose the format.',
      'Tap Create share to send the invitation or generate the file.',
    ],
  ),
  UserGuideSection(
    id: 'shared-schedule',
    title: 'Shared schedules (secondary carers)',
    summary: 'Follow a shared link and record administrations.',
    steps: [
      'Tap the shared link you received to open the shared schedule.',
      'Tap the Important info tab to review allergies and notes.',
      'Tap the Schedule tab to return to the daily plan.',
      'Tap Given or Skip on a scheduled item to record the action.',
      'Tap Download schedule to save or share the PDF.',
    ],
  ),
  UserGuideSection(
    id: 'export-backup',
    title: 'Exporting & backups',
    summary: 'Export PDFs or back up your data for safe keeping.',
    steps: [
      'Tap Child, then tap Sharing to access export tools.',
      'Tap Export medicines to generate a medicines summary PDF.',
      'Tap Export schedule to choose a date range for a schedule PDF.',
      'Tap Settings, then tap Export data to save a backup file.',
      'Tap Settings, then tap Import data to restore a backup as a new profile.',
    ],
  ),
  UserGuideSection(
    id: 'offline',
    title: 'Offline use',
    summary: 'Continue working when you do not have a connection.',
    steps: [
      'Tap Home to view the most recently synced schedule.',
      'Tap Given or Skip to record actions while offline.',
      'Tap Sharing to review shared schedules while offline.',
      'Tap Home to continue recording actions until you reconnect.',
    ],
  ),
  UserGuideSection(
    id: 'settings',
    title: 'Settings & privacy',
    summary: 'Manage privacy, theme, and support options.',
    steps: [
      'Tap Child, then tap Settings to open the settings screen.',
      'Tap Theme to choose system, light, or dark mode.',
      'Drag the Text size slider to adjust the text scale.',
      'Tap Enable reminders to turn notifications on or off.',
      'Tap Biometric unlock to allow Face ID/Touch ID where available.',
      'Tap Change passcode to update the profile passcode.',
      'Tap Privacy policy to read the privacy information.',
      'Tap Data deletion to read data removal guidance.',
      'Tap Back to return to the main app.',
    ],
  ),
  UserGuideSection(
    id: 'permissions',
    title: 'Camera & photo permissions',
    summary: 'Allow access so you can scan QR codes or add packaging photos.',
    steps: [
      'Tap Medicines in the bottom navigation to open the medicines list.',
      'Tap Add medicine to start a new medicine entry.',
      'Tap Take photo to trigger the camera permission prompt.',
      'Tap Allow to grant camera access.',
      'Tap Choose photo to trigger the photo library prompt.',
      'Tap Allow to grant photo library access.',
      'If your device has no camera, read the message and use a camera-enabled device.',
    ],
  ),
];
