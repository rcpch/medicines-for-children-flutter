// Privacy policy screen UI.
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Medicines for Children stores your profile, child information, '
              'medicines, schedules, and administrations locally on your device. '
              'We do not require a cloud account to use the app.',
            ),
            const SizedBox(height: 16),
            Text('Data we store', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              '• Profiles, child details, medicines, schedules, and administration notes.\n'
              '• Optional analytics preferences and consent flags.\n'
              '• If you create a shared schedule, the app sends only the data '
              'needed to generate the shared view.',
            ),
            const SizedBox(height: 16),
            Text('Analytics', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Analytics are optional. You can enable or disable anonymous usage '
              'tracking at any time from Settings.',
            ),
            const SizedBox(height: 16),
            Text('Backups', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'You can export an encrypted backup. The encryption passphrase is '
              'never stored by the app, so keep it somewhere safe.',
            ),
            const SizedBox(height: 16),
            Text('Contact', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'If you have questions about privacy, contact support@example.com.',
            ),
          ],
        ),
      ),
    );
  }
}
