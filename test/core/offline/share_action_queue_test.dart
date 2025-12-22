import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/offline/share_action_queue.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeShareCentreRepository implements ShareCentreRepository {
  FakeShareCentreRepository();

  int updateCalls = 0;

  @override
  Future<List<ShareCentreSchedule>> fetchSharedSchedules({required String childId}) async {
    return [];
  }

  @override
  Future<ShareCentreSchedule> createSharedSchedule({
    required String childId,
    required String email,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool digital,
    String? notes,
  }) async {
    return _sampleSchedule();
  }

  @override
  Future<String> exportSchedulePdf({
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) async {
    return 'https://example.com/pdf';
  }

  @override
  Future<ShareCentreSchedule> updateSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    bool? digital,
    String? notes,
    bool? deleted,
  }) async {
    updateCalls += 1;
    return _sampleSchedule();
  }

  @override
  Future<ShareCentreSchedule> endSharedSchedule({required String apiId}) async {
    return _sampleSchedule();
  }

  @override
  Future<ShareCentreSchedule> deleteSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    return _sampleSchedule();
  }

  ShareCentreSchedule _sampleSchedule() {
    return ShareCentreSchedule(
      apiId: 'share-1',
      status: 'pending',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 2),
      isDigital: true,
      isDeleted: false,
      carerEmail: 'carer@example.com',
      carerName: 'Carer',
      scheduleUrl: 'https://example.com',
      pdfUrl: '',
      notes: '',
    );
  }
}

void main() {
  test('processQueue sends pending update actions', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = FakeShareCentreRepository();
    const config = AppConfig(
      environment: AppEnvironment.dev,
      sharedScheduleApiBaseUrl: 'https://example.com',
      sharedScheduleApiKey: 'api-key',
    );

    final service = ShareActionQueueService(
      prefs: prefs,
      repository: repository,
      config: config,
    );

    await service.enqueue(
      PendingShareAction(
        id: 'action-1',
        type: ShareActionType.update,
        payload: {
          'apiId': 'share-1',
          'childId': 'child-1',
          'dateFrom': DateTime(2024, 1, 1).toIso8601String(),
          'dateTo': DateTime(2024, 1, 2).toIso8601String(),
          'digital': true,
          'notes': 'note',
        },
        queuedAt: DateTime.now(),
      ),
    );

    await service.processQueue();

    expect(repository.updateCalls, 1);
    final remaining = await service.loadQueue();
    expect(remaining, isEmpty);
  });
}
