// Schedules list screen UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/presentation/child_switcher_action.dart';
import 'package:medicines_for_children_flutter/features/schedules/application/schedule_editor_controller.dart';

// Lists schedules for the active child and offers edit/delete actions.
class SchedulesPage extends ConsumerWidget {
  const SchedulesPage({super.key});

  @override
  // Builds the schedule list or empty states.
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);

    if (child == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Schedules'),
          actions: const [ChildSwitcherAction()],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available.'),
        ),
      );
    }

    if (child.schedules.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Schedules'),
          actions: const [ChildSwitcherAction()],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No schedules yet. Add one to get started.'),
        ),
      );
    }

    final medicinesById = {for (final med in child.medicines) med.id: med};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: const [ChildSwitcherAction()],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: child.schedules.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final schedule = child.schedules[index];
          final medicine = medicinesById[schedule.medicineId];
          final subtitle = [
            if (medicine != null) medicine.name,
            'From ${DateFormat.yMMMd().format(schedule.startDate)} to ${DateFormat.yMMMd().format(schedule.endDate)}',
            schedule.times.join(', '),
          ].join('\n');

          return Card(
            child: ListTile(
              title: Text(medicine?.name ?? 'Medicine schedule'),
              subtitle: Text(subtitle),
              trailing: PopupMenuButton<_ScheduleAction>(
                onSelected: (action) =>
                    _handleAction(context, ref, action, schedule.id),
                itemBuilder: (context) {
                  final theme = Theme.of(context);
                  return [
                    const PopupMenuItem(
                      value: _ScheduleAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _ScheduleAction.delete,
                      child: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ];
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Handles edit/delete actions from the schedule menu.
  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _ScheduleAction action,
    String scheduleId,
  ) async {
    switch (action) {
      case _ScheduleAction.edit:
        context.goNamed(
          AppRoute.editSchedule.name,
          pathParameters: {'scheduleId': scheduleId},
        );
        return;
      case _ScheduleAction.delete:
        final confirm =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete schedule?'),
                content: const Text(
                  'This will remove all future doses for this schedule.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
        if (!confirm) {
          return;
        }
        final controller = ref.read(scheduleEditorControllerProvider.notifier);
        final success = await controller.deleteSchedule(scheduleId);
        if (!context.mounted) {
          return;
        }
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Schedule deleted.')));
        } else {
          final message = ref
              .read(scheduleEditorControllerProvider)
              .errorMessage;
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
        return;
    }
  }
}

// Actions available for each schedule entry.
enum _ScheduleAction { edit, delete }
