import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/offline/shared_schedule_action_queue.dart';
import 'package:medicines_for_children_flutter/features/shared_schedule/data/shared_schedule_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedScheduleRepository implements SharedScheduleRepository {
  int confirmCalls = 0;

  @override
  Future<SharedScheduleAuthResult> exchangeLinkToken(String linkToken) async {
    throw UnimplementedError();
  }

  @override
  Future<SharedScheduleViewModel> fetchSharedSchedule({
    required String apiId,
    required String authToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> confirmSchedule({
    required String apiId,
    required String authToken,
    required bool approved,
    String? reason,
  }) async {
    confirmCalls += 1;
  }

  @override
  Future<String> exportSharedSchedulePdf({
    required String apiId,
    required String authToken,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> recordAdministration({
    required String apiId,
    required String authToken,
    required String parentId,
    required String adminBy,
    required DateTime dateTime,
    required bool isAsNeeded,
    required bool skipped,
    String? scheduledItemId,
    String? medicineId,
    String? notes,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  test('processQueue sends pending confirm actions', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = FakeSharedScheduleRepository();
    const config = AppConfig(
      environment: AppEnvironment.dev,
      sharedScheduleApiBaseUrl: 'https://example.com',
      sharedScheduleApiKey: 'api-key',
    );

    final service = SharedScheduleActionQueueService(
      prefs: prefs,
      repository: repository,
      config: config,
    );

    await service.enqueue(
      PendingSharedScheduleAction(
        id: 'action-1',
        type: SharedScheduleActionType.confirm,
        payload: {
          'apiId': 'share-1',
          'authToken': 'token',
          'approved': true,
          'reason': null,
        },
        queuedAt: DateTime.now(),
      ),
    );

    await service.processQueue();

    expect(repository.confirmCalls, 1);
    final remaining = await service.loadQueue();
    expect(remaining, isEmpty);
  });
}
