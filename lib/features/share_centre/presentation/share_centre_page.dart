import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';

class ShareCentrePage extends ConsumerWidget {
  const ShareCentrePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  await ref.refresh(shareCentreSchedulesProvider(child.id).future);
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
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: schedules.length,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => ListView(
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
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
