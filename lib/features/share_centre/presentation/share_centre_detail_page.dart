import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';

class ShareCentreDetailPage extends ConsumerWidget {
  const ShareCentreDetailPage({super.key, required this.shareId});

  final String shareId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Share details')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available yet.'),
        ),
      );
    }

    final actionState = ref.watch(shareCentreControllerProvider);
    final controller = ref.read(shareCentreControllerProvider.notifier);
    final schedulesAsync = ref.watch(shareCentreSchedulesProvider(child.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Share details')),
      body: SafeArea(
        child: schedulesAsync.when(
          data: (schedules) {
            final schedule = schedules.cast<ShareCentreSchedule?>().firstWhere(
                  (item) => item?.apiId == shareId,
                  orElse: () => null,
                );
            if (schedule == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Shared schedule not found.'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (actionState.errorMessage != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        actionState.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.displayCarer, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Status', value: _statusLabel(schedule)),
                        _InfoRow(
                          label: 'Dates',
                          value: '${DateFormat.yMMMd().format(schedule.dateFrom)} – '
                              '${DateFormat.yMMMd().format(schedule.dateTo)}',
                        ),
                        _InfoRow(label: 'Format', value: schedule.isDigital ? 'Digital' : 'PDF'),
                        if (schedule.carerEmail.isNotEmpty)
                          _InfoRow(label: 'Email', value: schedule.carerEmail),
                        if (schedule.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Notes', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(schedule.notes),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (schedule.scheduleUrl.isNotEmpty)
                  FilledButton.icon(
                    onPressed: actionState.isSaving
                        ? null
                        : () => _copyToClipboard(context, schedule.scheduleUrl, 'Schedule link copied.'),
                    icon: const Icon(Icons.link),
                    label: const Text('Copy schedule link'),
                  ),
                if (schedule.pdfUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: actionState.isSaving
                        ? null
                        : () => _copyToClipboard(context, schedule.pdfUrl, 'PDF link copied.'),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Copy PDF link'),
                  ),
                ],
                const SizedBox(height: 24),
                Text('Manage share', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: actionState.isSaving
                      ? null
                      : () async {
                          final selected = await _selectDate(
                            context,
                            initialDate: schedule.dateTo,
                            firstDate: schedule.dateFrom,
                          );
                          if (selected == null) {
                            return;
                          }
                          final result = await controller.updateSchedule(
                            childId: child.id,
                            apiId: schedule.apiId,
                            dateFrom: schedule.dateFrom,
                            dateTo: selected,
                          );
                          if (result != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share updated.')),
                            );
                          }
                        },
                  child: const Text('Extend share'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: actionState.isSaving
                      ? null
                      : () async {
                          final confirmed = await _confirmAction(
                            context,
                            title: 'End this share?',
                            message: 'The carer will no longer have access after today.',
                          );
                          if (confirmed != true) {
                            return;
                          }
                          final result = await controller.endSchedule(
                            childId: child.id,
                            apiId: schedule.apiId,
                          );
                          if (result != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share ended.')),
                            );
                          }
                        },
                  child: const Text('End share'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: actionState.isSaving
                      ? null
                      : () async {
                          final confirmed = await _confirmAction(
                            context,
                            title: 'Delete this share?',
                            message: 'This will remove the share from your list.',
                          );
                          if (confirmed != true) {
                            return;
                          }
                          final result = await controller.deleteSchedule(
                            childId: child.id,
                            apiId: schedule.apiId,
                            dateFrom: schedule.dateFrom,
                            dateTo: schedule.dateTo,
                          );
                          if (result != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share deleted.')),
                            );
                          }
                        },
                  child: Text(
                    'Delete share',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Unable to load share details right now.'),
          ),
        ),
      ),
    );
  }

  String _statusLabel(ShareCentreSchedule schedule) {
    if (schedule.status.isNotEmpty) {
      return schedule.status;
    }
    return schedule.isDeleted ? 'Ended' : 'Pending';
  }

  Future<void> _copyToClipboard(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<DateTime?> _selectDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: initialDate.add(const Duration(days: 365)),
    );
  }

  Future<bool?> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
