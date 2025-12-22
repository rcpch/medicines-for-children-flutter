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
import 'package:medicines_for_children_flutter/features/auth/data/local_profiles_local_data_source.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create medicine and schedule', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final profilesStore = LocalProfilesLocalDataSource(prefs);
    final profile = LocalProfile(
      id: 'profile-1',
      name: 'Family',
      displayName: 'Alex Carer',
      createdAt: DateTime(2024, 1, 1),
      hasPasscode: false,
    );
    await profilesStore.writeProfiles([profile]);
    await profilesStore.writeActiveProfileId(profile.id);

    final profileData = ProfileDataLocalDataSource(prefs);
    final child = Child(
      id: 'child-1',
      firstName: 'Ava',
      lastName: 'Taylor',
      dateOfBirth: DateTime(2018, 5, 12),
      condition: 'Asthma',
      allergies: const [],
      notes: null,
      medicines: const [],
      schedules: const [],
      asNeededSchedules: const [],
    );
    final carer = PrimaryCarer(
      id: profile.id,
      firstName: 'Alex',
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
        ],
        child: const MedicinesApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MedicinesApp)),
    );

    await tester.tap(find.text('Medicines'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add medicine'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(7));
    await tester.enterText(fields.at(0), 'Amoxicillin');
    await tester.enterText(fields.at(2), '5');
    await tester.enterText(fields.at(3), 'ml');
    await tester.enterText(fields.at(4), 'oral');
    await tester.enterText(fields.at(5), 'Twice daily');

    final addMedicineButton = find.widgetWithText(ElevatedButton, 'Add medicine').first;
    await tester.scrollUntilVisible(
      addMedicineButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addMedicineButton);
    await tester.pumpAndSettle();

    final updatedCarer = profileData.readPrimaryCarer(profile.id);
    expect(updatedCarer, isNotNull);
    expect(updatedCarer!.children.first.medicines.length, 1);
    expect(updatedCarer.children.first.medicines.first.name, 'Amoxicillin');

    await container.read(primaryCarerControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();

    final router = container.read(appRouterProvider);
    router.goNamed(AppRoute.addSchedule.name);
    await tester.pumpAndSettle();

    final reminderLabel = find.text('Enable reminders');
    await tester.scrollUntilVisible(
      reminderLabel,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(reminderLabel);
    await tester.pumpAndSettle();

    final addScheduleButton = find.widgetWithText(ElevatedButton, 'Add schedule').first;
    await tester.scrollUntilVisible(
      addScheduleButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addScheduleButton);
    await tester.pumpAndSettle();

    await container.read(primaryCarerControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();

    router.goNamed(AppRoute.schedules.name);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final afterScheduleCarer = profileData.readPrimaryCarer(profile.id);
    expect(afterScheduleCarer, isNotNull);
    expect(afterScheduleCarer!.children.first.schedules.length, 1);
    expect(find.text('Amoxicillin'), findsOneWidget);
  });
}
