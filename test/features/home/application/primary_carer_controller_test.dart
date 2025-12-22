import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/application/auth_controller.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/data/primary_carer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrimaryCarerController', () {
    late ProviderContainer container;
    late TestPrimaryCarerRepository repository;
    late SharedPreferences preferences;
    const profileId = 'profile-1';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      repository = TestPrimaryCarerRepository(samplePrimaryCarer());
      container = ProviderContainer(
        overrides: [
          primaryCarerRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(
            TestAuthRepository(
              user: const AuthUser(
                uid: profileId,
                email: 'emma@example.com',
                displayName: 'Emma Taylor',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test('hydrates state from cached data on startup', () async {
      final sample = samplePrimaryCarer();
      final profileData = ProfileDataLocalDataSource(preferences);
      await profileData.writePrimaryCarer(profileId, sample);

      final hydratedContainer = ProviderContainer(
        overrides: [
          primaryCarerRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(
            TestAuthRepository(
              user: const AuthUser(
                uid: profileId,
                email: 'emma@example.com',
                displayName: 'Emma Taylor',
              ),
            ),
          ),
        ],
      );
      addTearDown(hydratedContainer.dispose);

      await _awaitAuthenticated(hydratedContainer);
      final state = hydratedContainer.read(primaryCarerControllerProvider);
      expect(state.carer, isNotNull);
      expect(state.carer!.firstName, sample.firstName);
      expect(state.isStale, isTrue);
    });

    test('refresh fetches latest data and caches it', () async {
      final controller =
          container.read(primaryCarerControllerProvider.notifier);

      await _awaitAuthenticated(container);
      await controller.refresh();
      final state = container.read(primaryCarerControllerProvider);

      expect(state.carer, isNotNull);
      expect(state.isLoading, isFalse);
      expect(state.isStale, isFalse);
      final profileData = ProfileDataLocalDataSource(preferences);
      final cachedCarer = profileData.readPrimaryCarer(profileId);
      expect(cachedCarer, isNotNull);
    });

    test('clear removes cache and resets state', () async {
      final controller =
          container.read(primaryCarerControllerProvider.notifier);
      await _awaitAuthenticated(container);
      await controller.refresh();

      await controller.clear();
      final state = container.read(primaryCarerControllerProvider);
      expect(state.carer, isNull);
      final profileData = ProfileDataLocalDataSource(preferences);
      expect(profileData.readPrimaryCarer(profileId), isNull);
    });

    test('addChild appends child and selects it', () async {
      final controller =
          container.read(primaryCarerControllerProvider.notifier);
      await _awaitAuthenticated(container);
      await controller.refresh();

      final child = Child(
        id: 'child-2',
        firstName: 'Leo',
        lastName: 'Taylor',
        dateOfBirth: DateTime(2020, 6, 10),
        condition: 'Diabetes',
        allergies: const [],
        notes: null,
        medicines: const [],
        schedules: const [],
        asNeededSchedules: const [],
      );

      final success = await controller.addChild(child);
      expect(success, isTrue);
      final state = container.read(primaryCarerControllerProvider);
      expect(state.carer?.children.length, 2);

      final profileData = ProfileDataLocalDataSource(preferences);
      final cachedCarer = profileData.readPrimaryCarer(profileId);
      expect(cachedCarer?.children.length, 2);

      final activeChildStorage = ActiveChildLocalDataSource(preferences);
      expect(activeChildStorage.readActiveChildId(profileId), 'child-2');
    });
  });
}

Future<void> _awaitAuthenticated(ProviderContainer container) async {
  final controller = container.read(authControllerProvider.notifier);
  await controller.stream.firstWhere((state) => state.status == AuthStatus.authenticated);
}

PrimaryCarer samplePrimaryCarer() {
  final medicine = Medicine(
    id: 'med-1',
    name: 'Amoxicillin',
    alias: 'Amoxil',
    type: MedicineType.everyday,
    dose: '5',
    doseUnit: 'ml',
    route: 'oral',
    frequency: 'Twice daily',
    notes: 'Give after meals',
  );

  final child = Child(
    id: 'child-1',
    firstName: 'Ava',
    lastName: 'Taylor',
    dateOfBirth: DateTime(2018, 5, 12),
    condition: 'Asthma',
    allergies: const ['Penicillin'],
    notes: 'Requires spacer for inhaler.',
    medicines: [medicine],
    schedules: [
      MedicineSchedule(
        id: 'sched-1',
        medicineId: medicine.id,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        times: const ['08:00', '20:00'],
        weekdaysActive: List<bool>.filled(7, true),
        administrations: const [],
      ),
    ],
    asNeededSchedules: const [],
  );

  return PrimaryCarer(
    id: 'pc-1',
    firstName: 'Emma',
    lastName: 'Taylor',
    email: 'emma@example.com',
    relationshipToChild: 'Mum',
    children: [child],
  );
}

class TestAuthRepository implements AuthRepository {
  TestAuthRepository({required this.user});

  final AuthUser user;

  @override
  Stream<AuthStatus> statusStream() async* {
    yield AuthStatus.authenticated;
  }

  @override
  Future<AuthUser?> currentUser() async {
    return user;
  }

  @override
  Future<List<LocalProfile>> listProfiles() async {
    return [
      LocalProfile(
        id: user.uid,
        name: 'Test profile',
        displayName: user.displayName ?? '',
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
  Future<bool> verifyPasscode(String passcode) async {
    return true;
  }

  @override
  Future<void> changePasscode({String? currentPasscode, required String newPasscode}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> completeOnboarding({required String displayName}) async {}
}

class TestPrimaryCarerRepository implements PrimaryCarerRepository {
  TestPrimaryCarerRepository(this._carer);

  final PrimaryCarer _carer;
  bool shouldThrow = false;

  @override
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    if (shouldThrow) {
      throw Exception('error');
    }
    return _carer;
  }
}
