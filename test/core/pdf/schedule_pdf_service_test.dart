import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/pdf/schedule_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildPdf returns bytes for schedule', () async {
    final medicine = Medicine(
      id: 'med-1',
      name: 'Amoxicillin',
      alias: '',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'Oral',
      frequency: 'Twice daily',
    );
    final schedule = MedicineSchedule(
      id: 'schedule-1',
      medicineId: medicine.id,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 7),
      times: const ['08:00', '20:00'],
      weekdaysActive: const [true, true, true, true, true, true, true],
      administrations: const [],
    );
    final child = Child(
      id: 'child-1',
      firstName: 'Maya',
      lastName: 'Patel',
      dateOfBirth: DateTime(2018, 5, 12),
      condition: 'Asthma',
      allergies: const [],
      medicines: [medicine],
      schedules: [schedule],
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

    final service = SchedulePdfService();
    final bytes = await service.buildPdf(
      carer: carer,
      child: child,
      dateFrom: DateTime(2024, 1, 1),
      dateTo: DateTime(2024, 1, 7),
    );

    expect(bytes, isNotEmpty);
  });
}
