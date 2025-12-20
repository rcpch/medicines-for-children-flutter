import 'package:flutter/material.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GuideHeader(
            title: 'Medicines for Children',
            subtitle: 'A quick guide to managing medicines, schedules, and shared care.',
            accent: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const _GuideSection(
            title: 'Home & today\'s schedule',
            items: [
              'See what is due today and record administrations as given or skipped.',
              'Tap a schedule entry to view details and recent history.',
              'As-needed medicines appear separately so they are easy to record on demand.',
            ],
          ),
          const _GuideSection(
            title: 'Medicines',
            items: [
              'Add each medicine with dose, route, and frequency.',
              'Edit medicine details any time and add notes for extra guidance.',
              'Mark medicines as no longer used to keep the list tidy.',
            ],
          ),
          const _GuideSection(
            title: 'Schedules',
            items: [
              'Create a schedule for regular medicines and set the time(s) of day.',
              'Use as-needed schedules for medicines that are taken only when required.',
              'Review schedule history to confirm recent administrations.',
            ],
          ),
          const _GuideSection(
            title: 'Children & profiles',
            items: [
              'Add multiple children and switch between them in the child section.',
              'Store conditions, allergies, and notes for quick reference.',
              'Keep profile details up to date to help carers and clinicians.',
            ],
          ),
          const _GuideSection(
            title: 'Share centre',
            items: [
              'Create a share to give a secondary carer access for a set time period.',
              'Choose a digital share link or generate a schedule PDF for printing.',
              'Extend, end, or delete shares as care arrangements change.',
            ],
          ),
          const _GuideSection(
            title: 'Shared schedules (secondary carers)',
            items: [
              'Open the share link to view the schedule and important child information.',
              'Record administrations directly in the shared schedule view.',
              'Download or generate the PDF schedule when needed.',
            ],
          ),
          const _GuideSection(
            title: 'Exporting & backups',
            items: [
              'Export medicine summaries or schedules as PDFs from the share centre.',
              'Use backups to move data to another device or create a fresh profile.',
              'Importing a backup creates a new profile rather than replacing an existing one.',
            ],
          ),
          const _GuideSection(
            title: 'Offline use',
            items: [
              'The app keeps your latest data available when you are offline.',
              'Actions you take offline are queued and sent when you reconnect.',
            ],
          ),
          const _GuideSection(
            title: 'Settings & privacy',
            items: [
              'Review the privacy policy and data deletion information in settings.',
              'Control analytics consent from the settings screen.',
              'Use the dark theme if it is more comfortable for you.',
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: colorScheme.surfaceVariant,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tip: keep schedules and medicine details updated after clinic visits so shared carers always see the latest instructions.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideHeader extends StatelessWidget {
  const _GuideHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.15), accent.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
