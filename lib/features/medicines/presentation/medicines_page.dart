import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/platform/image_provider.dart';
import 'package:medicines_for_children_flutter/core/presentation/child_switcher_action.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';

enum MedicineFilter { everyday, asNeeded }

class MedicinesPage extends ConsumerStatefulWidget {
  const MedicinesPage({super.key});

  @override
  ConsumerState<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends ConsumerState<MedicinesPage> {
  MedicineFilter _filter = MedicineFilter.everyday;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(primaryCarerStateProvider);
    final child = ref.watch(activeChildProvider);

    if (state.isLoading && child == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (child == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medicines'),
          actions: const [ChildSwitcherAction()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(state.errorMessage ?? 'No child profile available yet.'),
        ),
      );
    }

    final filtered = _filterMedicines(child.medicines);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
        actions: const [ChildSwitcherAction()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      state.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SegmentedButton<MedicineFilter>(
                segments: const [
                  ButtonSegment(
                    value: MedicineFilter.everyday,
                    label: Text('Everyday'),
                  ),
                  ButtonSegment(
                    value: MedicineFilter.asNeeded,
                    label: Text('As-needed'),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (selection) {
                  setState(() {
                    _filter = selection.first;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => context.goNamed(AppRoute.addMedicine.name),
                        icon: const Icon(Icons.add),
                        label: const Text('Add medicine'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.tonalIcon(
                        onPressed: () => context.goNamed(AppRoute.scanMedicine.name),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Add by QR code'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No medicines match this filter.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemBuilder: (context, index) {
                        final medicine = filtered[index];
                        return _MedicineTile(
                          medicine: medicine,
                          onTap: () => context.goNamed(
                            AppRoute.medicineDetail.name,
                            pathParameters: {'medicineId': medicine.id},
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: filtered.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Medicine> _filterMedicines(List<Medicine> medicines) {
    return medicines.where((medicine) {
      if (medicine.status == MedicineStatus.noLongerUsed) {
        return false;
      }
      switch (_filter) {
        case MedicineFilter.everyday:
          return medicine.type == MedicineType.everyday || medicine.type == MedicineType.both;
        case MedicineFilter.asNeeded:
          return medicine.type == MedicineType.asNeeded || medicine.type == MedicineType.both;
      }
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({
    required this.medicine,
    required this.onTap,
  });

  final Medicine medicine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photos = _resolvePhotos(medicine);
    final photo = photos.isEmpty ? null : photos.first;
    final imageProvider = photo == null ? null : createImageProvider(photo);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceVariant,
          backgroundImage: imageProvider,
          child: imageProvider == null ? const Icon(Icons.medication_outlined) : null,
        ),
        title: Text(medicine.name),
        subtitle: Text('${medicine.dose} ${medicine.doseUnit} · ${medicine.route}'),
        trailing: Text(
          _typeLabel(medicine.type),
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  List<String> _resolvePhotos(Medicine medicine) {
    if (medicine.photoUrls.isNotEmpty) {
      return medicine.photoUrls;
    }
    if (medicine.photoUrl != null && medicine.photoUrl!.trim().isNotEmpty) {
      return [medicine.photoUrl!];
    }
    return const [];
  }

  String _typeLabel(MedicineType type) {
    switch (type) {
      case MedicineType.everyday:
        return 'Everyday';
      case MedicineType.asNeeded:
        return 'As-needed';
      case MedicineType.both:
        return 'Everyday + as-needed';
    }
  }
}
