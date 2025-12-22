import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';

class ChildSwitcherAction extends ConsumerWidget {
  const ChildSwitcherAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carer = ref.watch(primaryCarerStateProvider).carer;
    if (carer == null || carer.children.length < 2) {
      return const SizedBox.shrink();
    }

    final selectedId = ref.watch(selectedChildIdProvider);
    final selected = _resolveSelected(carer.children, selectedId);

    return Semantics(
      button: true,
      label: 'Select child profile',
      child: PopupMenuButton<String>(
        tooltip: 'Select child',
        initialValue: selected.id,
        onSelected: (childId) {
          ref.read(selectedChildIdProvider.notifier).selectChild(childId);
        },
        itemBuilder: (context) => [
          for (final child in carer.children)
            PopupMenuItem<String>(
              value: child.id,
              child: Row(
                children: [
                  if (child.id == selected.id)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${child.firstName} ${child.lastName}'.trim())),
                ],
              ),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_alt_outlined),
              const SizedBox(width: 6),
              Text(
                selected.firstName.isEmpty ? 'Child' : selected.firstName,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Child _resolveSelected(List<Child> children, String? selectedId) {
    return children.cast<Child?>().firstWhere(
          (child) => child?.id == selectedId,
          orElse: () => null,
        ) ??
        children.first;
  }
}
