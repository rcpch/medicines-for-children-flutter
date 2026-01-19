// Provider for active child state.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';

class SelectedChildController extends StateNotifier<String?> {
  SelectedChildController(this._ref, this._storage) : super(null) {
    _authSub = _ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => _handleAuthChange(next),
      fireImmediately: true,
    );
    _carerSub = _ref.listen<PrimaryCarerState>(
      primaryCarerStateProvider,
      (previous, next) => _handleCarerChange(next),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  final ActiveChildLocalDataSource _storage;
  ProviderSubscription<AuthState>? _authSub;
  ProviderSubscription<PrimaryCarerState>? _carerSub;
  String? _profileId;
  PrimaryCarerState? _carerState;

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
    _syncWithCarer();
  }

  void _handleCarerChange(PrimaryCarerState next) {
    _carerState = next;
    _syncWithCarer();
  }

  void _syncWithCarer() {
    final profileId = _profileId;
    final carer = _carerState?.carer;
    if (profileId == null || profileId.isEmpty || carer == null || carer.children.isEmpty) {
      state = null;
      return;
    }
    final currentId = state;
    final selected = carer.children.cast<Child?>().firstWhere(
          (child) => child?.id == currentId,
          orElse: () => null,
        ) ??
        carer.children.first;
    if (selected.id != currentId) {
      state = selected.id;
      unawaited(_storage.writeActiveChildId(profileId, selected.id));
    }
  }

  Future<void> selectChild(String childId) async {
    final profileId = _profileId;
    if (profileId == null || profileId.isEmpty) {
      return;
    }
    state = childId;
    await _storage.writeActiveChildId(profileId, childId);
  }

  @override
  void dispose() {
    _authSub?.close();
    _carerSub?.close();
    super.dispose();
  }
}

final selectedChildIdProvider = StateNotifierProvider<SelectedChildController, String?>((ref) {
  final storage = ref.watch(activeChildLocalDataSourceProvider);
  return SelectedChildController(ref, storage);
});

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
