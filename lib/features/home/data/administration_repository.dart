// Administration data access layer.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/auth/domain/auth_user.dart';

const _administrationRetentionDays = 90;

abstract class AdministrationRepository {
  Future<void> recordScheduledAdministration({
    required String scheduleId,
    required DateTime dateTime,
    required AdministrationStatus status,
    String? notes,
  });

  Future<void> clearScheduledAdministration({
    required String scheduleId,
    required DateTime dateTime,
  });
}

class LocalAdministrationRepository implements AdministrationRepository {
  LocalAdministrationRepository({
    required this.authRepository,
    required this.profileData,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  @override
  Future<void> recordScheduledAdministration({
    required String scheduleId,
    required DateTime dateTime,
    required AdministrationStatus status,
    String? notes,
  }) async {
    final context = await _loadContext();
    final schedule = context.child.schedules.firstWhere(
      (item) => item.id == scheduleId,
      orElse: () => throw StateError('Schedule not found'),
    );

    final administeredBy = context.user.displayName?.trim().isEmpty ?? true
        ? null
        : context.user.displayName;
    final existingIndex = schedule.administrations.indexWhere(
      (admin) => _isSameMinute(admin.dateTime, dateTime),
    );

    final updatedAdmin = Administration(
      id: existingIndex == -1 ? _generateId() : schedule.administrations[existingIndex].id,
      dateTime: dateTime,
      status: status,
      isAsNeeded: false,
      administeredBy: administeredBy,
      notes: notes,
    );

    final updatedAdministrations = [...schedule.administrations];
    if (existingIndex == -1) {
      updatedAdministrations.add(updatedAdmin);
    } else {
      updatedAdministrations[existingIndex] = updatedAdmin;
    }

    final updatedSchedule = schedule.copyWith(administrations: updatedAdministrations);
    await _saveSchedule(context, updatedSchedule);
  }

  @override
  Future<void> clearScheduledAdministration({
    required String scheduleId,
    required DateTime dateTime,
  }) async {
    final context = await _loadContext();
    final schedule = context.child.schedules.firstWhere(
      (item) => item.id == scheduleId,
      orElse: () => throw StateError('Schedule not found'),
    );

    final updatedAdministrations = schedule.administrations
        .where((admin) => !_isSameMinute(admin.dateTime, dateTime))
        .toList();
    final updatedSchedule = schedule.copyWith(administrations: updatedAdministrations);
    await _saveSchedule(context, updatedSchedule);
  }

  Future<_AdministrationContext> _loadContext() async {
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
    return _AdministrationContext(profileId: user.uid, user: user, carer: carer, child: carer.children.first);
  }

  Future<void> _saveSchedule(_AdministrationContext context, MedicineSchedule schedule) async {
    final prunedAdministrations = _pruneAdministrations(schedule.administrations);
    final prunedSchedule = schedule.copyWith(administrations: prunedAdministrations);
    final updatedSchedules = context.child.schedules
        .map((item) => item.id == schedule.id ? prunedSchedule : item)
        .toList();
    final updatedChild = context.child.copyWith(schedules: updatedSchedules);
    final updatedCarer = context.carer.copyWith(children: [
      updatedChild,
      ...context.carer.children.skip(1),
    ]);
    await profileData.writePrimaryCarer(context.profileId, updatedCarer);
  }

  bool _isSameMinute(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  List<Administration> _pruneAdministrations(List<Administration> administrations) {
    final cutoff = DateTime.now().subtract(const Duration(days: _administrationRetentionDays));
    return administrations.where((admin) => !admin.dateTime.isBefore(cutoff)).toList();
  }

  String _generateId() {
    return 'admin-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class _AdministrationContext {
  const _AdministrationContext({
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

final administrationRepositoryProvider = Provider<AdministrationRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return LocalAdministrationRepository(authRepository: authRepository, profileData: profileData);
});
