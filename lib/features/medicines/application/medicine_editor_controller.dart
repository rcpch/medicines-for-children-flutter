// Controller for creating/editing medicines.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/medicines/data/medicine_repository.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';

// Holds UI state for medicine create/edit actions.
class MedicineEditorState {
  const MedicineEditorState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  // Returns a copy with updated state fields.
  MedicineEditorState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MedicineEditorState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Coordinates medicine create/update/archive actions.
class MedicineEditorController extends Notifier<MedicineEditorState> {
  late MedicineRepository _repository;

  // Loads the repository and initial controller state.
  @override
  MedicineEditorState build() {
    _repository = ref.watch(medicineRepositoryProvider);
    return const MedicineEditorState();
  }

  // Creates a medicine from a draft and refreshes local cache.
  Future<Medicine?> createMedicine(MedicineDraft draft) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final medicine = await _repository.createMedicine(draft);
      await _refreshCarerCache();
      state = state.copyWith(isSaving: false, clearError: true);
      return medicine;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to save this medicine right now.',
      );
      return null;
    }
  }

  // Updates an existing medicine and refreshes local cache.
  Future<bool> updateMedicine(Medicine medicine) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.updateMedicine(medicine);
      await _refreshCarerCache();
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to update this medicine right now.',
      );
      return false;
    }
  }

  // Archives a medicine and refreshes local cache.
  Future<bool> archiveMedicine(String medicineId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.archiveMedicine(medicineId);
      await _refreshCarerCache();
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to archive this medicine right now.',
      );
      return false;
    }
  }

  // Refreshes the primary carer data from local storage.
  Future<void> _refreshCarerCache() async {
    await ref.read(primaryCarerControllerProvider.notifier).refreshFromLocal();
    // Reconcile derived state before navigation resumes hidden consumers.
    ref.read(activeChildProvider);
  }
}

// Provides the medicine editor controller and state.
final medicineEditorControllerProvider =
    NotifierProvider<MedicineEditorController, MedicineEditorState>(
      MedicineEditorController.new,
    );
