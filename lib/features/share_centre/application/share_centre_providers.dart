// Providers for Sharing state.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/network/api_client.dart';
import 'package:medicines_for_children_flutter/core/offline/share_action_queue.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';

// Holds UI state for share centre actions.
class ShareCentreActionState {
  const ShareCentreActionState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  // Creates a new state with selective field overrides.
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

// Orchestrates share centre actions and queues offline work.
class ShareCentreController extends Notifier<ShareCentreActionState> {
  ShareCentreController();

  late ShareCentreRepository _repository;
  late TelemetryService _telemetry;
  late ShareActionQueueService _queue;

  @override
  // Wires up dependencies and initializes default state.
  ShareCentreActionState build() {
    _repository = ref.watch(shareCentreRepositoryProvider);
    _telemetry = ref.read(telemetryServiceProvider);
    _queue = ref.read(shareActionQueueServiceProvider);
    return const ShareCentreActionState();
  }

  // Creates a shared schedule and tracks telemetry.
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
      ref.invalidate(shareCentreSchedulesProvider(childId));
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

  // Updates an existing shared schedule and tracks telemetry.
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
      ref.invalidate(shareCentreSchedulesProvider(childId));
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

  // Exports a shared schedule PDF and returns the url.
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

  // Ends a shared schedule and tracks telemetry.
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
      ref.invalidate(shareCentreSchedulesProvider(childId));
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

  // Deletes a shared schedule and tracks telemetry.
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
      ref.invalidate(shareCentreSchedulesProvider(childId));
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

// Determines whether a request failure is due to network issues.
bool _isNetworkError(Object error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.unknown;
  }
  return false;
}

// Provides the share centre repository implementation.
final shareCentreRepositoryProvider = Provider<ShareCentreRepository>((ref) {
  final dio = ref.watch(securedApiClientProvider);
  return HttpShareCentreRepository(dio);
});

// Loads share schedules for the current child.
final shareCentreSchedulesProvider =
    FutureProvider.family<List<ShareCentreSchedule>, String>((
      ref,
      childId,
    ) async {
      final repository = ref.watch(shareCentreRepositoryProvider);
      return repository.fetchSharedSchedules(childId: childId);
    });

// Provides access to share centre actions.
final shareCentreControllerProvider =
    NotifierProvider<ShareCentreController, ShareCentreActionState>(
      ShareCentreController.new,
    );
