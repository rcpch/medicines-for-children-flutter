import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/primary_carer_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
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
    StateNotifierProvider<PrimaryCarerController, PrimaryCarerState>((ref) {
  return PrimaryCarerController(ref);
});

class PrimaryCarerController extends StateNotifier<PrimaryCarerState> {
  PrimaryCarerController(this._ref)
      : _repository = _ref.read(primaryCarerRepositoryProvider),
        _localDataSource = _ref.read(primaryCarerLocalDataSourceProvider),
        super(const PrimaryCarerState()) {
    unawaited(_hydrateFromCache());
  }

  final Ref _ref;
  final PrimaryCarerRepository _repository;
  final PrimaryCarerLocalDataSource _localDataSource;

  Future<void> _hydrateFromCache() async {
    final cached = _localDataSource.read();
    if (!mounted) {
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final carer = await _repository.fetchPrimaryCarer();
      await _localDataSource.write(carer);
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        carer: carer,
        isLoading: false,
        isStale: false,
        clearError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load your family data. Pull to retry.',
      );
    }
  }

  Future<void> clear() async {
    await _localDataSource.clear();
    if (!mounted) {
      return;
    }
    state = const PrimaryCarerState();
  }
}
