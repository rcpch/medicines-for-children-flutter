// Controller for dose administration actions.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/data/administration_repository.dart';

class AdministrationState {
  const AdministrationState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  AdministrationState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdministrationState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdministrationController extends Notifier<AdministrationState> {
  late AdministrationRepository _repository;

  @override
  AdministrationState build() {
    _repository = ref.watch(administrationRepositoryProvider);
    return const AdministrationState();
  }

  Future<bool> markScheduled({
    required String scheduleId,
    required DateTime dateTime,
    required AdministrationStatus status,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.recordScheduledAdministration(
        scheduleId: scheduleId,
        dateTime: dateTime,
        status: status,
      );
      await ref.read(primaryCarerControllerProvider.notifier).refresh();
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to update this dose right now.',
      );
      return false;
    }
  }

  Future<bool> undoScheduled({
    required String scheduleId,
    required DateTime dateTime,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.clearScheduledAdministration(
        scheduleId: scheduleId,
        dateTime: dateTime,
      );
      await ref.read(primaryCarerControllerProvider.notifier).refresh();
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to undo this update right now.',
      );
      return false;
    }
  }
}

final administrationControllerProvider =
    NotifierProvider<AdministrationController, AdministrationState>(
      AdministrationController.new,
    );
