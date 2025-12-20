import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _privacyPolicyUrl = 'https://example.com/privacy';
  static const _dataDeletionEmail = 'support@example.com';

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
                subtitle: const Text('Copy the link to view our privacy policy.'),
                trailing: const Icon(Icons.copy_outlined),
                onTap: () => _copyToClipboard(context, _privacyPolicyUrl, 'Privacy policy link copied.'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Request data deletion'),
                subtitle: const Text('Copy the support email to request data deletion.'),
                trailing: const Icon(Icons.copy_outlined),
                onTap: () => _copyToClipboard(context, _dataDeletionEmail, 'Support email copied.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
