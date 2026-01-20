// Main menu for top-level app actions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/presentation/backup_actions.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';

/// Actions available from the main overflow menu.
enum MainMenuAction { settings, shareCentre, exportBackup, importBackup, signOut }

/// Overflow menu widget for top-level navigation and actions.
class MainMenu extends ConsumerWidget {
  const MainMenu({super.key});

  /// Builds the popup menu for primary actions.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<MainMenuAction>(
      onSelected: (action) => _handleAction(context, ref, action),
      itemBuilder: (context) => const [
        PopupMenuItem(value: MainMenuAction.settings, child: Text('Settings')),
        PopupMenuItem(
          value: MainMenuAction.shareCentre,
          child: Text('Share centre'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: MainMenuAction.exportBackup,
          child: Text('Export backup'),
        ),
        PopupMenuItem(
          value: MainMenuAction.importBackup,
          child: Text('Import backup'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(value: MainMenuAction.signOut, child: Text('Sign out')),
      ],
    );
  }

  /// Handles menu action selection and navigation/side effects.
  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    MainMenuAction action,
  ) async {
    switch (action) {
      case MainMenuAction.settings:
        context.goNamed(AppRoute.settings.name);
        return;
      case MainMenuAction.shareCentre:
        context.goNamed(AppRoute.shareCentre.name);
        return;
      case MainMenuAction.exportBackup:
        await BackupActions.exportBackup(context, ref);
        return;
      case MainMenuAction.importBackup:
        await BackupActions.importBackup(context, ref);
        return;
      case MainMenuAction.signOut:
        await ref.read(authControllerProvider.notifier).signOut();
        return;
    }
  }
}
