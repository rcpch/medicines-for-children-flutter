import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/application/shared_schedule_providers.dart';

class SharedSchedulePage extends ConsumerWidget {
  const SharedSchedulePage({super.key, required this.apiId});

  final String apiId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sharedScheduleSessionProvider);

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
                  final times = item.times.join(', ');
                  return Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(times),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
