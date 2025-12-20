import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/data_deletion_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/privacy_policy_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile.adaptive(
                value: settings.telemetryEnabled,
                title: const Text('Share anonymous analytics'),
                subtitle: const Text('Help improve the app by sharing usage data.'),
                onChanged: (value) => controller.setTelemetryEnabled(value),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Privacy policy'),
                subtitle: const Text('Read how we handle your data.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Request data deletion'),
                subtitle: const Text('Learn how to request data deletion.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DataDeletionPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
