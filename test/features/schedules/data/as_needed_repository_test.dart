import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/as_needed_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('records as-needed administration for a medicine', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileData = ProfileDataLocalDataSource(prefs);
    final activeChildStorage = ActiveChildLocalDataSource(prefs);
    const profileId = 'profile-1';

    final medicine = Medicine(
      id: 'med-1',
      name: 'Salbutamol',
      alias: 'Blue inhaler',
      type: MedicineType.asNeeded,
      dose: '2',
      doseUnit: 'puffs',
      route: 'inhaled',
      frequency: 'As needed',
    );

    final carer = PrimaryCarer(
      id: profileId,
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
          allergies: const [],
          medicines: [medicine],
          schedules: const [],
          asNeededSchedules: const [],
        ),
      ],
    );

    await profileData.writePrimaryCarer(profileId, carer);
    final repository = LocalAsNeededRepository(
      authRepository: _TestAuthRepository(
        AuthUser(
          uid: profileId,
          email: 'emma@example.com',
          displayName: 'Emma',
        ),
      ),
      profileData: profileData,
      activeChildStorage: activeChildStorage,
    );

    final current = DateTime.now();
    final now = DateTime(current.year, current.month, current.day, current.hour, current.minute);
    await repository.recordAdministration(
      medicineId: medicine.id,
      dateTime: now,
      notes: 'After PE',
    );

    final updated = profileData.readPrimaryCarer(profileId);
    expect(updated, isNotNull);
    expect(updated!.children.first.asNeededSchedules, hasLength(1));
    final schedule = updated.children.first.asNeededSchedules.first;
    expect(schedule.medicineId, medicine.id);
    expect(schedule.administrations, hasLength(1));
    expect(schedule.administrations.first.notes, 'After PE');
  });

  test('prunes old as-needed administrations on save', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileData = ProfileDataLocalDataSource(prefs);
    final activeChildStorage = ActiveChildLocalDataSource(prefs);
    const profileId = 'profile-2';

    final medicine = Medicine(
      id: 'med-2',
      name: 'Salbutamol',
      alias: 'Blue inhaler',
      type: MedicineType.asNeeded,
      dose: '2',
      doseUnit: 'puffs',
      route: 'inhaled',
      frequency: 'As needed',
    );

    final oldDate = DateTime.now().subtract(const Duration(days: 120));
    final recentDate = DateTime.now();

    final carer = PrimaryCarer(
      id: profileId,
      firstName: 'Morgan',
      lastName: 'Taylor',
      email: 'morgan@example.com',
      relationshipToChild: 'Dad',
      children: [
        Child(
          id: 'child-2',
          firstName: 'Ava',
          lastName: 'Taylor',
          dateOfBirth: DateTime(2018, 5, 12),
          condition: 'Asthma',
          allergies: const [],
          medicines: [medicine],
          schedules: const [],
          asNeededSchedules: [
            AsNeededSchedule(
              id: 'asneeded-${medicine.id}',
              medicineId: medicine.id,
              administrations: [
                Administration(
                  id: 'admin-old',
                  dateTime: oldDate,
                  status: AdministrationStatus.given,
                  isAsNeeded: true,
                  administeredBy: 'Tester',
                  notes: null,
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await profileData.writePrimaryCarer(profileId, carer);
    final repository = LocalAsNeededRepository(
      authRepository: _TestAuthRepository(
        AuthUser(
          uid: profileId,
          email: 'morgan@example.com',
          displayName: 'Morgan',
        ),
      ),
      profileData: profileData,
      activeChildStorage: activeChildStorage,
    );

    await repository.recordAdministration(
      medicineId: medicine.id,
      dateTime: recentDate,
      notes: null,
    );

    final updated = profileData.readPrimaryCarer(profileId);
    final schedule = updated!.children.first.asNeededSchedules.first;
    expect(schedule.administrations.length, 1);
    expect(schedule.administrations.first.dateTime, recentDate);
  });

  test('records as-needed administration for the selected child', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileData = ProfileDataLocalDataSource(prefs);
    final activeChildStorage = ActiveChildLocalDataSource(prefs);
    const profileId = 'profile-3';

    final medicine = Medicine(
      id: 'med-3',
      name: 'Cetirizine',
      alias: 'Antihistamine',
      type: MedicineType.asNeeded,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'As needed',
    );

    final carer = PrimaryCarer(
      id: profileId,
      firstName: 'Jamie',
      lastName: 'Lee',
      email: 'jamie@example.com',
      relationshipToChild: 'Parent',
      children: [
        Child(
          id: 'child-3a',
          firstName: 'Kai',
          lastName: 'Lee',
          dateOfBirth: DateTime(2017, 3, 9),
          condition: 'Allergies',
          allergies: const [],
          medicines: [medicine],
          schedules: const [],
          asNeededSchedules: const [],
        ),
        Child(
          id: 'child-3b',
          firstName: 'Noa',
          lastName: 'Lee',
          dateOfBirth: DateTime(2019, 7, 18),
          condition: 'Allergies',
          allergies: const [],
          medicines: [medicine],
          schedules: const [],
          asNeededSchedules: const [],
        ),
      ],
    );

    await profileData.writePrimaryCarer(profileId, carer);
    await activeChildStorage.writeActiveChildId(profileId, 'child-3b');
    final repository = LocalAsNeededRepository(
      authRepository: _TestAuthRepository(
        AuthUser(
          uid: profileId,
          email: 'jamie@example.com',
          displayName: 'Jamie',
        ),
      ),
      profileData: profileData,
      activeChildStorage: activeChildStorage,
    );

    await repository.recordAdministration(
      medicineId: medicine.id,
      dateTime: DateTime(2024, 2, 10, 10, 0),
      notes: 'After lunch',
    );

    final updated = profileData.readPrimaryCarer(profileId);
    expect(updated, isNotNull);
    expect(updated!.children.first.asNeededSchedules, isEmpty);
    expect(updated.children.last.asNeededSchedules, hasLength(1));
    expect(updated.children.last.asNeededSchedules.first.medicineId, medicine.id);
  });
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
