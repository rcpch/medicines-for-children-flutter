import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';
import 'package:medicines_for_children_flutter/features/medicines/application/medicine_editor_controller.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';
import 'package:medicines_for_children_flutter/features/medicines/presentation/medicines_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('filters medicines by type', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final carer = _sampleCarer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          primaryCarerStateProvider.overrideWithValue(
            PrimaryCarerState(carer: carer),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: MedicinesPage()),
      ),
    );

    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Daily Vitamin'), findsOneWidget);
    expect(find.text('Salbutamol'), findsNothing);

    await tester.tap(find.text('As-needed'));
    await tester.pumpAndSettle();

    expect(find.text('Amoxicillin'), findsNothing);
    expect(find.text('Daily Vitamin'), findsOneWidget);
    expect(find.text('Salbutamol'), findsOneWidget);
  });

  testWidgets('shows newly added medicine without re-login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileId = 'profile-2';
    final carer = _sampleCarer();
    await _writeCarer(prefs, profileId, carer);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(
          _TestAuthRepository(
            AuthUser(
              uid: profileId,
              email: 'emma@example.com',
              displayName: 'Emma',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _awaitAuthenticated(container);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MedicinesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Cetirizine'), findsNothing);

    final editor = container.read(medicineEditorControllerProvider.notifier);
    await editor.createMedicine(
      const MedicineDraft(
        name: 'Cetirizine',
        alias: 'Antihistamine',
        type: MedicineType.everyday,
        dose: '5',
        doseUnit: 'ml',
        route: 'oral',
        frequency: 'Once daily',
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Cetirizine'), findsOneWidget);
  });
}

PrimaryCarer _sampleCarer() {
  return PrimaryCarer(
    id: 'carer-1',
    firstName: 'Emma',
    lastName: 'Taylor',
    email: 'emma@example.com',
    relationshipToChild: 'Mum',
    children: [
      Child(
        id: 'child-1',
        firstName: 'Ava',
        lastName: 'Taylor',
        dateOfBirth: DateTime(2018, 5, 12),
        condition: 'Asthma',
        allergies: const ['Penicillin'],
        notes: 'Uses spacer with inhaler.',
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
          Medicine(
            id: 'med-2',
            name: 'Salbutamol',
            alias: 'Blue inhaler',
            type: MedicineType.asNeeded,
            dose: '2',
            doseUnit: 'puffs',
            route: 'inhaled',
            frequency: 'As needed',
          ),
          Medicine(
            id: 'med-3',
            name: 'Daily Vitamin',
            alias: 'Vitamin D',
            type: MedicineType.both,
            dose: '1',
            doseUnit: 'tablet',
            route: 'oral',
            frequency: 'Daily',
          ),
        ],
        schedules: const [],
        asNeededSchedules: const [],
      ),
    ],
  );
}

Future<void> _writeCarer(SharedPreferences prefs, String profileId, PrimaryCarer carer) async {
  final data = ProfileDataLocalDataSource(prefs);
  await data.writePrimaryCarer(profileId, carer);
}

Future<void> _awaitAuthenticated(ProviderContainer container) async {
  final controller = container.read(authControllerProvider.notifier);
  await controller.stream.firstWhere((state) => state.status == AuthStatus.authenticated);
}

class _TestAuthRepository implements AuthRepository {
  _TestAuthRepository(this._user);

  final AuthUser _user;

  @override
  Stream<AuthStatus> statusStream() async* {
    yield AuthStatus.authenticated;
  }

  @override
  Future<AuthUser?> currentUser() async {
    return _user;
  }

  @override
  Future<List<LocalProfile>> listProfiles() async {
    return [
      LocalProfile(
        id: _user.uid,
        name: 'Profile',
        displayName: _user.displayName ?? '',
        createdAt: DateTime(2024, 1, 1),
        hasPasscode: false,
      ),
    ];
  }

  @override
  Future<LocalProfile> createProfile({required String name, String? passcode}) {
    throw UnimplementedError();
  }

  @override
  Future<void> selectProfile(String profileId) async {}

  @override
  Future<void> unlockWithPasscode(String passcode) async {}

  @override
  Future<void> unlockWithBiometrics() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> completeOnboarding({required String displayName}) async {}
}
