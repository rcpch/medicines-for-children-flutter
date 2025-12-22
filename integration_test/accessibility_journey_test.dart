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
import 'package:medicines_for_children_flutter/core/notifications/notification_service.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/auth/data/local_profiles_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNotificationService implements NotificationService {
  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> scheduleForSchedule({
    required MedicineSchedule schedule,
    required Medicine medicine,
  }) async {}

  @override
  Future<void> cancelForSchedule(String scheduleId) async {}

  @override
  Future<void> pruneExpired() async {}

  @override
  Future<void> cancelAll() async {}
}

class NoopTelemetryService implements TelemetryService {
  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {}

  @override
  void trackScreen(String name, {Map<String, Object?>? properties}) {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('accessibility labels present for schedule dates', (tester) async {
    final originalOnError = FlutterError.onError;
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final profilesStore = LocalProfilesLocalDataSource(prefs);
    final profile = LocalProfile(
      id: 'profile-1',
      name: 'Family',
      displayName: 'Taylor',
      createdAt: DateTime(2024, 1, 1),
      hasPasscode: false,
    );
    await profilesStore.writeProfiles([profile]);
    await profilesStore.writeActiveProfileId(profile.id);

    final profileData = ProfileDataLocalDataSource(prefs);
    final now = DateTime.now();
    final child = Child(
      id: 'child-1',
      firstName: 'Ava',
      lastName: 'Taylor',
      dateOfBirth: DateTime(2018, 5, 12),
      condition: 'Asthma',
      allergies: const [],
      notes: null,
      medicines: [
        Medicine(
          id: 'med-1',
          name: 'Amoxicillin',
          alias: 'Amoxil',
          type: MedicineType.everyday,
          dose: '5',
          doseUnit: 'ml',
          route: 'oral',
          frequency: 'Twice daily',
        ),
      ],
      schedules: [
        MedicineSchedule(
          id: 'schedule-1',
          medicineId: 'med-1',
          startDate: now.subtract(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 1)),
          times: const ['08:00'],
          weekdaysActive: List<bool>.filled(7, true),
          administrations: const [],
        ),
      ],
      asNeededSchedules: const [],
    );
    final carer = PrimaryCarer(
      id: profile.id,
      firstName: 'Jordan',
      lastName: 'Carer',
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
          telemetryServiceProvider.overrideWithValue(NoopTelemetryService()),
        ],
        child: const MedicinesApp(),
      ),
    );
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;

    final container = ProviderScope.containerOf(tester.element(find.byType(MedicinesApp)));
    final router = container.read(appRouterProvider);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics &&
            widget.properties.label?.contains('Scheduled Amoxicillin') == true,
      ),
      findsWidgets,
    );

    router.goNamed(AppRoute.addSchedule.name);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics &&
            widget.properties.label?.contains('Start date.') == true,
      ),
      findsWidgets,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics &&
            widget.properties.label?.contains('End date.') == true,
      ),
      findsWidgets,
    );

    semantics.dispose();
  });
}
