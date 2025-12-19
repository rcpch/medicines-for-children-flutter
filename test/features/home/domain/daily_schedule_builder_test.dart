import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/home/domain/daily_schedule_builder.dart';

void main() {
  group('DailyScheduleBuilder', () {
    final builder = DailyScheduleBuilder();
    final child = _sampleChild();

    test('buildScheduledEntries returns entries for active schedules', () {
      final now = DateTime(2025, 1, 6, 9); // Monday
      final entries = builder.buildScheduledEntries(child, now);

      expect(entries, isNotEmpty);
      expect(entries.first.medicine.name, 'Amoxicillin');
      expect(entries.first.status, AdministrationStatus.given);
    });

    test('buildScheduledEntries ignores inactive days', () {
      final saturday = DateTime(2025, 1, 4);
      final entries = builder.buildScheduledEntries(child, saturday);
      expect(entries, isEmpty);
    });

    test('buildAsNeededEntries filters administrations for the day', () {
      final now = DateTime(2025, 1, 6, 15);
      final entries = builder.buildAsNeededEntries(child, now);
      expect(entries, hasLength(1));
      expect(entries.first.medicine.name, 'Salbutamol');
    });
  });
}

Child _sampleChild() {
  final medicine = Medicine(
    id: 'med-1',
    name: 'Amoxicillin',
    alias: 'Amoxil',
    type: MedicineType.everyday,
    dose: '5',
    doseUnit: 'ml',
    route: 'oral',
    frequency: 'Twice daily',
    notes: 'After meals',
  );

  final asNeededMedicine = Medicine(
    id: 'med-2',
    name: 'Salbutamol',
    alias: 'Blue inhaler',
    type: MedicineType.asNeeded,
    dose: '2',
    doseUnit: 'puffs',
    route: 'inhaled',
    frequency: 'As needed',
    notes: 'Use spacer',
  );

  final schedule = MedicineSchedule(
    id: 'sched-1',
    medicineId: medicine.id,
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2025, 1, 31),
    times: const ['8:00am', '20:00'],
    weekdaysActive: const [true, true, true, true, true, false, false],
    administrations: [
      Administration(
        id: 'admin-1',
        dateTime: DateTime(2025, 1, 6, 8, 0),
        status: AdministrationStatus.given,
        isAsNeeded: false,
        administeredBy: 'Mum',
      ),
    ],
  );

  final asNeededSchedule = AsNeededSchedule(
    id: 'asneeded-1',
    medicineId: asNeededMedicine.id,
    administrations: [
      Administration(
        id: 'admin-2',
        dateTime: DateTime(2025, 1, 6, 14, 30),
        status: AdministrationStatus.given,
        isAsNeeded: true,
        administeredBy: 'Dad',
        notes: 'After PE',
      ),
      Administration(
        id: 'admin-3',
        dateTime: DateTime(2025, 1, 5, 14, 30),
        status: AdministrationStatus.given,
        isAsNeeded: true,
      ),
    ],
  );

  return Child(
    id: 'child-1',
    firstName: 'Ava',
    lastName: 'Taylor',
    dateOfBirth: DateTime(2018, 5, 12),
    condition: 'Asthma',
    allergies: const ['Penicillin'],
    notes: 'Requires spacer for inhaler.',
    medicines: [medicine, asNeededMedicine],
    schedules: [schedule],
    asNeededSchedules: [asNeededSchedule],
  );
}
