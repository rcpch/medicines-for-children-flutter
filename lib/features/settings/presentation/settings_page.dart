// Settings screen UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/security/biometric_auth_service.dart';
import 'package:medicines_for_children_flutter/core/settings/app_settings.dart';
import 'package:medicines_for_children_flutter/core/settings/profile_settings_controller.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/data_deletion_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/privacy_policy_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    LocalProfile? currentProfile;
    if (authState.user != null) {
      for (final profile in authState.profiles) {
        if (profile.id == authState.user!.uid) {
          currentProfile = profile;
          break;
        }
      }
    }
    final profileSettings = currentProfile == null
        ? null
        : ref.watch(profileSettingsControllerProvider(currentProfile.id));
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Profile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: _BiometricsTile(
                profileName: currentProfile?.name,
                hasPasscode: currentProfile?.hasPasscode ?? false,
                biometricsEnabled: profileSettings?.biometricsEnabled ?? false,
                onChanged: profileSettings == null
                    ? null
                    : (value) async {
                        final controller = ref.read(
                          profileSettingsControllerProvider(currentProfile!.id).notifier,
                        );
                        if (!value) {
                          await controller.setBiometricsEnabled(false);
                          return;
                        }
                        final ok = await _confirmPasscode(
                          context,
                          authController,
                          title: 'Enable biometric unlock',
                          actionLabel: 'Enable',
                        );
                        if (!ok) {
                          return;
                        }
                        await controller.setBiometricsEnabled(true);
                      },
              ),
            ),
            if (currentProfile != null)
              Builder(
                builder: (context) {
                  final profile = currentProfile!;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          profile.hasPasscode ? 'Change passcode' : 'Set passcode',
                        ),
                        subtitle: Text(
                          profile.hasPasscode
                              ? 'Update the passcode for this profile.'
                              : 'Add a passcode to protect this profile.',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showPasscodeDialog(
                          context,
                          authController,
                          hasPasscode: profile.hasPasscode,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Choose light, dark, or system default.'),
                trailing: DropdownButton<AppThemeMode>(
                  value: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setThemeMode(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: AppThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: AppThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: AppThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Text size'),
                    const SizedBox(height: 6),
                    Text(
                      _textScaleLabel(settings.textScale),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: settings.textScale,
                      min: 0.9,
                      max: 1.3,
                      divisions: 4,
                      label: _textScaleLabel(settings.textScale),
                      onChanged: (value) => controller.setTextScale(value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile.adaptive(
                value: settings.notificationsEnabled,
                title: const Text('Enable reminders'),
                subtitle: Text(
                  settings.notificationsEnabled
                      ? 'Allow schedule reminders on this device.'
                      : 'Reminders are off. Existing notifications are cleared.',
                ),
                onChanged: (value) => controller.setNotificationsEnabled(value),
              ),
            ),
            const SizedBox(height: 16),
            Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
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

  String _textScaleLabel(double scale) {
    if (scale <= 0.95) {
      return 'Small';
    }
    if (scale <= 1.05) {
      return 'Default';
    }
    if (scale <= 1.2) {
      return 'Large';
    }
    return 'Extra large';
  }

  Future<bool> _confirmPasscode(
    BuildContext context,
    AuthController controller, {
    required String title,
    required String actionLabel,
  }) async {
    final passcodeController = TextEditingController();
    bool confirmed = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: passcodeController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Passcode',
              hintText: 'Enter passcode to confirm',
            ),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok = await controller.verifyPasscode(
                  passcodeController.text.trim(),
                );
                if (!context.mounted) {
                  return;
                }
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect passcode.')),
                  );
                  return;
                }
                confirmed = true;
                Navigator.of(context).pop();
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
    passcodeController.dispose();
    return confirmed;
  }

  Future<void> _showPasscodeDialog(
    BuildContext context,
    AuthController controller, {
    required bool hasPasscode,
  }) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(hasPasscode ? 'Change passcode' : 'Set passcode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasPasscode)
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current passcode',
                  ),
                ),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New passcode',
                ),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm new passcode',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final current = currentController.text.trim();
                final next = newController.text.trim();
                final confirm = confirmController.text.trim();
                if (next.isEmpty || confirm.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter and confirm the new passcode.')),
                  );
                  return;
                }
                if (next != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passcodes do not match.')),
                  );
                  return;
                }
                final ok = await controller.changePasscode(
                  currentPasscode: hasPasscode ? current : null,
                  newPasscode: next,
                );
                if (!context.mounted) {
                  return;
                }
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to update passcode.')),
                  );
                  return;
                }
                Navigator.of(context).pop();
              },
              child: Text(hasPasscode ? 'Update' : 'Set'),
            ),
          ],
        );
      },
    );
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }
}

class _BiometricsTile extends ConsumerWidget {
  const _BiometricsTile({
    required this.profileName,
    required this.hasPasscode,
    required this.biometricsEnabled,
    required this.onChanged,
  });

  final String? profileName;
  final bool hasPasscode;
  final bool biometricsEnabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.read(biometricAuthServiceProvider).isSupported(),
      builder: (context, snapshot) {
        final supported = snapshot.data ?? false;
        final enabled = supported && hasPasscode;
        final subtitle = !supported
            ? 'Biometrics are not available on this device.'
            : !hasPasscode
                ? 'Add a passcode to enable biometric unlock.'
                : profileName == null
                    ? 'Select a profile to configure biometrics.'
                    : 'Use biometrics to unlock ${profileName!}.';
        return SwitchListTile.adaptive(
          value: enabled && biometricsEnabled,
          title: const Text('Biometric unlock'),
          subtitle: Text(subtitle),
          onChanged: enabled ? onChanged : null,
        );
      },
    );
  }
}
