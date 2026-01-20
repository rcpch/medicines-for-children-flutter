// Controller for creating/editing medicines.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/medicines/data/medicine_repository.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';

class MedicineEditorState {
  const MedicineEditorState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

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

class MedicineEditorController extends Notifier<MedicineEditorState> {
  late MedicineRepository _repository;

  @override
  MedicineEditorState build() {
    _repository = ref.watch(medicineRepositoryProvider);
    return const MedicineEditorState();
  }

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

  Future<void> _refreshCarerCache() async {
    await ref.read(primaryCarerControllerProvider.notifier).refreshFromLocal();
  }
}

final medicineEditorControllerProvider =
    NotifierProvider<MedicineEditorController, MedicineEditorState>(
      MedicineEditorController.new,
    );
