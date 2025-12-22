import 'package:flutter_test/flutter_test.dart';
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
import 'package:medicines_for_children_flutter/features/home/data/administration_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('records and clears scheduled administration', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileData = ProfileDataLocalDataSource(prefs);
    const profileId = 'profile-1';

    final medicine = Medicine(
      id: 'med-1',
      name: 'Amoxicillin',
      alias: 'Amoxil',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'Twice daily',
    );

    final schedule = MedicineSchedule(
      id: 'sched-1',
      medicineId: medicine.id,
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      times: const ['08:00'],
      weekdaysActive: List<bool>.filled(7, true),
      administrations: const [],
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
          schedules: [schedule],
          asNeededSchedules: const [],
        ),
      ],
    );

    await profileData.writePrimaryCarer(profileId, carer);
    final repository = LocalAdministrationRepository(
      authRepository: _TestAuthRepository(
        AuthUser(
          uid: profileId,
          email: 'emma@example.com',
          displayName: 'Emma',
        ),
      ),
      profileData: profileData,
    );

    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, 8);
    await repository.recordScheduledAdministration(
      scheduleId: schedule.id,
      dateTime: date,
      status: AdministrationStatus.given,
    );

    final updated = profileData.readPrimaryCarer(profileId);
    final updatedSchedule = updated!.children.first.schedules.first;
    expect(updatedSchedule.administrations, hasLength(1));
    expect(updatedSchedule.administrations.first.status, AdministrationStatus.given);

    await repository.clearScheduledAdministration(
      scheduleId: schedule.id,
      dateTime: date,
    );
    final cleared = profileData.readPrimaryCarer(profileId);
    final clearedSchedule = cleared!.children.first.schedules.first;
    expect(clearedSchedule.administrations, isEmpty);
  });

  test('prunes old scheduled administrations on save', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final profileData = ProfileDataLocalDataSource(prefs);
    const profileId = 'profile-2';

    final medicine = Medicine(
      id: 'med-2',
      name: 'Ibuprofen',
      alias: '',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'Twice daily',
    );

    final oldDate = DateTime.now().subtract(const Duration(days: 120));
    final recentDate = DateTime.now();

    final schedule = MedicineSchedule(
      id: 'sched-2',
      medicineId: medicine.id,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2026, 1, 1),
      times: const ['08:00'],
      weekdaysActive: List<bool>.filled(7, true),
      administrations: [
        Administration(
          id: 'admin-old',
          dateTime: oldDate,
          status: AdministrationStatus.given,
          isAsNeeded: false,
          administeredBy: 'Tester',
          notes: null,
        ),
      ],
    );

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
          schedules: [schedule],
          asNeededSchedules: const [],
        ),
      ],
    );

    await profileData.writePrimaryCarer(profileId, carer);
    final repository = LocalAdministrationRepository(
      authRepository: _TestAuthRepository(
        AuthUser(
          uid: profileId,
          email: 'morgan@example.com',
          displayName: 'Morgan',
        ),
      ),
      profileData: profileData,
    );

    await repository.recordScheduledAdministration(
      scheduleId: schedule.id,
      dateTime: recentDate,
      status: AdministrationStatus.given,
    );

    final updated = profileData.readPrimaryCarer(profileId);
    final updatedSchedule = updated!.children.first.schedules.first;
    expect(updatedSchedule.administrations.length, 1);
    expect(updatedSchedule.administrations.first.dateTime, recentDate);
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
