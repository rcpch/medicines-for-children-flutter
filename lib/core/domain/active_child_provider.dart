// Provider for active child state.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';

/// Manages the selected child id for the active profile.
class SelectedChildController extends Notifier<String?> {
  SelectedChildController();

  late ActiveChildLocalDataSource _storage;
  String? _profileId;

  /// Initializes state from storage and listens for auth changes.
  @override
  String? build() {
    _storage = ref.watch(activeChildLocalDataSourceProvider);

    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => _handleAuthChange(next),
    );

    final auth = ref.watch(authControllerProvider);
    final profileId = auth.user?.uid;
    _profileId = profileId;

    final initial = (profileId == null || profileId.isEmpty)
        ? null
        : _storage.readActiveChildId(profileId);

    return initial;
  }

  /// Updates selected child state when the active profile changes.
  void _handleAuthChange(AuthState next) {
    final profileId = next.user?.uid;
    if (_profileId == profileId) {
      return;
    }
    _profileId = profileId;
    if (profileId == null || profileId.isEmpty) {
      state = null;
      return;
    }
    state = _storage.readActiveChildId(profileId);
  }

  /// Persists the newly selected child id for the current profile.
  Future<void> selectChild(String childId) async {
    final profileId = _profileId;
    if (profileId == null || profileId.isEmpty) {
      return;
    }
    state = childId;
    await _storage.writeActiveChildId(profileId, childId);
  }
}

/// Provides the selected child id state.
final selectedChildIdProvider =
    NotifierProvider<SelectedChildController, String?>(
      SelectedChildController.new,
    );

/// Provides the active child entity resolved from the selected id.
final activeChildProvider = Provider<Child?>((ref) {
  final state = ref.watch(primaryCarerStateProvider);
  final selectedChildId = ref.watch(selectedChildIdProvider);
  final carer = state.carer;
  if (carer == null || carer.children.isEmpty) {
    return null;
  }
  if (selectedChildId == null || selectedChildId.isEmpty) {
    return carer.children.first;
  }
  return carer.children.cast<Child?>().firstWhere(
    (child) => child?.id == selectedChildId,
    orElse: () => carer.children.first,
  );
});
