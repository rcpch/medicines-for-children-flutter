// Controller for as-needed dose records.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/as_needed_repository.dart';

class AsNeededRecordState {
  const AsNeededRecordState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  AsNeededRecordState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AsNeededRecordState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AsNeededRecordController extends StateNotifier<AsNeededRecordState> {
  AsNeededRecordController(this._ref, this._repository)
    : super(const AsNeededRecordState());

  final Ref _ref;
  final AsNeededRepository _repository;

  Future<bool> recordAdministration({
    required String medicineId,
    required DateTime dateTime,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.recordAdministration(
        medicineId: medicineId,
        dateTime: dateTime,
        notes: notes,
      );
      await _refreshCarerCache();
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to record this dose right now.',
      );
      return false;
    }
  }

  Future<void> _refreshCarerCache() async {
    await _ref.read(primaryCarerControllerProvider.notifier).refreshFromLocal();
  }
}

final asNeededRecordControllerProvider =
    StateNotifierProvider<AsNeededRecordController, AsNeededRecordState>((ref) {
      final repository = ref.watch(asNeededRepositoryProvider);
      return AsNeededRecordController(ref, repository);
    });
