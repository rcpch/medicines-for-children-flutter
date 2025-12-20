import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medicines_for_children_flutter/app/app.dart';
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
import 'package:medicines_for_children_flutter/features/user_guide/domain/user_guide_content.dart';

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
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigate user guide sections', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final profilesStore = LocalProfilesLocalDataSource(prefs);
    final profile = LocalProfile(
      id: 'profile-guide',
      name: 'Guide Family',
      displayName: 'Guide Carer',
      createdAt: DateTime(2024, 1, 1),
      hasPasscode: false,
    );
    await profilesStore.writeProfiles([profile]);
    await profilesStore.writeActiveProfileId(profile.id);

    final profileData = ProfileDataLocalDataSource(prefs);
    final child = Child(
      id: 'child-guide',
      firstName: 'Guide',
      lastName: 'Child',
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
      firstName: 'Guide',
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

    await tester.tap(find.text('Guide'));
    await tester.pumpAndSettle();

    for (final section in userGuideSections) {
      final sectionFinder = find.byKey(ValueKey('guide-section-${section.id}'));
      await tester.scrollUntilVisible(
        sectionFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(sectionFinder);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(section.title)),
        findsOneWidget,
      );
      expect(find.text('Step-by-step guidance'), findsOneWidget);
      expect(find.text(section.steps.first), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
