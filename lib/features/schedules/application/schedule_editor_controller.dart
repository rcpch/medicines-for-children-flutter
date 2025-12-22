import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
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
  ScheduleEditorController(this._ref, this._repository, this._notifications)
      : super(const ScheduleEditorState());

  final Ref _ref;
  final ScheduleRepository _repository;
  final NotificationService _notifications;

  Future<MedicineSchedule?> createSchedule({
    required ScheduleDraft draft,
    required Medicine medicine,
    required bool enableNotifications,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.createSchedule(draft);
      final settings = _ref.read(settingsControllerProvider);
      if (enableNotifications && settings.notificationsEnabled) {
        try {
          await _notifications.scheduleForSchedule(schedule: schedule, medicine: medicine);
        } catch (_) {
          // Scheduling failures should not block saving the schedule.
        }
      }
      await _refreshCarerCache();
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

  Future<bool> updateSchedule({
    required MedicineSchedule schedule,
    required Medicine medicine,
    required bool enableNotifications,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.updateSchedule(schedule);
      try {
        await _notifications.cancelForSchedule(schedule.id);
      } catch (_) {
        // Ignore notification failures so edits still succeed.
      }
      final settings = _ref.read(settingsControllerProvider);
      if (enableNotifications && settings.notificationsEnabled) {
        try {
          await _notifications.scheduleForSchedule(schedule: schedule, medicine: medicine);
        } catch (_) {
          // Scheduling failures should not block saving the schedule.
        }
      }
      await _refreshCarerCache();
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
      try {
        await _notifications.cancelForSchedule(scheduleId);
      } catch (_) {
        // Ignore notification failures so deletes still succeed.
      }
      await _refreshCarerCache();
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

  Future<void> _refreshCarerCache() async {
    await _ref.read(primaryCarerControllerProvider.notifier).refreshFromLocal();
  }
}

final scheduleEditorControllerProvider =
    StateNotifierProvider<ScheduleEditorController, ScheduleEditorState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return ScheduleEditorController(ref, repository, notifications);
});
