import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_status.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/local_profile.dart';
import 'package:medicines_for_children_flutter/features/medicines/data/medicine_repository.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalMedicineRepository', () {
    late SharedPreferences preferences;
    late ProfileDataLocalDataSource profileData;
    late ActiveChildLocalDataSource activeChildStorage;
    late LocalMedicineRepository repository;

    const profileId = 'profile-1';
    final childOne = _child(
      id: 'child-1',
      medicines: [
        _medicine(id: 'med-1', name: 'Ibuprofen', dose: '5', doseUnit: 'ml'),
      ],
    );
    final childTwo = _child(
      id: 'child-2',
      medicines: [
        _medicine(id: 'med-2', name: 'Paracetamol', dose: '2', doseUnit: 'ml'),
      ],
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      profileData = ProfileDataLocalDataSource(preferences);
      activeChildStorage = ActiveChildLocalDataSource(preferences);
      repository = LocalMedicineRepository(
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

    test('createMedicine adds to the active child only', () async {
      await activeChildStorage.writeActiveChildId(profileId, childTwo.id);

      final created = await repository.createMedicine(
        const MedicineDraft(
          name: 'Amoxicillin',
          alias: 'Amox',
          type: MedicineType.everyday,
          dose: '7.5',
          doseUnit: 'ml',
          route: 'Oral',
          frequency: 'Twice daily',
        ),
      );

      final updated = profileData.readPrimaryCarer(profileId)!;
      final updatedChildOne = updated.children.firstWhere(
        (child) => child.id == childOne.id,
      );
      final updatedChildTwo = updated.children.firstWhere(
        (child) => child.id == childTwo.id,
      );

      expect(updatedChildOne.medicines, childOne.medicines);
      expect(updatedChildTwo.medicines.length, 2);
      expect(updatedChildTwo.medicines.last.name, 'Amoxicillin');
      expect(updatedChildTwo.medicines.last.dose, '7.5');
      expect(updatedChildTwo.medicines.last.doseUnit, 'ml');
      expect(updatedChildTwo.medicines.last.id, created.id);
    });

    test('updateMedicine preserves other medicines and children', () async {
      await activeChildStorage.writeActiveChildId(profileId, childOne.id);

      final updatedMedicine = childOne.medicines.first.copyWith(
        name: 'Ibuprofen updated',
        dose: '10',
        notes: 'After meals',
      );
      await repository.updateMedicine(updatedMedicine);

      final updated = profileData.readPrimaryCarer(profileId)!;
      final updatedChildOne = updated.children.firstWhere(
        (child) => child.id == childOne.id,
      );
      final updatedChildTwo = updated.children.firstWhere(
        (child) => child.id == childTwo.id,
      );

      expect(updatedChildTwo.medicines, childTwo.medicines);
      expect(updatedChildOne.medicines.length, 1);
      expect(updatedChildOne.medicines.first.name, 'Ibuprofen updated');
      expect(updatedChildOne.medicines.first.dose, '10');
      expect(updatedChildOne.medicines.first.notes, 'After meals');
    });

    test('archiveMedicine only changes status', () async {
      await activeChildStorage.writeActiveChildId(profileId, childOne.id);

      await repository.archiveMedicine('med-1');

      final updated = profileData.readPrimaryCarer(profileId)!;
      final updatedChildOne = updated.children.firstWhere(
        (child) => child.id == childOne.id,
      );

      final medicine = updatedChildOne.medicines.single;
      expect(medicine.status, MedicineStatus.noLongerUsed);
      expect(medicine.name, 'Ibuprofen');
      expect(medicine.dose, '5');
      expect(medicine.doseUnit, 'ml');
    });
  });
}

Child _child({required String id, required List<Medicine> medicines}) {
  return Child(
    id: id,
    firstName: 'Maya',
    lastName: 'Patel',
    dateOfBirth: DateTime(2018, 5, 12),
    condition: 'Asthma',
    allergies: const [],
    medicines: medicines,
    schedules: const [],
    asNeededSchedules: const [],
  );
}

Medicine _medicine({
  required String id,
  required String name,
  required String dose,
  required String doseUnit,
}) {
  return Medicine(
    id: id,
    name: name,
    alias: '',
    type: MedicineType.everyday,
    dose: dose,
    doseUnit: doseUnit,
    route: 'Oral',
    frequency: 'Twice daily',
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
