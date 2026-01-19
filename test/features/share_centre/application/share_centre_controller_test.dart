import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/telemetry/telemetry_service.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeShareCentreRepository implements ShareCentreRepository {
  FakeShareCentreRepository(this.schedule);

  final ShareCentreSchedule schedule;

  @override
  Future<List<ShareCentreSchedule>> fetchSharedSchedules({
    required String childId,
  }) async {
    return [schedule];
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
    return schedule;
  }

  @override
  Future<String> exportSchedulePdf({
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) async {
    return 'https://example.com/schedule.pdf';
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
    return schedule;
  }

  @override
  Future<ShareCentreSchedule> endSharedSchedule({required String apiId}) async {
    return schedule;
  }

  @override
  Future<ShareCentreSchedule> deleteSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    return schedule;
  }
}

class TestTelemetryService implements TelemetryService {
  final List<({String name, Map<String, Object?>? properties})> events = [];

  @override
  void trackEvent(String name, {Map<String, Object?>? properties}) {
    events.add((name: name, properties: properties));
  }

  @override
  void trackScreen(String name, {Map<String, Object?>? properties}) {}
}

Future<ProviderContainer> _createContainer({
  required ShareCentreSchedule schedule,
  required TestTelemetryService telemetry,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  const config = AppConfig(
    environment: AppEnvironment.dev,
    sharedScheduleApiBaseUrl: '',
    sharedScheduleApiKey: '',
  );
  return ProviderContainer(
    overrides: [
      shareCentreRepositoryProvider.overrideWithValue(
        FakeShareCentreRepository(schedule),
      ),
      telemetryServiceProvider.overrideWithValue(telemetry),
      sharedPreferencesProvider.overrideWithValue(prefs),
      appConfigProvider.overrideWithValue(config),
    ],
  );
}

void main() {
  test('share centre controller tracks create event', () async {
    final schedule = ShareCentreSchedule(
      apiId: 'share-1',
      status: 'pending',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 10),
      isDigital: true,
      isDeleted: false,
      carerEmail: 'carer@example.com',
      carerName: 'Taylor',
      scheduleUrl: 'https://example.com',
      pdfUrl: '',
      notes: '',
    );
    final telemetry = TestTelemetryService();
    final container = await _createContainer(
      schedule: schedule,
      telemetry: telemetry,
    );
    addTearDown(container.dispose);

    final controller = container.read(shareCentreControllerProvider.notifier);
    final result = await controller.createSchedule(
      childId: 'child-1',
      email: 'carer@example.com',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 10),
      digital: true,
      notes: 'Note',
    );

    expect(result, isNotNull);
    final tracked = telemetry.events.any(
      (event) =>
          event.name == 'share_centre_created' &&
          event.properties?['shareId'] == 'share-1',
    );
    expect(tracked, isTrue);
  });

  test('share centre controller tracks delete event', () async {
    final schedule = ShareCentreSchedule(
      apiId: 'share-2',
      status: 'active',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 10),
      isDigital: false,
      isDeleted: false,
      carerEmail: 'carer@example.com',
      carerName: 'Alex',
      scheduleUrl: '',
      pdfUrl: 'https://example.com/pdf',
      notes: '',
    );
    final telemetry = TestTelemetryService();
    final container = await _createContainer(
      schedule: schedule,
      telemetry: telemetry,
    );
    addTearDown(container.dispose);

    final controller = container.read(shareCentreControllerProvider.notifier);
    final result = await controller.deleteSchedule(
      childId: 'child-1',
      apiId: 'share-2',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 10),
    );

    expect(result, isNotNull);
    final tracked = telemetry.events.any(
      (event) =>
          event.name == 'share_centre_deleted' &&
          event.properties?['shareId'] == 'share-2',
    );
    expect(tracked, isTrue);
  });

  test('share centre controller tracks pdf export event', () async {
    final schedule = ShareCentreSchedule(
      apiId: 'share-3',
      status: 'active',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 10),
      isDigital: false,
      isDeleted: false,
      carerEmail: 'carer@example.com',
      carerName: 'Morgan',
      scheduleUrl: '',
      pdfUrl: '',
      notes: '',
    );
    final telemetry = TestTelemetryService();
    final container = await _createContainer(
      schedule: schedule,
      telemetry: telemetry,
    );
    addTearDown(container.dispose);

    final controller = container.read(shareCentreControllerProvider.notifier);
    final result = await controller.exportPdf(
      childId: 'child-1',
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 10),
      primaryCarerEmail: 'primary@example.com',
    );

    expect(result, isNotNull);
    final tracked = telemetry.events.any(
      (event) =>
          event.name == 'share_centre_pdf_exported' &&
          event.properties?['childId'] == 'child-1',
    );
    expect(tracked, isTrue);
  });
}
