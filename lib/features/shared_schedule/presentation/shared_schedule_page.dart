import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/application/shared_schedule_providers.dart';
import 'package:share_plus/share_plus.dart';

class SharedSchedulePage extends ConsumerWidget {
  const SharedSchedulePage({super.key, required this.apiId});

  final String apiId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sharedScheduleSessionProvider);
    final telemetry = ref.read(telemetryServiceProvider);

    if (session == null || session.apiId != apiId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shared schedule')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Missing shared schedule session. Please open the link again.'),
        ),
      );
    }

    final modelAsync = ref.watch(sharedScheduleViewModelProvider(session));
    final repository = ref.read(sharedScheduleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared schedule'),
      ),
      body: modelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Unable to load schedule.\n\n$error'),
        ),
        data: (model) {
          final today = model.today ?? (model.days.isNotEmpty ? model.days.first : null);
          final dateRange = '${DateFormat.yMMMd().format(model.dateFrom)} – ${DateFormat.yMMMd().format(model.dateTo)}';

          if (today == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No schedule days available. ($dateRange)'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(dateRange, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (model.pdfUrl.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => Share.share(
                    model.pdfUrl,
                    subject: 'Shared schedule PDF',
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Share schedule PDF'),
                ),
              if (model.pdfUrl.isNotEmpty) const SizedBox(height: 12),
              if (model.status.toLowerCase() == 'pending')
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Awaiting confirmation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text('Let the primary carer know if you can cover this period.'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await repository.confirmSchedule(
                                    apiId: model.apiId,
                                    authToken: session.authToken,
                                    approved: true,
                                  );
                                  telemetry.trackEvent('share_schedule_approved', properties: {
                                    'shareId': model.apiId,
                                  });
                                  ref.invalidate(sharedScheduleViewModelProvider(session));
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Unable to approve: $error')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Approve'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () async {
                                final reason = await _promptDeclineReason(context);
                                if (reason == null) {
                                  return;
                                }
                                try {
                                  await repository.confirmSchedule(
                                    apiId: model.apiId,
                                    authToken: session.authToken,
                                    approved: false,
                                    reason: reason,
                                  );
                                  telemetry.trackEvent('share_schedule_declined', properties: {
                                    'shareId': model.apiId,
                                  });
                                  ref.invalidate(sharedScheduleViewModelProvider(session));
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Unable to decline: $error')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Decline'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              Text(
                'Today',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (today.scheduledItemsForDay.isEmpty)
                const Text('No scheduled medicines for today.')
              else
                ...today.scheduledItemsForDay.map((item) {
                  final medicine = model.medicinesById[item.medicineId];
                  final title = medicine?.displayName ?? 'Medicine';
                  return Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final time in item.times)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Expanded(child: Text(time)),
                                  TextButton(
                                    onPressed: () async {
                                      final dateTime = _mergeDateAndTime(today.date, time);
                                      if (dateTime == null) {
                                        return;
                                      }
                                      try {
                                        await repository.recordAdministration(
                                          apiId: model.apiId,
                                          authToken: session.authToken,
                                          parentId: model.parentId,
                                          adminBy: model.carerFirstName.isEmpty ? 'Carer' : model.carerFirstName,
                                          dateTime: dateTime,
                                          isAsNeeded: false,
                                          skipped: false,
                                          scheduledItemId: item.id,
                                        );
                                        telemetry.trackEvent('share_schedule_admin_recorded', properties: {
                                          'shareId': model.apiId,
                                          'scheduledItemId': item.id,
                                          'skipped': false,
                                        });
                                        ref.invalidate(sharedScheduleViewModelProvider(session));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Recorded as given.')),
                                          );
                                        }
                                      } catch (error) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Unable to record: $error')),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Given'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final dateTime = _mergeDateAndTime(today.date, time);
                                      if (dateTime == null) {
                                        return;
                                      }
                                      try {
                                        await repository.recordAdministration(
                                          apiId: model.apiId,
                                          authToken: session.authToken,
                                          parentId: model.parentId,
                                          adminBy: model.carerFirstName.isEmpty ? 'Carer' : model.carerFirstName,
                                          dateTime: dateTime,
                                          isAsNeeded: false,
                                          skipped: true,
                                          scheduledItemId: item.id,
                                        );
                                        telemetry.trackEvent('share_schedule_admin_recorded', properties: {
                                          'shareId': model.apiId,
                                          'scheduledItemId': item.id,
                                          'skipped': true,
                                        });
                                        ref.invalidate(sharedScheduleViewModelProvider(session));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Recorded as skipped.')),
                                          );
                                        }
                                      } catch (error) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Unable to record: $error')),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Skip'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Future<String?> _promptDeclineReason(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline schedule'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Add a note for the primary carer',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(context).pop(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  DateTime? _mergeDateAndTime(DateTime date, String timeString) {
    final sanitized = timeString.trim().toUpperCase();
    const patterns = ['HH:mm', 'H:mm', 'h:mma', 'hh:mma'];
    for (final pattern in patterns) {
      try {
        final parsed = DateFormat(pattern).parseStrict(sanitized);
        return DateTime(date.year, date.month, date.day, parsed.hour, parsed.minute);
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
