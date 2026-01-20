import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/platform/backup_file_io.dart';
import 'package:medicines_for_children_flutter/core/pdf/medicine_summary_pdf_service.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';
import 'package:medicines_for_children_flutter/features/share_centre/application/share_centre_providers.dart';
import 'package:medicines_for_children_flutter/features/share_centre/data/share_centre_repository.dart';
import 'package:medicines_for_children_flutter/features/share_centre/presentation/share_centre_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBackupFileIO implements BackupFileIO {
  Uint8List? savedBytes;
  String? savedFilename;
  String? savedMimeType;

  @override
  Future<void> saveBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    savedBytes = bytes;
    savedFilename = filename;
    savedMimeType = mimeType;
  }

  @override
  Future<Uint8List?> pickFileBytes({
    required String label,
    required List<String> extensions,
  }) async {
    return null;
  }
}

class FakeMedicineSummaryPdfService extends MedicineSummaryPdfService {
  bool called = false;
  Child? child;
  PrimaryCarer? carer;

  @override
  Future<Uint8List> buildPdf({
    required PrimaryCarer carer,
    required Child child,
  }) async {
    called = true;
    this.child = child;
    this.carer = carer;
    return Uint8List.fromList([1, 2, 3, 4]);
  }
}

class FakeShareCentreRepository implements ShareCentreRepository {
  @override
  Future<ShareCentreSchedule> createSharedSchedule({
    required String childId,
    required String email,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool digital,
    String? notes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<ShareCentreSchedule>> fetchSharedSchedules({
    required String childId,
  }) async {
    return [];
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ShareCentreSchedule> endSharedSchedule({required String apiId}) {
    throw UnimplementedError();
  }

  @override
  Future<ShareCentreSchedule> deleteSharedSchedule({
    required String apiId,
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> exportSchedulePdf({
    required String childId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String primaryCarerEmail,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('export medicines saves a PDF', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final child = Child(
      id: 'child-1',
      firstName: 'Maya',
      lastName: 'Patel',
      dateOfBirth: DateTime(2018, 5, 12),
      condition: 'Asthma',
      allergies: const [],
      medicines: const [],
      schedules: const [],
      asNeededSchedules: const [],
    );
    final carer = PrimaryCarer(
      id: 'carer-1',
      firstName: 'Jamie',
      lastName: 'Patel',
      email: 'jamie@example.com',
      relationshipToChild: 'Parent',
      children: [child],
    );
    final fakeFileIO = FakeBackupFileIO();
    final fakePdfService = FakeMedicineSummaryPdfService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeChildProvider.overrideWithValue(child),
          sharedPreferencesProvider.overrideWithValue(prefs),
          appConfigProvider.overrideWithValue(
            const AppConfig(
              environment: AppEnvironment.dev,
              sharedScheduleApiBaseUrl: '',
              sharedScheduleApiKey: '',
            ),
          ),
          primaryCarerStateProvider.overrideWithValue(
            PrimaryCarerState(carer: carer),
          ),
          shareCentreRepositoryProvider.overrideWithValue(
            FakeShareCentreRepository(),
          ),
          shareCentreSchedulesProvider(
            child.id,
          ).overrideWith((ref) async => []),
          backupFileIOProvider.overrideWithValue(fakeFileIO),
          medicineSummaryPdfServiceProvider.overrideWithValue(fakePdfService),
        ],
        child: const MaterialApp(home: ShareCentrePage()),
      ),
    );

    await tester.tap(find.text('Export medicines'));
    await tester.pumpAndSettle();

    expect(fakePdfService.called, isTrue);
    expect(fakeFileIO.savedBytes, isNotNull);
    expect(fakeFileIO.savedMimeType, 'application/pdf');
    expect(find.text('Medicines PDF saved.'), findsOneWidget);
  });
}
