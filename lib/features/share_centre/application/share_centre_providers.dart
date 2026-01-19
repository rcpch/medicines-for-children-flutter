// Providers for Share Centre state.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/network/api_client.dart';
import 'package:medicines_for_children_flutter/core/offline/share_action_queue.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';

class ShareCentreActionState {
  const ShareCentreActionState({this.isSaving = false, this.errorMessage});

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
      _queue = _ref.read(shareActionQueueServiceProvider),
      super(const ShareCentreActionState());

  final Ref _ref;
  final ShareCentreRepository _repository;
  final TelemetryService _telemetry;
  final ShareActionQueueService _queue;

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
      _telemetry.trackEvent(
        'share_centre_created',
        properties: {
          'childId': childId,
          'shareId': schedule.apiId,
          'digital': digital,
        },
      );
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (error) {
      if (_isNetworkError(error)) {
        await _queue.enqueue(
          PendingShareAction(
            id: 'share-create-${DateTime.now().millisecondsSinceEpoch}',
            type: ShareActionType.create,
            payload: {
              'childId': childId,
              'email': email,
              'dateFrom': dateFrom.toIso8601String(),
              'dateTo': dateTo.toIso8601String(),
              'digital': digital,
              'notes': notes,
            },
            queuedAt: DateTime.now(),
          ),
        );
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: _isNetworkError(error)
            ? 'No connection. Share creation queued for retry.'
            : 'Unable to create this share right now.',
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
      _telemetry.trackEvent(
        'share_centre_updated',
        properties: {'childId': childId, 'shareId': schedule.apiId},
      );
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (error) {
      if (_isNetworkError(error)) {
        await _queue.enqueue(
          PendingShareAction(
            id: 'share-update-${DateTime.now().millisecondsSinceEpoch}',
            type: ShareActionType.update,
            payload: {
              'apiId': apiId,
              'childId': childId,
              'dateFrom': dateFrom.toIso8601String(),
              'dateTo': dateTo.toIso8601String(),
              'digital': digital,
              'notes': notes,
            },
            queuedAt: DateTime.now(),
          ),
        );
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: _isNetworkError(error)
            ? 'No connection. Share update queued for retry.'
            : 'Unable to update this share right now.',
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
      _telemetry.trackEvent(
        'share_centre_pdf_exported',
        properties: {'childId': childId},
      );
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
      _telemetry.trackEvent(
        'share_centre_ended',
        properties: {'childId': childId, 'shareId': schedule.apiId},
      );
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (error) {
      if (_isNetworkError(error)) {
        await _queue.enqueue(
          PendingShareAction(
            id: 'share-end-${DateTime.now().millisecondsSinceEpoch}',
            type: ShareActionType.end,
            payload: {'apiId': apiId},
            queuedAt: DateTime.now(),
          ),
        );
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: _isNetworkError(error)
            ? 'No connection. Share end queued for retry.'
            : 'Unable to end this share right now.',
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
      _telemetry.trackEvent(
        'share_centre_deleted',
        properties: {'childId': childId, 'shareId': schedule.apiId},
      );
      _ref.invalidate(shareCentreSchedulesProvider(childId));
      state = state.copyWith(isSaving: false, clearError: true);
      return schedule;
    } catch (error) {
      if (_isNetworkError(error)) {
        await _queue.enqueue(
          PendingShareAction(
            id: 'share-delete-${DateTime.now().millisecondsSinceEpoch}',
            type: ShareActionType.delete,
            payload: {
              'apiId': apiId,
              'childId': childId,
              'dateFrom': dateFrom.toIso8601String(),
              'dateTo': dateTo.toIso8601String(),
            },
            queuedAt: DateTime.now(),
          ),
        );
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: _isNetworkError(error)
            ? 'No connection. Share delete queued for retry.'
            : 'Unable to delete this share right now.',
      );
      return null;
    }
  }
}

bool _isNetworkError(Object error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.unknown;
  }
  return false;
}

final shareCentreRepositoryProvider = Provider<ShareCentreRepository>((ref) {
  final dio = ref.watch(securedApiClientProvider);
  return HttpShareCentreRepository(dio);
});

final shareCentreSchedulesProvider =
    FutureProvider.family<List<ShareCentreSchedule>, String>((
      ref,
      childId,
    ) async {
      final repository = ref.watch(shareCentreRepositoryProvider);
      return repository.fetchSharedSchedules(childId: childId);
    });

final shareCentreControllerProvider =
    StateNotifierProvider<ShareCentreController, ShareCentreActionState>((ref) {
      final repository = ref.watch(shareCentreRepositoryProvider);
      return ShareCentreController(ref, repository);
    });
