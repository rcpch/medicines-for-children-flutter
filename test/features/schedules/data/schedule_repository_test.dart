import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/schedules/data/schedule_repository.dart';
import 'package:medicines_for_children_flutter/features/schedules/domain/schedule_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalScheduleRepository', () {
    late SharedPreferences preferences;
    late ProfileDataLocalDataSource profileData;
    late ActiveChildLocalDataSource activeChildStorage;
    late LocalScheduleRepository repository;

    const profileId = 'profile-1';
    final scheduleOne = MedicineSchedule(
      id: 'sched-1',
      medicineId: 'med-1',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 7),
      times: const ['08:00'],
      weekdaysActive: const [true, true, true, true, true, true, true],
      administrations: [
        Administration(
          id: 'admin-1',
          dateTime: DateTime(2024, 1, 1, 8),
          status: AdministrationStatus.given,
          isAsNeeded: false,
        ),
      ],
    );
    final scheduleTwo = MedicineSchedule(
      id: 'sched-2',
      medicineId: 'med-2',
      startDate: DateTime(2024, 2, 1),
      endDate: DateTime(2024, 2, 7),
      times: const ['20:00'],
      weekdaysActive: const [true, true, true, true, true, true, true],
      administrations: const [],
    );
    final childOne = _child(id: 'child-1', schedules: [scheduleOne]);
    final childTwo = _child(id: 'child-2', schedules: [scheduleTwo]);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      profileData = ProfileDataLocalDataSource(preferences);
      activeChildStorage = ActiveChildLocalDataSource(preferences);
      repository = LocalScheduleRepository(
        authRepository: _FakeAuthRepository(profileId),
        profileData: profileData,
        activeChildStorage: activeChildStorage,
      );
      await profileData.writePrimaryCarer(
        profileId,
        PrimaryCarer(
          id: 'carer-1',
          firstName: 'Jamie',
          lastName: 'Patel',
          email: 'jamie@example.com',
          relationshipToChild: 'Parent',
          children: [childOne, childTwo],
        ),
      );
    });

    test('createSchedule adds to the active child only', () async {
      await activeChildStorage.writeActiveChildId(profileId, childTwo.id);

      final created = await repository.createSchedule(
        ScheduleDraft(
          medicineId: 'med-3',
          startDate: DateTime(2024, 3, 1),
          endDate: DateTime(2024, 3, 7),
          times: const ['09:00'],
          weekdaysActive: const [true, false, true, false, true, false, true],
        ),
      );

      final updated = profileData.readPrimaryCarer(profileId)!;
      final updatedChildOne = updated.children.firstWhere(
        (child) => child.id == childOne.id,
      );
      final updatedChildTwo = updated.children.firstWhere(
        (child) => child.id == childTwo.id,
      );

      expect(updatedChildOne.schedules, childOne.schedules);
      expect(updatedChildTwo.schedules.length, 2);
      expect(updatedChildTwo.schedules.last.id, created.id);
      expect(updatedChildTwo.schedules.last.medicineId, 'med-3');
    });

    test('updateSchedule preserves administrations', () async {
      await activeChildStorage.writeActiveChildId(profileId, childOne.id);

      final updatedSchedule = scheduleOne.copyWith(times: const ['07:30']);
      await repository.updateSchedule(updatedSchedule);

      final updated = profileData.readPrimaryCarer(profileId)!;
      final updatedChild = updated.children.firstWhere(
        (child) => child.id == childOne.id,
      );

      expect(updatedChild.schedules.length, 1);
      final saved = updatedChild.schedules.single;
      expect(saved.times, const ['07:30']);
      expect(saved.administrations, scheduleOne.administrations);
    });

    test('deleteSchedule removes only the matching schedule', () async {
      await activeChildStorage.writeActiveChildId(profileId, childTwo.id);

      await repository.deleteSchedule('sched-2');

      final updated = profileData.readPrimaryCarer(profileId)!;
      final updatedChildOne = updated.children.firstWhere(
        (child) => child.id == childOne.id,
      );
      final updatedChildTwo = updated.children.firstWhere(
        (child) => child.id == childTwo.id,
      );

      expect(updatedChildOne.schedules, childOne.schedules);
      expect(updatedChildTwo.schedules, isEmpty);
    });
  });
}

Child _child({required String id, required List<MedicineSchedule> schedules}) {
  return Child(
    id: id,
    firstName: 'Maya',
    lastName: 'Patel',
    dateOfBirth: DateTime(2018, 5, 12),
    condition: 'Asthma',
    allergies: const [],
    medicines: const [],
    schedules: schedules,
    asNeededSchedules: const [],
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.profileId);

  final String profileId;

  @override
  Stream<AuthStatus> statusStream() => const Stream.empty();

  @override
  Future<AuthUser?> currentUser() async {
    return AuthUser(uid: profileId, email: '', displayName: 'Test');
  }

  @override
  Future<List<LocalProfile>> listProfiles() async => const [];

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
  Future<bool> verifyPasscode(String passcode) async => false;

  @override
  Future<void> changePasscode({
    String? currentPasscode,
    required String newPasscode,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> completeOnboarding({required String displayName}) async {}
}
