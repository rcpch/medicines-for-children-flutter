// Controller for schedule create/edit.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/settings/settings_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/schedule_repository.dart';
import 'package:medicines_for_children_flutter/features/schedules/domain/schedule_draft.dart';

// Holds UI state for schedule save/edit operations.
class ScheduleEditorState {
  const ScheduleEditorState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  // Creates a new state with selective field overrides.
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

// Coordinates schedule CRUD operations and notifications.
class ScheduleEditorController extends Notifier<ScheduleEditorState> {
  late ScheduleRepository _repository;
  late NotificationService _notifications;

  @override
  // Wires up dependencies and initializes default state.
  ScheduleEditorState build() {
    _repository = ref.watch(scheduleRepositoryProvider);
    _notifications = ref.watch(notificationServiceProvider);
    return const ScheduleEditorState();
  }

  // Creates a schedule and optionally schedules notifications.
  Future<MedicineSchedule?> createSchedule({
    required ScheduleDraft draft,
    required Medicine medicine,
    required bool enableNotifications,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.createSchedule(draft);
      final settings = ref.read(settingsControllerProvider);
      if (enableNotifications && settings.notificationsEnabled) {
        try {
          await _notifications.scheduleForSchedule(
            schedule: schedule,
            medicine: medicine,
          );
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

  // Updates a schedule and refreshes related notifications.
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
      final settings = ref.read(settingsControllerProvider);
      if (enableNotifications && settings.notificationsEnabled) {
        try {
          await _notifications.scheduleForSchedule(
            schedule: schedule,
            medicine: medicine,
          );
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

  // Deletes a schedule and cancels any notifications.
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

  // Reloads cached carer data after schedule changes.
  Future<void> _refreshCarerCache() async {
    await ref.read(primaryCarerControllerProvider.notifier).refreshFromLocal();
  }
}

// Provides access to the schedule editor controller.
final scheduleEditorControllerProvider =
    NotifierProvider<ScheduleEditorController, ScheduleEditorState>(
      ScheduleEditorController.new,
    );
