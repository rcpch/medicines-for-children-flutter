// Login screen UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/presentation/backup_actions.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/core/security/biometric_auth_service.dart';
import 'package:medicines_for_children_flutter/core/settings/profile_settings_controller.dart';

// Login screen that lets users select or import profiles.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  // Creates the login page state.
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _passcodeController;
  bool _biometricsAvailable = false;

  // Sets up controllers and loads biometric availability.
  @override
  void initState() {
    super.initState();
    _passcodeController = TextEditingController();
    _checkBiometrics();
    Future<void>.microtask(() {
      ref.read(authControllerProvider.notifier).refreshProfiles();
    });
  }

  // Disposes text controllers.
  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  // Navigates to the signup page.
  void _goToSignup() {
    context.goNamed(AppRoute.signup.name);
  }

  // Shows a snackbar message.
  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  // Checks whether biometric auth is supported on this device.
  Future<void> _checkBiometrics() async {
    final available = await ref
        .read(biometricAuthServiceProvider)
        .isSupported();
    if (!mounted) {
      return;
    }
    setState(() {
      _biometricsAvailable = available;
    });
  }

  // Prompts to unlock the selected profile if it has a passcode.
  Future<void> _selectProfile(LocalProfile profile) async {
    await ref.read(authControllerProvider.notifier).selectProfile(profile.id);
    if (!profile.hasPasscode) {
      return;
    }
    _passcodeController.clear();
    final profileSettings = ref.read(
      profileSettingsControllerProvider(profile.id),
    );
    final biometricsEnabled = profileSettings.biometricsEnabled;
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        final canUseBiometrics = _biometricsAvailable && biometricsEnabled;
        return AlertDialog(
          title: Text('Unlock ${profile.name}'),
          content: TextField(
            controller: _passcodeController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Passcode',
              hintText: 'Enter passcode to unlock',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) async {
              await ref
                  .read(authControllerProvider.notifier)
                  .unlockWithPasscode(_passcodeController.text.trim());
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (canUseBiometrics)
              OutlinedButton.icon(
                onPressed: () async {
                  final success = await ref
                      .read(authControllerProvider.notifier)
                      .unlockWithBiometrics();
                  if (!context.mounted) {
                    return;
                  }
                  if (success) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use biometrics'),
              ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(authControllerProvider.notifier)
                    .unlockWithPasscode(_passcodeController.text.trim());
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }

  // Builds the login screen UI.
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null &&
          message.isNotEmpty &&
          message != previous?.errorMessage) {
        _showMessage(message);
      }
    });

    final hasProfiles = authState.profiles.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose profile')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.family_restroom_outlined, size: 72),
                  const SizedBox(height: 16),
                  Text(
                    hasProfiles
                        ? 'Welcome back'
                        : 'Welcome to Medicines for Children',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasProfiles
                        ? 'Select a local profile to continue. Data stays on this device unless you export it.'
                        : 'Create a profile or import a backup to get started.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (authState.profiles.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('No profiles yet.'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _goToSignup,
                              child: const Text('Create a profile'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => BackupActions.importBackup(
                                      context,
                                      ref,
                                    ),
                              icon: const Icon(Icons.file_upload_outlined),
                              label: const Text('Import a backup'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...authState.profiles.map(
                      (profile) => Card(
                        child: ListTile(
                          title: Text(profile.name),
                          subtitle: profile.displayName.isEmpty
                              ? const Text('Profile setup pending')
                              : Text(profile.displayName),
                          trailing: profile.hasPasscode
                              ? const Icon(Icons.lock_outline)
                              : const Icon(Icons.chevron_right),
                          onTap: authState.isLoading
                              ? null
                              : () => _selectProfile(profile),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: authState.isLoading ? null : _goToSignup,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create another profile'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => BackupActions.importBackup(context, ref),
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Import a backup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
