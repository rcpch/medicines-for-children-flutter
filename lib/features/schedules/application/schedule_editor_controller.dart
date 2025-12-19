import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/schedule_repository.dart';
import 'package:medicines_for_children_flutter/features/schedules/domain/schedule_draft.dart';

class ScheduleEditorState {
  const ScheduleEditorState({
    this.isSaving = false,
    this.errorMessage,
  });

  final bool isSaving;
  final String? errorMessage;

  ScheduleEditorState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScheduleEditorState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ScheduleEditorController extends StateNotifier<ScheduleEditorState> {
  ScheduleEditorController(this._repository) : super(const ScheduleEditorState());

  final ScheduleRepository _repository;

  Future<MedicineSchedule?> createSchedule(ScheduleDraft draft) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.createSchedule(draft);
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to save this schedule right now.',
      );
      return null;
    }
  }

  Future<bool> updateSchedule(MedicineSchedule schedule) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.updateSchedule(schedule);
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to update this schedule right now.',
      );
      return false;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.deleteSchedule(scheduleId);
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to delete this schedule right now.',
      );
      return false;
    }
  }
}

final scheduleEditorControllerProvider =
    StateNotifierProvider<ScheduleEditorController, ScheduleEditorState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleEditorController(repository);
});
