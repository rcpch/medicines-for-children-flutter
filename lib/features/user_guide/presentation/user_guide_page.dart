import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/features/user_guide/domain/user_guide_content.dart';

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
          ...userGuideSections.map(
            (section) => _GuideSection(
              key: ValueKey('guide-section-${section.id}'),
              title: section.title,
              summary: section.summary,
              onTap: () => context.pushNamed(
                AppRoute.userGuideDetail.name,
                pathParameters: {'sectionId': section.id},
              ),
            ),
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
    super.key,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(summary, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
