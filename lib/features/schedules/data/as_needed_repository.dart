// Data access for as-needed doses.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/active_child_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';

const _administrationRetentionDays = 90;

// Interface for storing as-needed administrations.
abstract class AsNeededRepository {
  // Records an as-needed administration entry.
  Future<void> recordAdministration({
    required String medicineId,
    required DateTime dateTime,
    String? notes,
  });
}

// Stores as-needed administrations in local profile data.
class LocalAsNeededRepository implements AsNeededRepository {
  LocalAsNeededRepository({
    required this.authRepository,
    required this.profileData,
    required this.activeChildStorage,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;
  final ActiveChildLocalDataSource activeChildStorage;

  @override
  // Appends a new administration to the selected as-needed schedule.
  Future<void> recordAdministration({
    required String medicineId,
    required DateTime dateTime,
    String? notes,
  }) async {
    final context = await _loadContext();
    final administeredBy = context.user.displayName?.trim().isEmpty ?? true
        ? null
        : context.user.displayName;
    final administration = Administration(
      id: _generateId(),
      dateTime: dateTime,
      status: AdministrationStatus.given,
      isAsNeeded: true,
      administeredBy: administeredBy,
      notes: notes,
    );

    final schedules = [...context.child.asNeededSchedules];
    final index = schedules.indexWhere(
      (schedule) => schedule.medicineId == medicineId,
    );
    if (index == -1) {
      schedules.add(
        AsNeededSchedule(
          id: 'asneeded-$medicineId',
          medicineId: medicineId,
          administrations: [administration],
        ),
      );
    } else {
      final existing = schedules[index];
      final pruned = _pruneAdministrations(existing.administrations);
      schedules[index] = existing.copyWith(
        administrations: [...pruned, administration],
      );
    }

    final updatedChild = context.child.copyWith(asNeededSchedules: schedules);
    await _saveChild(context, updatedChild);
  }

  // Loads the active profile, carer, and child context.
  Future<_AsNeededContext> _loadContext() async {
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
    return _AsNeededContext(
      profileId: user.uid,
      user: user,
      carer: carer,
      child: carer.children[childIndex],
      childIndex: childIndex,
    );
  }

  // Writes updated child data back to storage.
  Future<void> _saveChild(_AsNeededContext context, Child updatedChild) async {
    final updatedChildren = [...context.carer.children];
    updatedChildren[context.childIndex] = updatedChild;
    final updatedCarer = context.carer.copyWith(children: updatedChildren);
    await profileData.writePrimaryCarer(context.profileId, updatedCarer);
  }

  // Determines the active child index from stored selection.
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

  // Generates a simple unique id for administrations.
  String _generateId() {
    return 'admin-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Filters out administrations older than the retention window.
  List<Administration> _pruneAdministrations(
    List<Administration> administrations,
  ) {
    final cutoff = DateTime.now().subtract(
      const Duration(days: _administrationRetentionDays),
    );
    return administrations
        .where((admin) => !admin.dateTime.isBefore(cutoff))
        .toList();
  }
}

// Bundles profile data needed to update as-needed administrations.
class _AsNeededContext {
  const _AsNeededContext({
    required this.profileId,
    required this.user,
    required this.carer,
    required this.child,
    required this.childIndex,
  });

  final String profileId;
  final AuthUser user;
  final PrimaryCarer carer;
  final Child child;
  final int childIndex;
}

// Provides the as-needed repository implementation.
final asNeededRepositoryProvider = Provider<AsNeededRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  final activeChildStorage = ref.watch(activeChildLocalDataSourceProvider);
  return LocalAsNeededRepository(
    authRepository: authRepository,
    profileData: profileData,
    activeChildStorage: activeChildStorage,
  );
});
