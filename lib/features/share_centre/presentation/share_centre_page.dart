import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/platform/backup_file_io.dart';
import 'package:medicines_for_children_flutter/core/pdf/medicine_summary_pdf_service.dart';
import 'package:medicines_for_children_flutter/core/pdf/schedule_pdf_service.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';
import 'package:printing/printing.dart';

class ShareCentrePage extends ConsumerStatefulWidget {
  const ShareCentrePage({super.key});

  @override
  ConsumerState<ShareCentrePage> createState() => _ShareCentrePageState();
}

class _ShareCentrePageState extends ConsumerState<ShareCentrePage> {
  bool _exportingSchedule = false;
  bool _exportingMedicines = false;
  bool _printingSchedule = false;
  bool _printingMedicines = false;

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(activeChildProvider);
    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Share centre')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available yet.'),
        ),
      );
    }

    final actionState = ref.watch(shareCentreControllerProvider);
    final schedulesAsync = ref.watch(shareCentreSchedulesProvider(child.id));
    final carerState = ref.watch(primaryCarerStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Share centre')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoute.shareCentreCreate.name),
        icon: const Icon(Icons.add),
        label: const Text('New share'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Export PDFs', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const Text('Generate a PDF from local data to share or print.'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _exportingSchedule
                                ? null
                                : () => _exportSchedulePdf(context, carerState),
                            icon: _exportingSchedule
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Export schedule'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _exportingMedicines
                                ? null
                                : () => _exportMedicinePdf(context, carerState),
                            icon: _exportingMedicines
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.medication_outlined),
                            label: const Text('Export medicines'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _printingSchedule
                                ? null
                                : () => _printSchedulePdf(context, carerState),
                            icon: _printingSchedule
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.print_outlined),
                            label: const Text('Print schedule'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _printingMedicines
                                ? null
                                : () => _printMedicinesPdf(context, carerState),
                            icon: _printingMedicines
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.print_outlined),
                            label: const Text('Print medicines'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (actionState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Card(
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
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final _ = await ref.refresh(shareCentreSchedulesProvider(child.id).future);
                },
                child: schedulesAsync.when(
                  data: (schedules) {
                    if (schedules.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('There are no shared schedules.'),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return _ShareScheduleTile(
                          schedule: schedule,
                          onTap: () => context.pushNamed(
                            AppRoute.shareCentreDetail.name,
                            pathParameters: {'shareId': schedule.apiId},
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemCount: schedules.length,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Text('Unable to load shared schedules right now.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportSchedulePdf(BuildContext context, PrimaryCarerState carerState) async {
    setState(() => _exportingSchedule = true);
    try {
      final schedule = await _buildSchedulePdf(context, carerState);
      if (schedule == null) {
        return;
      }
      final bytes = schedule.bytes;
      final fileIO = ref.read(backupFileIOProvider);
      final fileName =
          'mfc-schedule-${DateFormat('yyyyMMdd').format(schedule.range.start)}-${DateFormat('yyyyMMdd').format(schedule.range.end)}.pdf';
      await fileIO.saveBytes(
        bytes: bytes,
        filename: fileName,
        mimeType: 'application/pdf',
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule PDF saved.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to export schedule: $error')),
      );
    } finally {
      if (context.mounted) {
        setState(() => _exportingSchedule = false);
      }
    }
  }

  Future<void> _exportMedicinePdf(BuildContext context, PrimaryCarerState carerState) async {
    setState(() => _exportingMedicines = true);
    try {
      final bytes = await _buildMedicinesPdf(context, carerState);
      if (bytes == null) {
        return;
      }
      final fileIO = ref.read(backupFileIOProvider);
      final fileName = 'mfc-medicines-${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      await fileIO.saveBytes(
        bytes: bytes,
        filename: fileName,
        mimeType: 'application/pdf',
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicines PDF saved.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to export medicines: $error')),
      );
    } finally {
      if (context.mounted) {
        setState(() => _exportingMedicines = false);
      }
    }
  }

  Future<void> _printSchedulePdf(BuildContext context, PrimaryCarerState carerState) async {
    setState(() => _printingSchedule = true);
    try {
      final schedule = await _buildSchedulePdf(context, carerState);
      if (schedule == null) {
        return;
      }
      await Printing.layoutPdf(
        onLayout: (_) async => schedule.bytes,
        name:
            'mfc-schedule-${DateFormat('yyyyMMdd').format(schedule.range.start)}-${DateFormat('yyyyMMdd').format(schedule.range.end)}.pdf',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to print schedule: $error')),
      );
    } finally {
      if (context.mounted) {
        setState(() => _printingSchedule = false);
      }
    }
  }

  Future<void> _printMedicinesPdf(BuildContext context, PrimaryCarerState carerState) async {
    setState(() => _printingMedicines = true);
    try {
      final bytes = await _buildMedicinesPdf(context, carerState);
      if (bytes == null) {
        return;
      }
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'mfc-medicines-${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to print medicines: $error')),
      );
    } finally {
      if (context.mounted) {
        setState(() => _printingMedicines = false);
      }
    }
  }

  Future<_SchedulePdfPayload?> _buildSchedulePdf(
    BuildContext context,
    PrimaryCarerState carerState,
  ) async {
    final child = ref.read(activeChildProvider);
    if (child == null || carerState.carer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access child profile data.')),
      );
      return null;
    }

    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 7)),
      ),
    );
    if (!context.mounted) {
      return null;
    }
    if (range == null) {
      return null;
    }
    final days = range.end.difference(range.start).inDays;
    if (days > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule export is limited to 14 days.')),
      );
      return null;
    }

    final pdfService = ref.read(schedulePdfServiceProvider);
    final bytes = await pdfService.buildPdf(
      carer: carerState.carer!,
      child: child,
      dateFrom: range.start,
      dateTo: range.end,
    );
    return _SchedulePdfPayload(bytes: bytes, range: range);
  }

  Future<Uint8List?> _buildMedicinesPdf(
    BuildContext context,
    PrimaryCarerState carerState,
  ) async {
    final child = ref.read(activeChildProvider);
    if (child == null || carerState.carer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access child profile data.')),
      );
      return null;
    }
    final pdfService = ref.read(medicineSummaryPdfServiceProvider);
    return pdfService.buildPdf(
      carer: carerState.carer!,
      child: child,
    );
  }
}

class _SchedulePdfPayload {
  const _SchedulePdfPayload({
    required this.bytes,
    required this.range,
  });

  final Uint8List bytes;
  final DateTimeRange range;
}

class _ShareScheduleTile extends StatelessWidget {
  const _ShareScheduleTile({
    required this.schedule,
    required this.onTap,
  });

  final ShareCentreSchedule schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDateRange(schedule.dateFrom, schedule.dateTo);
    final statusLabel = schedule.status.isEmpty ? 'Pending' : schedule.status;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(schedule.isDigital ? Icons.link : Icons.picture_as_pdf_outlined),
        ),
        title: Text(schedule.displayCarer),
        subtitle: Text('$dateLabel · $statusLabel'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String _formatDateRange(DateTime start, DateTime end) {
  final formatter = DateFormat('d MMM');
  final startLabel = formatter.format(start);
  final endLabel = formatter.format(end);
  if (start.year == end.year) {
    return '$startLabel – $endLabel';
  }
  return '${DateFormat('d MMM y').format(start)} – ${DateFormat('d MMM y').format(end)}';
}
