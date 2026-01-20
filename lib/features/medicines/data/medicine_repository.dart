// Medicine data access layer.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';

// Interface for medicine persistence operations.
abstract class MedicineRepository {
  // Creates a new medicine from a draft.
  Future<Medicine> createMedicine(MedicineDraft draft);
  // Updates an existing medicine.
  Future<void> updateMedicine(Medicine medicine);
  // Marks a medicine as no longer used.
  Future<void> archiveMedicine(String medicineId);
}

// Local implementation that writes to profile data storage.
class LocalMedicineRepository implements MedicineRepository {
  LocalMedicineRepository({
    required this.authRepository,
    required this.profileData,
    required this.activeChildStorage,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;
  final ActiveChildLocalDataSource activeChildStorage;

  @override
  // Creates a medicine and appends it to the active child.
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
  // Updates the medicine entry for the active child.
  Future<void> updateMedicine(Medicine medicine) async {
    final context = await _loadContext();
    final updatedMedicines = context.child.medicines
        .map((item) => item.id == medicine.id ? medicine : item)
        .toList();
    final updatedChild = context.child.copyWith(medicines: updatedMedicines);
    await _saveChild(context, updatedChild);
  }

  @override
  // Archives a medicine by setting its status to no longer used.
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

  // Loads the active profile, carer, and child context.
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
    final childIndex = _resolveChildIndex(carer, user.uid);
    return _MedicineContext(
      profileId: user.uid,
      carer: carer,
      child: carer.children[childIndex],
      childIndex: childIndex,
    );
  }

  // Persists the updated child back into the carer data.
  Future<void> _saveChild(_MedicineContext context, Child updatedChild) async {
    final updatedChildren = [...context.carer.children];
    updatedChildren[context.childIndex] = updatedChild;
    final updatedCarer = context.carer.copyWith(children: updatedChildren);
    await profileData.writePrimaryCarer(context.profileId, updatedCarer);
  }

  // Resolves which child index to update based on active selection.
  int _resolveChildIndex(PrimaryCarer carer, String profileId) {
    final activeChildId = activeChildStorage.readActiveChildId(profileId);
    if (activeChildId == null || activeChildId.isEmpty) {
      return 0;
    }
    final index = carer.children.indexWhere(
      (child) => child.id == activeChildId,
    );
    return index == -1 ? 0 : index;
  }

  // Generates a unique id for a medicine.
  String _generateId() {
    return 'med-${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Holds loaded context for updating medicines.
class _MedicineContext {
  const _MedicineContext({
    required this.profileId,
    required this.carer,
    required this.child,
    required this.childIndex,
  });

  final String profileId;
  final PrimaryCarer carer;
  final Child child;
  final int childIndex;
}

// Provides the medicine repository implementation.
final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  final activeChildStorage = ref.watch(activeChildLocalDataSourceProvider);
  return LocalMedicineRepository(
    authRepository: authRepository,
    profileData: profileData,
    activeChildStorage: activeChildStorage,
  );
});
