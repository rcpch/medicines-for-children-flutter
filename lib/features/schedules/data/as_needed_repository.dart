import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';

const _administrationRetentionDays = 90;

abstract class AsNeededRepository {
  Future<void> recordAdministration({
    required String medicineId,
    required DateTime dateTime,
    String? notes,
  });
}

class LocalAsNeededRepository implements AsNeededRepository {
  LocalAsNeededRepository({
    required this.authRepository,
    required this.profileData,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  @override
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
    final index = schedules.indexWhere((schedule) => schedule.medicineId == medicineId);
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
    return _AsNeededContext(profileId: user.uid, user: user, carer: carer, child: carer.children.first);
  }

  Future<void> _saveChild(_AsNeededContext context, Child updatedChild) async {
    final updatedChildren = [updatedChild, ...context.carer.children.skip(1)];
    final updatedCarer = context.carer.copyWith(children: updatedChildren);
    await profileData.writePrimaryCarer(context.profileId, updatedCarer);
  }

  String _generateId() {
    return 'admin-${DateTime.now().millisecondsSinceEpoch}';
  }

  List<Administration> _pruneAdministrations(List<Administration> administrations) {
    final cutoff = DateTime.now().subtract(const Duration(days: _administrationRetentionDays));
    return administrations.where((admin) => !admin.dateTime.isBefore(cutoff)).toList();
  }
}

class _AsNeededContext {
  const _AsNeededContext({
    required this.profileId,
    required this.user,
    required this.carer,
    required this.child,
  });

  final String profileId;
  final AuthUser user;
  final PrimaryCarer carer;
  final Child child;
}

final asNeededRepositoryProvider = Provider<AsNeededRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return LocalAsNeededRepository(authRepository: authRepository, profileData: profileData);
});
