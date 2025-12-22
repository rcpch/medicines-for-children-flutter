import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medicines_for_children_flutter/app/app.dart';
import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_schedule_calculator.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/notifications/notification_store.dart';
import 'package:medicines_for_children_flutter/features/auth/data/local_profiles_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingNotificationService implements NotificationService {
  RecordingNotificationService(this._store)
      : _calculator = const NotificationScheduleCalculator();

  final NotificationStore _store;
  final NotificationScheduleCalculator _calculator;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> scheduleForSchedule({
    required MedicineSchedule schedule,
    required Medicine medicine,
  }) async {
    final ids = <int>[];
    for (final time in schedule.times) {
      final candidate = _calculator.nextInstance(
        startDate: schedule.startDate,
        timeString: time,
        now: DateTime.now(),
      );
      if (candidate == null) {
        continue;
      }
      ids.add(_calculator.notificationId(schedule.id, time));
    }
    if (ids.isNotEmpty) {
      await _store.writeForSchedule(
        schedule.id,
        NotificationMetadata(notificationIds: ids, endDate: schedule.endDate),
      );
    }
  }

  @override
  Future<void> cancelForSchedule(String scheduleId) async {
    await _store.removeSchedule(scheduleId);
  }

  @override
  Future<void> pruneExpired() async {}

  @override
  Future<void> cancelAll() async {
    await _store.clearAll();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('schedule creation stores notification metadata', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final profilesStore = LocalProfilesLocalDataSource(prefs);
    final profile = LocalProfile(
      id: 'profile-2',
      name: 'Family',
      displayName: 'Taylor Family',
      createdAt: DateTime(2024, 1, 1),
      hasPasscode: false,
    );
    await profilesStore.writeProfiles([profile]);
    await profilesStore.writeActiveProfileId(profile.id);

    final profileData = ProfileDataLocalDataSource(prefs);
    final medicine = Medicine(
      id: 'med-1',
      name: 'Amoxicillin',
      alias: '',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'Daily',
    );
    final child = Child(
      id: 'child-1',
      firstName: 'Ava',
      lastName: 'Taylor',
      dateOfBirth: DateTime(2018, 5, 12),
      condition: 'Asthma',
      allergies: const [],
      notes: null,
      medicines: [medicine],
      schedules: const [],
      asNeededSchedules: const [],
    );
    final carer = PrimaryCarer(
      id: profile.id,
      firstName: 'Alex',
      lastName: 'Taylor',
      email: '',
      relationshipToChild: 'Parent',
      children: [child],
    );
    await profileData.writePrimaryCarer(profile.id, carer);

    const config = AppConfig(
      environment: AppEnvironment.dev,
      sharedScheduleApiBaseUrl: '',
      sharedScheduleApiKey: '',
    );

    final store = NotificationStore(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(RecordingNotificationService(store)),
        ],
        child: const MedicinesApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(MedicinesApp)));
    final router = container.read(appRouterProvider);

    router.goNamed(AppRoute.addSchedule.name);
    await tester.pumpAndSettle();

    final addScheduleButton = find.widgetWithText(ElevatedButton, 'Add schedule').first;
    await tester.scrollUntilVisible(
      addScheduleButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addScheduleButton);
    await tester.pumpAndSettle();

    final updatedCarer = profileData.readPrimaryCarer(profile.id);
    expect(updatedCarer, isNotNull);
    final schedule = updatedCarer!.children.first.schedules.first;

    final metadata = await store.readForSchedule(schedule.id);
    expect(metadata, isNotNull);
    expect(metadata!.notificationIds.isNotEmpty, isTrue);
    expect(metadata.endDate, schedule.endDate);
  });
}
