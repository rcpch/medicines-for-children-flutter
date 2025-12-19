import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';

final activeChildProvider = Provider<Child?>((ref) {
  final state = ref.watch(primaryCarerStateProvider);
  final carer = state.carer;
  if (carer == null || carer.children.isEmpty) {
    return null;
  }
  return carer.children.first;
});
