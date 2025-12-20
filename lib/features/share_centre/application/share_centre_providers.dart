import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/network/api_client.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';

class ShareCentreActionState {
  const ShareCentreActionState({
    this.isSaving = false,
    this.errorMessage,
  });

  final bool isSaving;
  final String? errorMessage;

  ShareCentreActionState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShareCentreActionState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ShareCentreController extends StateNotifier<ShareCentreActionState> {
  ShareCentreController(this._ref, this._repository)
      : _telemetry = _ref.read(telemetryServiceProvider),
        super(const ShareCentreActionState());

  final Ref _ref;
  final ShareCentreRepository _repository;
  final TelemetryService _telemetry;

  Future<ShareCentreSchedule?> createSchedule({
    required String childId,
    required String email,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool digital,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.createSharedSchedule(
        childId: childId,
        email: email,
        dateFrom: dateFrom,
        dateTo: dateTo,
        digital: digital,
        notes: notes,
      );
      _telemetry.trackEvent('share_centre_created', properties: {
        'childId': childId,
        'shareId': schedule.apiId,
        'digital': digital,
      });
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to create this share right now.',
      );
      return null;
    }
  }

  Future<ShareCentreSchedule?> updateSchedule({
    required String childId,
    required String apiId,
    required DateTime dateFrom,
    required DateTime dateTo,
    bool? digital,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.updateSharedSchedule(
        apiId: apiId,
        childId: childId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        digital: digital,
        notes: notes,
      );
      _telemetry.trackEvent('share_centre_updated', properties: {
        'childId': childId,
        'shareId': schedule.apiId,
      });
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to update this share right now.',
      );
      return null;
    }
  }

  Future<String?> exportPdf({
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final pdfUrl = await _repository.exportSchedulePdf(
        childId: childId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        primaryCarerEmail: primaryCarerEmail,
      );
      _telemetry.trackEvent('share_centre_pdf_exported', properties: {
        'childId': childId,
      });
      state = state.copyWith(isSaving: false, clearError: true);
      return pdfUrl;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to generate a PDF right now.',
      );
      return null;
    }
  }

  Future<ShareCentreSchedule?> endSchedule({
    required String childId,
    required String apiId,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.endSharedSchedule(apiId: apiId);
      _telemetry.trackEvent('share_centre_ended', properties: {
        'childId': childId,
        'shareId': schedule.apiId,
      });
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to end this share right now.',
      );
      return null;
    }
  }

  Future<ShareCentreSchedule?> deleteSchedule({
    required String childId,
    required String apiId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final schedule = await _repository.deleteSharedSchedule(
        apiId: apiId,
        childId: childId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      _telemetry.trackEvent('share_centre_deleted', properties: {
        'childId': childId,
        'shareId': schedule.apiId,
      });
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to delete this share right now.',
      );
      return null;
    }
  }
}

final shareCentreRepositoryProvider = Provider<ShareCentreRepository>((ref) {
  final dio = ref.watch(securedApiClientProvider);
  return HttpShareCentreRepository(dio);
});

final shareCentreSchedulesProvider = FutureProvider.family<List<ShareCentreSchedule>, String>((ref, childId) async {
  final repository = ref.watch(shareCentreRepositoryProvider);
  return repository.fetchSharedSchedules(childId: childId);
});

final shareCentreControllerProvider = StateNotifierProvider<ShareCentreController, ShareCentreActionState>((ref) {
  final repository = ref.watch(shareCentreRepositoryProvider);
  return ShareCentreController(ref, repository);
});
