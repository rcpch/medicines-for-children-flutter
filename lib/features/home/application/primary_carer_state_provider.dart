// Provider for primary carer state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';

final primaryCarerStateProvider = Provider<PrimaryCarerState>((ref) {
  // Exposes the current primary carer state.
  return ref.watch(primaryCarerControllerProvider);
});
