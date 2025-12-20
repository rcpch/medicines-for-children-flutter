import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/offline/shared_schedule_action_queue.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/application/shared_schedule_providers.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/data/shared_schedule_repository.dart';
import 'package:share_plus/share_plus.dart';

enum _SharedScheduleTab { schedule, info }

class SharedSchedulePage extends ConsumerStatefulWidget {
  const SharedSchedulePage({super.key, required this.apiId});

  final String apiId;

  @override
  ConsumerState<SharedSchedulePage> createState() => _SharedSchedulePageState();
}

class _SharedSchedulePageState extends ConsumerState<SharedSchedulePage> {
  static const _guidanceDismissedKey = 'shared_schedule_guidance_dismissed';

  _SharedScheduleTab _selectedTab = _SharedScheduleTab.schedule;
  bool _showGuidance = false;
  bool _guidanceLoaded = false;
  bool _exportingPdf = false;
  String? _generatedPdfUrl;

  @override
  void initState() {
    super.initState();
    _loadGuidancePreference();
  }

  Future<void> _loadGuidancePreference() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final dismissed = prefs.getBool(_guidanceDismissedKey) ?? false;
    if (!mounted) {
      return;
    }
    setState(() {
      _showGuidance = !dismissed;
      _guidanceLoaded = true;
    });
  }

  Future<void> _dismissGuidance() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_guidanceDismissedKey, true);
    if (!mounted) {
      return;
    }
    setState(() {
      _showGuidance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sharedScheduleSessionProvider);
    final telemetry = ref.read(telemetryServiceProvider);
    final actionQueue = ref.read(sharedScheduleActionQueueServiceProvider);

    if (session == null || session.apiId != widget.apiId) {
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
          final pdfUrl = _generatedPdfUrl ?? model.pdfUrl;

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
              SegmentedButton<_SharedScheduleTab>(
                segments: const [
                  ButtonSegment(
                    value: _SharedScheduleTab.schedule,
                    label: Text('Schedule'),
                  ),
                  ButtonSegment(
                    value: _SharedScheduleTab.info,
                    label: Text('Important info'),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (value) {
                  setState(() => _selectedTab = value.first);
                },
              ),
              const SizedBox(height: 16),
              if (_selectedTab == _SharedScheduleTab.info)
                _ImportantInfoSection(
                  dateRange: dateRange,
                  durationLabel: _formatDuration(model.dateFrom, model.dateTo),
                  childName: model.child.displayName,
                  childCondition: model.child.condition,
                  childNotes: model.child.notes,
                  allergies: model.child.allergies,
                  pdfUrl: pdfUrl,
                  exportingPdf: _exportingPdf,
                  onDownload: () => _handleDownloadPdf(
                    context,
                    repository,
                    session,
                    model,
                  ),
                )
              else ...[
                if (_guidanceLoaded && _showGuidance)
                  _GuidanceCard(
                    parentName: model.parentId,
                    onDismiss: _dismissGuidance,
                  ),
                if (_guidanceLoaded && _showGuidance) const SizedBox(height: 12),
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
                                    if (_isNetworkError(error)) {
                                      await actionQueue.enqueue(
                                        PendingSharedScheduleAction(
                                          id: 'shared-confirm-${DateTime.now().millisecondsSinceEpoch}',
                                          type: SharedScheduleActionType.confirm,
                                          payload: {
                                            'apiId': model.apiId,
                                            'authToken': session.authToken,
                                            'approved': true,
                                            'reason': null,
                                          },
                                          queuedAt: DateTime.now(),
                                        ),
                                      );
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _isNetworkError(error)
                                                ? 'No connection. Approval queued for retry.'
                                                : 'Unable to approve: $error',
                                          ),
                                        ),
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
                                    if (_isNetworkError(error)) {
                                      await actionQueue.enqueue(
                                        PendingSharedScheduleAction(
                                          id: 'shared-decline-${DateTime.now().millisecondsSinceEpoch}',
                                          type: SharedScheduleActionType.confirm,
                                          payload: {
                                            'apiId': model.apiId,
                                            'authToken': session.authToken,
                                            'approved': false,
                                            'reason': reason,
                                          },
                                          queuedAt: DateTime.now(),
                                        ),
                                      );
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _isNetworkError(error)
                                                ? 'No connection. Decline queued for retry.'
                                                : 'Unable to decline: $error',
                                          ),
                                        ),
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
                                            adminBy:
                                                model.carerFirstName.isEmpty ? 'Carer' : model.carerFirstName,
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
                                          if (_isNetworkError(error)) {
                                            await actionQueue.enqueue(
                                              PendingSharedScheduleAction(
                                                id: 'shared-record-${DateTime.now().millisecondsSinceEpoch}',
                                                type: SharedScheduleActionType.record,
                                                payload: {
                                                  'apiId': model.apiId,
                                                  'authToken': session.authToken,
                                                  'parentId': model.parentId,
                                                  'adminBy': model.carerFirstName.isEmpty
                                                      ? 'Carer'
                                                      : model.carerFirstName,
                                                  'dateTime': dateTime.toIso8601String(),
                                                  'isAsNeeded': false,
                                                  'skipped': false,
                                                  'scheduledItemId': item.id,
                                                  'medicineId': null,
                                                  'notes': null,
                                                },
                                                queuedAt: DateTime.now(),
                                              ),
                                            );
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  _isNetworkError(error)
                                                      ? 'No connection. Record queued for retry.'
                                                      : 'Unable to record: $error',
                                                ),
                                              ),
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
                                            adminBy:
                                                model.carerFirstName.isEmpty ? 'Carer' : model.carerFirstName,
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
                                          if (_isNetworkError(error)) {
                                            await actionQueue.enqueue(
                                              PendingSharedScheduleAction(
                                                id: 'shared-skip-${DateTime.now().millisecondsSinceEpoch}',
                                                type: SharedScheduleActionType.record,
                                                payload: {
                                                  'apiId': model.apiId,
                                                  'authToken': session.authToken,
                                                  'parentId': model.parentId,
                                                  'adminBy': model.carerFirstName.isEmpty
                                                      ? 'Carer'
                                                      : model.carerFirstName,
                                                  'dateTime': dateTime.toIso8601String(),
                                                  'isAsNeeded': false,
                                                  'skipped': true,
                                                  'scheduledItemId': item.id,
                                                  'medicineId': null,
                                                  'notes': null,
                                                },
                                                queuedAt: DateTime.now(),
                                              ),
                                            );
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  _isNetworkError(error)
                                                      ? 'No connection. Record queued for retry.'
                                                      : 'Unable to record: $error',
                                                ),
                                              ),
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
            ],
          );
        },
      ),
    );
  }

  Future<String?> _promptDeclineReason(BuildContext context) async {
    var reason = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline schedule'),
        content: SingleChildScrollView(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'Add a note for the primary carer',
            ),
            onChanged: (value) => reason = value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.of(context).pop(reason.trim()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(reason.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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

  Future<void> _handleDownloadPdf(
    BuildContext context,
    SharedScheduleRepository repository,
    SharedScheduleSession session,
    SharedScheduleViewModel model,
  ) async {
    final pdfUrl = _generatedPdfUrl ?? model.pdfUrl;
    if (pdfUrl.isNotEmpty) {
      Share.share(pdfUrl, subject: 'Shared schedule PDF');
      return;
    }
    setState(() => _exportingPdf = true);
    try {
      final url = await repository.exportSharedSchedulePdf(
        apiId: model.apiId,
        authToken: session.authToken,
        dateFrom: model.dateFrom,
        dateTo: model.dateTo,
        primaryCarerEmail: model.parentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _generatedPdfUrl = url;
        _exportingPdf = false;
      });
      Share.share(url, subject: 'Shared schedule PDF');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _exportingPdf = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate PDF: $error')),
      );
    }
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.parentName,
    required this.onDismiss,
  });

  final String parentName;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Guidance', style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'It can be difficult for a parent to leave their child with someone, '
              'and it can also be hard to take care of them. We’ve tried to make '
              'the process as easy as possible for you, the parent, and the child.',
            ),
            const SizedBox(height: 8),
            Text(
              'Updating the medicine schedule in real time means that $parentName can see '
              'a medicine has been given as soon as you record it.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportantInfoSection extends StatelessWidget {
  const _ImportantInfoSection({
    required this.dateRange,
    required this.durationLabel,
    required this.childName,
    required this.childCondition,
    required this.childNotes,
    required this.allergies,
    required this.pdfUrl,
    required this.exportingPdf,
    required this.onDownload,
  });

  final String dateRange;
  final String durationLabel;
  final String childName;
  final String childCondition;
  final String childNotes;
  final List<String> allergies;
  final String pdfUrl;
  final bool exportingPdf;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello.',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text('Thank you for helping to look after $childName.'),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Care period',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateRange),
              const SizedBox(height: 6),
              Text('This period will run for: $durationLabel'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Important notes',
          child: Text(
            childCondition.isNotEmpty || childNotes.isNotEmpty
                ? [childCondition, childNotes].where((item) => item.trim().isNotEmpty).join('\n')
                : 'No notes provided.',
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Allergies',
          child: Text(
            allergies.isEmpty ? 'No allergies listed.' : allergies.join(', '),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You can download and print this schedule instead of completing it digitally.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: exportingPdf ? null : onDownload,
            icon: exportingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(pdfUrl.isEmpty ? 'Generate schedule PDF' : 'Share schedule PDF'),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

bool _isNetworkError(Object error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.unknown;
  }
  return false;
}

String _formatDuration(DateTime start, DateTime end) {
  final days = end.difference(start).inDays;
  if (days <= 0) {
    return 'Less than a day';
  }
  return days == 1 ? '1 day' : '$days days';
}
