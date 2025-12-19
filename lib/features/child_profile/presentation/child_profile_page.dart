import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/platform/image_provider.dart';

class ChildProfilePage extends ConsumerWidget {
  const ChildProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Child profile')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available yet.'),
        ),
      );
    }

    final imageProvider = child.photoUrl == null || child.photoUrl!.trim().isEmpty
        ? null
        : createImageProvider(child.photoUrl!);

    return Scaffold(
      appBar: AppBar(title: const Text('Child profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      backgroundImage: imageProvider,
                      child: imageProvider == null ? const Icon(Icons.child_care_outlined) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${child.firstName} ${child.lastName}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAge(child.dateOfBirth),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            DateFormat.yMMMMd().format(child.dateOfBirth),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Condition',
              child: Text(
                child.condition.isNotEmpty ? child.condition : 'No condition recorded.',
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Allergies',
              child: child.allergies.isEmpty
                  ? const Text('No allergies recorded.')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: child.allergies
                          .map((allergy) => Chip(label: Text(allergy)))
                          .toList(),
                    ),
            ),
            if (child.notes != null && child.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Notes for carers',
                child: Text(child.notes!),
              ),
            ],
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Medicines',
              child: Text('${child.medicines.length} active medicines'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    final hasHadBirthday = now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!hasHadBirthday) {
      years -= 1;
    }
    if (years <= 0) {
      final months = (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
      return '${months < 1 ? 1 : months} months old';
    }
    return '$years years old';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
