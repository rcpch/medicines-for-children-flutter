import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/domain/daily_schedule_builder.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(primaryCarerControllerProvider);
    final controller = ref.read(primaryCarerControllerProvider.notifier);
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
        ],
      ),
      body: SafeArea(
        child: _HomeBody(
          state: state,
          onRefresh: controller.refresh,
          theme: theme,
          dailyScheduleBuilder: ref.watch(dailyScheduleBuilderProvider),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.onRefresh,
    required this.theme,
    required this.dailyScheduleBuilder,
  });

  final PrimaryCarerState state;
  final Future<void> Function() onRefresh;
  final ThemeData theme;
  final DailyScheduleBuilder dailyScheduleBuilder;

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
        : dailyScheduleBuilder.buildScheduledEntries(primaryChild, DateTime.now());
    final asNeededEntries = primaryChild == null
        ? <AsNeededAdministrationEntry>[]
        : dailyScheduleBuilder.buildAsNeededEntries(primaryChild, DateTime.now());

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
            _ScheduleSection(entries: scheduleEntries),
            const SizedBox(height: 16),
            _AsNeededSection(entries: asNeededEntries),
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
  const _ScheduleSection({required this.entries});

  final List<DailyScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s schedule',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('No scheduled medicines for today.'),
            for (final entry in entries)
              _ScheduleTile(entry: entry),
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
  const _AsNeededSection({required this.entries});

  final List<AsNeededAdministrationEntry> entries;

  @override
  Widget build(BuildContext context) {
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
