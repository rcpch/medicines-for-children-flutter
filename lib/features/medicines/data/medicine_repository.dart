import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';

abstract class MedicineRepository {
  Future<Medicine> createMedicine(MedicineDraft draft);
  Future<void> updateMedicine(Medicine medicine);
  Future<void> archiveMedicine(String medicineId);
}

class LocalMedicineRepository implements MedicineRepository {
  LocalMedicineRepository({
    required this.authRepository,
    required this.profileData,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  @override
  Future<Medicine> createMedicine(MedicineDraft draft) async {
    final context = await _loadContext();
    final medicine = Medicine(
      id: _generateId(),
      name: draft.name,
      alias: draft.alias,
      type: draft.type,
      dose: draft.dose,
      doseUnit: draft.doseUnit,
      route: draft.route,
      frequency: draft.frequency,
      status: draft.status,
      notes: draft.notes,
      photoUrl: draft.photoUrl,
      photoUrls: draft.photoUrls,
    );

    final updatedChild = context.child.copyWith(
      medicines: [...context.child.medicines, medicine],
    );
    await _saveChild(context, updatedChild);
    return medicine;
  }

  @override
  Future<void> updateMedicine(Medicine medicine) async {
    final context = await _loadContext();
    final updatedMedicines = context.child.medicines
        .map((item) => item.id == medicine.id ? medicine : item)
        .toList();
    final updatedChild = context.child.copyWith(medicines: updatedMedicines);
    await _saveChild(context, updatedChild);
  }

  @override
  Future<void> archiveMedicine(String medicineId) async {
    final context = await _loadContext();
    final updatedMedicines = context.child.medicines.map((medicine) {
      if (medicine.id != medicineId) {
        return medicine;
      }
      return medicine.copyWith(status: MedicineStatus.noLongerUsed);
    }).toList();
    final updatedChild = context.child.copyWith(medicines: updatedMedicines);
    await _saveChild(context, updatedChild);
  }

  Future<_MedicineContext> _loadContext() async {
    final user = await authRepository.currentUser();
    if (user == null) {
      throw StateError('No active profile');
    }
    final carer = profileData.readPrimaryCarer(user.uid);
    if (carer == null) {
      throw StateError('Profile data missing');
    }
    if (carer.children.isEmpty) {
      throw StateError('No child profile available');
    }
    return _MedicineContext(profileId: user.uid, carer: carer, child: carer.children.first);
  }

  Future<void> _saveChild(_MedicineContext context, Child updatedChild) async {
    final updatedChildren = [updatedChild, ...context.carer.children.skip(1)];
    final updatedCarer = context.carer.copyWith(children: updatedChildren);
    await profileData.writePrimaryCarer(context.profileId, updatedCarer);
  }

  String _generateId() {
    return 'med-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class _MedicineContext {
  const _MedicineContext({
    required this.profileId,
    required this.carer,
    required this.child,
  });

  final String profileId;
  final PrimaryCarer carer;
  final Child child;
}

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return LocalMedicineRepository(authRepository: authRepository, profileData: profileData);
});
