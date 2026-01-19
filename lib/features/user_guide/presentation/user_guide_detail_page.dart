// User guide detail screen UI.
import 'package:flutter/material.dart';
import 'package:medicines_for_children_flutter/features/user_guide/domain/user_guide_content.dart';

class UserGuideDetailPage extends StatelessWidget {
  const UserGuideDetailPage({super.key, required this.sectionId});

  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final section = userGuideSections.cast<UserGuideSection?>().firstWhere(
          (item) => item?.id == sectionId,
          orElse: () => null,
        );

    if (section == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User guide')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('This guide section is not available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Step-by-step guidance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(section.summary),
          const SizedBox(height: 16),
          ...section.steps.asMap().entries.map(
                (entry) => _StepCard(
                  stepNumber: entry.key + 1,
                  text: entry.value,
                ),
              ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNumber,
    required this.text,
  });

  final int stepNumber;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
