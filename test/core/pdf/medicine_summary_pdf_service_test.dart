import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/pdf/medicine_summary_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildPdf returns bytes for medicines summary', () async {
    final child = Child(
      id: 'child-1',
      firstName: 'Maya',
      lastName: 'Patel',
      dateOfBirth: DateTime(2018, 5, 12),
      condition: 'Asthma',
      allergies: const [],
      medicines: [
        Medicine(
          id: 'med-1',
          name: 'Salbutamol',
          alias: 'Blue inhaler',
          type: MedicineType.everyday,
          dose: '2',
          doseUnit: 'puffs',
          route: 'Inhaled',
          frequency: 'Morning',
        ),
      ],
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

    final service = MedicineSummaryPdfService();
    final bytes = await service.buildPdf(carer: carer, child: child);

    expect(bytes, isNotEmpty);
  });
}
