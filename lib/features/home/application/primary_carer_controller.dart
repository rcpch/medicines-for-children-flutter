// Controller for primary carer profile data.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/primary_carer_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/home/data/primary_carer_repository.dart';

class PrimaryCarerState {
  const PrimaryCarerState({
    this.carer,
    this.isLoading = false,
    this.isStale = false,
    this.errorMessage,
  });

  final PrimaryCarer? carer;
  final bool isLoading;
  final bool isStale;
  final String? errorMessage;

  PrimaryCarerState copyWith({
    PrimaryCarer? carer,
    bool clearCarer = false,
    bool? isLoading,
    bool? isStale,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PrimaryCarerState(
      carer: clearCarer ? null : (carer ?? this.carer),
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final primaryCarerControllerProvider =
    NotifierProvider<PrimaryCarerController, PrimaryCarerState>(
      PrimaryCarerController.new,
    );

class PrimaryCarerController extends Notifier<PrimaryCarerState> {
  late PrimaryCarerRepository _repository;
  late PrimaryCarerLocalDataSource _localDataSource;
  String? _activeProfileId;

  @override
  PrimaryCarerState build() {
    _repository = ref.read(primaryCarerRepositoryProvider);
    _localDataSource = ref.read(primaryCarerLocalDataSourceProvider);
    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => unawaited(_handleAuthChange(previous, next)),
    );

    final auth = ref.watch(authControllerProvider);
    final profileId = auth.user?.uid;
    _activeProfileId = profileId;

    if (profileId == null || profileId.isEmpty) {
      return const PrimaryCarerState();
    }

    final cached = _localDataSource.readForProfile(profileId);
    if (cached == null) {
      return const PrimaryCarerState();
    }
    return const PrimaryCarerState().copyWith(
      carer: cached,
      isStale: true,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> _handleAuthChange(AuthState? previous, AuthState next) async {
    final profileId = next.user?.uid;
    if (_activeProfileId == profileId) {
      return;
    }
    _activeProfileId = profileId;
    if (profileId == null) {
      state = const PrimaryCarerState();
      return;
    }
    final cached = _localDataSource.readForProfile(profileId);
    if (!ref.mounted) {
      return;
    }
    if (cached != null) {
      state = state.copyWith(
        carer: cached,
        isStale: true,
        isLoading: false,
        clearError: true,
      );
    }
  }

  Future<void> refresh() async {
    final profileId = _activeProfileId;
    if (profileId == null || profileId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Select a profile to load your family data.',
      );
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final carer = await _repository.fetchPrimaryCarer();
      await _localDataSource.writeForProfile(profileId, carer);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        carer: carer,
        isLoading: false,
        isStale: false,
        clearError: true,
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load your family data. Pull to retry.',
      );
    }
  }

  Future<void> clear() async {
    final profileId = _activeProfileId;
    if (profileId != null) {
      await _localDataSource.clearForProfile(profileId);
    }
    if (!ref.mounted) {
      return;
    }
    state = const PrimaryCarerState();
  }

  Future<bool> addChild(Child child) async {
    final profileId = _activeProfileId;
    if (profileId == null || profileId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Select a profile before adding a child.',
      );
      return false;
    }
    final current = state.carer ?? _localDataSource.readForProfile(profileId);
    if (current == null) {
      state = state.copyWith(
        errorMessage: 'Unable to access your profile data.',
      );
      return false;
    }
    final updated = current.copyWith(children: [...current.children, child]);
    await _localDataSource.writeForProfile(profileId, updated);
    if (!ref.mounted) {
      return false;
    }
    state = state.copyWith(carer: updated, isStale: false, clearError: true);
    await ref.read(selectedChildIdProvider.notifier).selectChild(child.id);
    return true;
  }

  Future<void> refreshFromLocal() async {
    final profileId = _activeProfileId;
    if (profileId == null || profileId.isEmpty) {
      return;
    }
    final cached = _localDataSource.readForProfile(profileId);
    if (cached == null || !ref.mounted) {
      return;
    }
    state = state.copyWith(
      carer: cached,
      isLoading: false,
      isStale: false,
      clearError: true,
    );
  }
}
