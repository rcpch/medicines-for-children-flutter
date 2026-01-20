// Shared backup import/export flows.
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/data/backup/backup_service.dart';
import 'package:medicines_for_children_flutter/core/platform/backup_file_io.dart';

/// Presents backup import/export flows for the UI.
class BackupActions {
  /// Exports an encrypted backup and saves it via platform file IO.
  static Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
    final passphrase = await _promptPassphrase(
      context: context,
      title: 'Create a backup passphrase',
      confirmLabel: 'Confirm passphrase',
    );
    if (passphrase == null) {
      return;
    }
    try {
      final backupService = ref.read(backupServiceProvider);
      final backupFileIO = ref.read(backupFileIOProvider);
      final bytes = await backupService.createBackup(passphrase: passphrase);
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      await backupFileIO.saveBytes(
        bytes: bytes,
        filename: 'mfc-backup-$timestamp.mfc',
        mimeType: 'application/octet-stream',
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup exported. Store it somewhere safe.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to export backup: $error')),
      );
    }
  }

  /// Imports an encrypted backup and restores it as a new profile.
  static Future<void> importBackup(BuildContext context, WidgetRef ref) async {
    final backupFileIO = ref.read(backupFileIOProvider);
    Uint8List? bytes;
    try {
      bytes = await backupFileIO.pickFileBytes(
        label: 'Backup',
        extensions: const ['mfc'],
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open backup: $error')),
      );
      return;
    }

    if (bytes == null) {
      return;
    }

    final details = await _promptImportDetails(context);
    if (details == null) {
      return;
    }

    final backupService = ref.read(backupServiceProvider);
    while (true) {
      final passphrase = await _promptImportPassphrase(context);
      if (!context.mounted) {
        return;
      }
      if (passphrase == null) {
        return;
      }
      try {
        await backupService.restoreBackup(
          bytes: bytes,
          passphrase: passphrase,
          newProfileName: details.profileName,
          newPasscode: details.passcode,
        );
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup imported as a new profile.')),
        );
        return;
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        if (_isInvalidPassphrase(error)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect passphrase. Try again.')),
          );
          continue;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to import backup: $error')),
        );
        return;
      }
    }
  }

  /// Prompts for a new backup passphrase with confirmation.
  static Future<String?> _promptPassphrase({
    required BuildContext context,
    required String title,
    required String confirmLabel,
  }) async {
    final formKey = GlobalKey<FormState>();
    var passphrase = '';

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Passphrase'),
                    onChanged: (value) => passphrase = value,
                    validator: (value) {
                      if (value == null || value.trim().length < 8) {
                        return 'Use at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: confirmLabel),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm your passphrase';
                      }
                      if (value != passphrase) {
                        return 'Passphrases do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(passphrase.trim());
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return result;
  }

  /// Prompts for the backup passphrase to unlock a restore.
  static Future<String?> _promptImportPassphrase(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    var passphrase = '';

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter backup passphrase'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Passphrase'),
                onChanged: (value) => passphrase = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the backup passphrase';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(passphrase.trim());
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return result;
  }

  /// Prompts for optional profile name and passcode during import.
  static Future<_ImportDetails?> _promptImportDetails(
    BuildContext context,
  ) async {
    final formKey = GlobalKey<FormState>();
    var profileName = '';
    var passcode = '';

    final result = await showDialog<_ImportDetails>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import backup'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Import creates a new profile on this device.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Import as (optional)',
                      helperText:
                          'Leave blank to use the original profile name.',
                    ),
                    onChanged: (value) => profileName = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New passcode (optional)',
                    ),
                    onChanged: (value) => passcode = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new passcode',
                    ),
                    validator: (value) {
                      if (passcode.trim().isEmpty) {
                        return null;
                      }
                      if (value == null || value.isEmpty) {
                        return 'Confirm your passcode';
                      }
                      if (value != passcode) {
                        return 'Passcodes do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(
                    _ImportDetails(
                      profileName: profileName.trim().isEmpty
                          ? null
                          : profileName.trim(),
                      passcode: passcode.trim().isEmpty
                          ? null
                          : passcode.trim(),
                    ),
                  );
                }
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );

    return result;
  }
}

/// Holds optional fields collected during backup import.
class _ImportDetails {
  const _ImportDetails({this.profileName, this.passcode});

  final String? profileName;
  final String? passcode;
}

/// Returns true when the error indicates a bad backup passphrase.
bool _isInvalidPassphrase(Object error) {
  return error is SecretBoxAuthenticationError;
}
