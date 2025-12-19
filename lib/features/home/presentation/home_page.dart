import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/data/backup/backup_service.dart';
import 'package:medicines_for_children_flutter/core/platform/backup_file_io.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/selected_date_provider.dart';
import 'package:medicines_for_children_flutter/features/home/domain/daily_schedule_builder.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(primaryCarerControllerProvider);
    final controller = ref.read(primaryCarerControllerProvider.notifier);
    final selectedDate = ref.watch(selectedDateProvider);
    final telemetry = ref.read(telemetryServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines Home'),
        actions: [
          IconButton(
            tooltip: 'Refresh family data',
            onPressed: state.isLoading ? null : () => controller.refresh(),
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<_HomeAction>(
            onSelected: (action) => _handleAction(context, ref, action),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _HomeAction.exportBackup,
                child: Text('Export backup'),
              ),
              PopupMenuItem(
                value: _HomeAction.importBackup,
                child: Text('Import backup'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _HomeAction.signOut,
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: _HomeBody(
          state: state,
          onRefresh: controller.refresh,
          theme: theme,
          dailyScheduleBuilder: ref.watch(dailyScheduleBuilderProvider),
          selectedDate: selectedDate,
          onSelectDate: (date) {
            ref.read(selectedDateProvider.notifier).state = date;
            telemetry.trackEvent('home_date_selected', properties: {
              'date': DateFormat('yyyy-MM-dd').format(date),
            });
          },
          onAddSchedule: () {
            context.goNamed(AppRoute.addSchedule.name);
          },
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, _HomeAction action) async {
    switch (action) {
      case _HomeAction.exportBackup:
        await _exportBackup(context, ref);
        return;
      case _HomeAction.importBackup:
        await _importBackup(context, ref);
        return;
      case _HomeAction.signOut:
        await ref.read(authControllerProvider.notifier).signOut();
        return;
    }
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
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
        const SnackBar(content: Text('Backup exported. Store it somewhere safe.')),
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

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final backupFileIO = ref.read(backupFileIOProvider);
    Uint8List? bytes;
    try {
      bytes = await backupFileIO.pickFileBytes(label: 'Backup', extensions: const ['mfc']);
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

    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.restoreBackup(
        bytes: bytes,
        passphrase: details.passphrase,
        newProfileName: details.profileName,
        newPasscode: details.passcode,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup imported.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to import backup: $error')),
      );
    }
  }

  Future<String?> _promptPassphrase({
    required BuildContext context,
    required String title,
    required String confirmLabel,
  }) async {
    final passphraseController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Passphrase'),
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: confirmLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your passphrase';
                    }
                    if (value != passphraseController.text) {
                      return 'Passphrases do not match';
                    }
                    return null;
                  },
                ),
              ],
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
                  Navigator.of(context).pop(passphraseController.text.trim());
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    passphraseController.dispose();
    confirmController.dispose();
    return result;
  }

  Future<_ImportDetails?> _promptImportDetails(BuildContext context) async {
    final passphraseController = TextEditingController();
    final profileNameController = TextEditingController();
    final passcodeController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_ImportDetails>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import backup'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passphraseController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Backup passphrase'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the backup passphrase';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: profileNameController,
                  decoration: const InputDecoration(labelText: 'Profile name (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passcodeController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Passcode (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm passcode'),
                  validator: (value) {
                    if (passcodeController.text.trim().isEmpty) {
                      return null;
                    }
                    if (value == null || value.isEmpty) {
                      return 'Confirm your passcode';
                    }
                    if (value != passcodeController.text) {
                      return 'Passcodes do not match';
                    }
                    return null;
                  },
                ),
              ],
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
                      passphrase: passphraseController.text.trim(),
                      profileName: profileNameController.text.trim().isEmpty
                          ? null
                          : profileNameController.text.trim(),
                      passcode: passcodeController.text.trim().isEmpty
                          ? null
                          : passcodeController.text.trim(),
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

    passphraseController.dispose();
    profileNameController.dispose();
    passcodeController.dispose();
    confirmController.dispose();
    return result;
  }
}

enum _HomeAction { exportBackup, importBackup, signOut }

class _ImportDetails {
  const _ImportDetails({
    required this.passphrase,
    this.profileName,
    this.passcode,
  });

  final String passphrase;
  final String? profileName;
  final String? passcode;
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.onRefresh,
    required this.theme,
    required this.dailyScheduleBuilder,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onAddSchedule,
  });

  final PrimaryCarerState state;
  final Future<void> Function() onRefresh;
  final ThemeData theme;
  final DailyScheduleBuilder dailyScheduleBuilder;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.carer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.carer == null) {
      return _EmptyState(
        message: state.errorMessage ?? 'Sign in to view your child\'s medicines and schedule.',
        onRefresh: onRefresh,
      );
    }

    final List<Child> children = state.carer!.children;
    final Child? primaryChild = children.isEmpty ? null : children.first;
    final scheduleEntries = primaryChild == null
        ? <DailyScheduleEntry>[]
        : dailyScheduleBuilder.buildScheduledEntries(primaryChild, selectedDate);
    final asNeededEntries = primaryChild == null
        ? <AsNeededAdministrationEntry>[]
        : dailyScheduleBuilder.buildAsNeededEntries(primaryChild, selectedDate);
    final timeOfDaySections = dailyScheduleBuilder.buildTimeOfDaySections(scheduleEntries);

    return RefreshIndicator(
      onRefresh: () => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (state.isStale)
            Card(
              color: theme.colorScheme.surfaceVariant,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Showing saved data while we refresh your latest schedule...'),
              ),
            ),
          if (state.errorMessage != null)
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          _CarerSummary(carer: state.carer!),
          const SizedBox(height: 16),
          if (primaryChild != null) ...[
            _ChildCard(child: primaryChild),
            const SizedBox(height: 16),
            _CalendarStrip(
              selectedDate: selectedDate,
              onSelectDate: onSelectDate,
            ),
            const SizedBox(height: 16),
            _ScheduleSection(
              sections: timeOfDaySections,
              isLoading: state.isLoading,
              onAddSchedule: onAddSchedule,
            ),
            const SizedBox(height: 16),
            _AsNeededSection(
              entries: asNeededEntries,
              isLoading: state.isLoading,
            ),
          ] else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('No children found'),
                    SizedBox(height: 8),
                    Text('Add your first child to start tracking medicines and schedules.'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarerSummary extends StatelessWidget {
  const _CarerSummary({required this.carer});

  final PrimaryCarer carer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${carer.firstName}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${carer.firstName} ${carer.lastName} · ${carer.relationshipToChild}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              carer.children.isEmpty
                  ? 'You have no saved children yet.'
                  : 'You are currently managing ${carer.children.length} child${carer.children.length == 1 ? '' : 'ren'}.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${child.firstName} ${child.lastName}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Condition: ${child.condition}'),
            if (child.allergies.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Allergies: ${child.allergies.join(', ')}'),
            ],
            const SizedBox(height: 12),
            Text('Medicines: ${child.medicines.length} · Schedules: ${child.schedules.length}'),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.sections,
    required this.isLoading,
    required this.onAddSchedule,
  });

  final List<TimeOfDaySection> sections;
  final bool isLoading;
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) {
    if (isLoading && sections.every((section) => section.entries.isEmpty)) {
      return const _LoadingSection(title: 'Today\'s schedule');
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Today\'s schedule',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddSchedule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sections.every((section) => section.entries.isEmpty))
              const Text('No scheduled medicines for today.'),
            for (final section in sections) ...[
              if (section.entries.isNotEmpty) ...[
                Text(
                  section.label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                for (final entry in section.entries) _ScheduleTile(entry: entry),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.entry});

  final DailyScheduleEntry entry;

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (entry.status) {
      case AdministrationStatus.given:
        return scheme.tertiary;
      case AdministrationStatus.skipped:
        return scheme.error;
      case AdministrationStatus.scheduled:
        return scheme.primary;
    }
  }

  String _statusLabel() {
    switch (entry.status) {
      case AdministrationStatus.given:
        return 'Given';
      case AdministrationStatus.skipped:
        return 'Skipped';
      case AdministrationStatus.scheduled:
        return entry.isUpcoming ? 'Upcoming' : 'Due';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.timeLabel, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                entry.medicine.name,
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '${entry.medicine.dose} ${entry.medicine.doseUnit} · ${entry.medicine.route}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(context).withOpacity(0.12),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              _statusLabel(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _statusColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AsNeededSection extends StatelessWidget {
  const _AsNeededSection({
    required this.entries,
    required this.isLoading,
  });

  final List<AsNeededAdministrationEntry> entries;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && entries.isEmpty) {
      return const _LoadingSection(title: 'As-needed activity');
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'As-needed activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('No as-needed medicines recorded today.'),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.jm().format(entry.administration.dateTime),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(entry.medicine.name),
                        if (entry.administration.notes != null &&
                            entry.administration.notes!.isNotEmpty)
                          Text(
                            entry.administration.notes!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      entry.administration.administeredBy ?? 'Carer',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({
    required this.selectedDate,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = List.generate(14, (index) {
      final base = DateTime.now();
      final date = DateTime(base.year, base.month, base.day).add(Duration(days: index - 3));
      return date;
    });

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = _isSameDay(date, selectedDate);
          return GestureDetector(
            onTap: () => onSelectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            for (var index = 0; index < 3; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
