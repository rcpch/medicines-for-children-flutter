// Data deletion and reset screen UI.
import 'package:flutter/material.dart';

class DataDeletionPage extends StatelessWidget {
  const DataDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Request data deletion')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('How to request deletion', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Medicines for Children stores your data locally on your device. '
              'You can remove all local data by deleting the app or clearing '
              'storage from your device settings.',
            ),
            const SizedBox(height: 16),
            Text('Shared schedule data', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'If you have created shared schedules, you can request deletion '
              'of shared schedule records by contacting support.',
            ),
            const SizedBox(height: 16),
            Text('Contact', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Email support@example.com with the subject “Data deletion request”. '
              'Include the primary carer email used for sharing if applicable.',
            ),
          ],
        ),
      ),
    );
  }
}
