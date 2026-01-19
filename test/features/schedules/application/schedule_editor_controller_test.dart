import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:medicines_for_children_flutter/features/schedules/application/schedule_editor_controller.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/schedule_repository.dart';
import 'package:medicines_for_children_flutter/features/schedules/domain/schedule_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('createSchedule succeeds even if notifications fail', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        scheduleRepositoryProvider.overrideWithValue(_FakeScheduleRepository()),
        notificationServiceProvider.overrideWithValue(
          _FailingNotificationService(NotificationStore(prefs)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      scheduleEditorControllerProvider.notifier,
    );
    const medicine = Medicine(
      id: 'med-1',
      name: 'Ibuprofen',
      alias: '',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'Twice daily',
    );
    final draft = ScheduleDraft(
      medicineId: medicine.id,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 7),
      times: const ['08:00'],
      weekdaysActive: List<bool>.filled(7, true),
    );

    final schedule = await controller.createSchedule(
      draft: draft,
      medicine: medicine,
      enableNotifications: true,
    );

    final state = container.read(scheduleEditorControllerProvider);
    expect(schedule, isNotNull);
    expect(state.errorMessage, isNull);
  });
}

class _FakeScheduleRepository implements ScheduleRepository {
  @override
  Future<MedicineSchedule> createSchedule(ScheduleDraft draft) async {
    return MedicineSchedule(
      id: 'sched-1',
      medicineId: draft.medicineId,
      startDate: draft.startDate,
      endDate: draft.endDate,
      times: draft.times,
      weekdaysActive: draft.weekdaysActive,
      administrations: const [],
    );
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {}

  @override
  Future<void> updateSchedule(MedicineSchedule schedule) async {}
}

class _FailingNotificationService extends NotificationService {
  _FailingNotificationService(super.store);

  @override
  Future<void> scheduleForSchedule({
    required MedicineSchedule schedule,
    required Medicine medicine,
  }) async {
    throw StateError('Notifications unavailable');
  }

  @override
  Future<void> cancelForSchedule(String scheduleId) async {
    throw StateError('Notifications unavailable');
  }
}
