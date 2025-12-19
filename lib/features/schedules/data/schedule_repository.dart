import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/data/storage/profile_data_local_data_source.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/auth/data/auth_repository.dart';
import 'package:medicines_for_children_flutter/features/schedules/domain/schedule_draft.dart';

abstract class ScheduleRepository {
  Future<MedicineSchedule> createSchedule(ScheduleDraft draft);
  Future<void> updateSchedule(MedicineSchedule schedule);
  Future<void> deleteSchedule(String scheduleId);
}

class LocalScheduleRepository implements ScheduleRepository {
  LocalScheduleRepository({
    required this.authRepository,
    required this.profileData,
  });

  final AuthRepository authRepository;
  final ProfileDataLocalDataSource profileData;

  @override
  Future<MedicineSchedule> createSchedule(ScheduleDraft draft) async {
    final context = await _loadContext();
    final schedule = MedicineSchedule(
      id: _generateId(),
      medicineId: draft.medicineId,
      startDate: draft.startDate,
      endDate: draft.endDate,
      times: draft.times,
      weekdaysActive: draft.weekdaysActive,
      administrations: const [],
    );

    final updatedChild = context.child.copyWith(
      schedules: [...context.child.schedules, schedule],
    );
    await _saveChild(context, updatedChild);
    return schedule;
  }

  @override
  Future<void> updateSchedule(MedicineSchedule schedule) async {
    final context = await _loadContext();
    final updatedSchedules = context.child.schedules
        .map((item) => item.id == schedule.id ? schedule : item)
        .toList();
    final updatedChild = context.child.copyWith(schedules: updatedSchedules);
    await _saveChild(context, updatedChild);
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    final context = await _loadContext();
    final updatedSchedules = context.child.schedules
        .where((schedule) => schedule.id != scheduleId)
        .toList();
    final updatedChild = context.child.copyWith(schedules: updatedSchedules);
    await _saveChild(context, updatedChild);
  }

  Future<_ScheduleContext> _loadContext() async {
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
    return _ScheduleContext(profileId: user.uid, carer: carer, child: carer.children.first);
  }

  Future<void> _saveChild(_ScheduleContext context, Child updatedChild) async {
    final updatedChildren = [updatedChild, ...context.carer.children.skip(1)];
    final updatedCarer = context.carer.copyWith(children: updatedChildren);
    await profileData.writePrimaryCarer(context.profileId, updatedCarer);
  }

  String _generateId() {
    return 'sched-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class _ScheduleContext {
  const _ScheduleContext({
    required this.profileId,
    required this.carer,
    required this.child,
  });

  final String profileId;
  final PrimaryCarer carer;
  final Child child;
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileData = ref.watch(profileDataLocalDataSourceProvider);
  return LocalScheduleRepository(authRepository: authRepository, profileData: profileData);
});
