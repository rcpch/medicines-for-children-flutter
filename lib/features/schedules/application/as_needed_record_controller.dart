// Controller for as-needed dose records.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/as_needed_repository.dart';

// Holds UI state for recording an as-needed dose.
class AsNeededRecordState {
  const AsNeededRecordState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  // Creates a new state with selective field overrides.
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

// Handles as-needed administration records and refreshes cache.
class AsNeededRecordController extends Notifier<AsNeededRecordState> {
  late AsNeededRepository _repository;

  @override
  // Wires up dependencies and initializes default state.
  AsNeededRecordState build() {
    _repository = ref.watch(asNeededRepositoryProvider);
    return const AsNeededRecordState();
  }

  // Records an as-needed administration for a medicine.
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

  // Reloads cached carer data after recording a dose.
  Future<void> _refreshCarerCache() async {
    await ref.read(primaryCarerControllerProvider.notifier).refreshFromLocal();
  }
}

// Provides access to the as-needed record controller.
final asNeededRecordControllerProvider =
    NotifierProvider<AsNeededRecordController, AsNeededRecordState>(
      AsNeededRecordController.new,
    );
