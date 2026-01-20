// Mock repository for primary carer data.
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/features/home/data/primary_carer_repository.dart';

// In-memory implementation of the primary carer repository for tests.
class MockPrimaryCarerRepository implements PrimaryCarerRepository {
  MockPrimaryCarerRepository({PrimaryCarer? seed})
    : _seed = seed ?? _samplePrimaryCarer();

  final PrimaryCarer _seed;

  // Returns the seeded primary carer data.
  @override
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    return _seed;
  }
}

// Builds a sample primary carer with medicines, schedules, and a child.
PrimaryCarer _samplePrimaryCarer() {
  final medicine = Medicine(
    id: 'med-1',
    name: 'Amoxicillin',
    alias: 'Amoxil',
    type: MedicineType.everyday,
    dose: '5',
    doseUnit: 'ml',
    route: 'oral',
    frequency: 'Twice daily',
    notes: 'Give with food.',
    photoUrls: const [],
  );

  final rescueMedicine = Medicine(
    id: 'med-2',
    name: 'Salbutamol',
    alias: 'Blue inhaler',
    type: MedicineType.asNeeded,
    dose: '2',
    doseUnit: 'puffs',
    route: 'inhaled',
    frequency: 'As needed',
    notes: 'Use spacer.',
    photoUrls: const [],
  );

  final schedule = MedicineSchedule(
    id: 'schedule-1',
    medicineId: medicine.id,
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    times: const ['08:00', '20:00'],
    weekdaysActive: List<bool>.filled(7, true),
    administrations: [
      Administration(
        id: 'admin-1',
        dateTime: DateTime.now().subtract(const Duration(hours: 4)),
        status: AdministrationStatus.given,
        isAsNeeded: false,
        administeredBy: 'Mum',
      ),
    ],
  );

  final asNeededSchedule = AsNeededSchedule(
    id: 'asneeded-1',
    medicineId: rescueMedicine.id,
    administrations: [
      Administration(
        id: 'admin-2',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        status: AdministrationStatus.given,
        isAsNeeded: true,
        administeredBy: 'Dad',
        notes: 'After PE.',
      ),
    ],
  );

  final child = Child(
    id: 'child-1',
    firstName: 'Ava',
    lastName: 'Taylor',
    dateOfBirth: DateTime(2018, 5, 12),
    condition: 'Asthma',
    allergies: const ['Penicillin'],
    notes: 'Requires spacer for inhaler.',
    medicines: [medicine, rescueMedicine],
    schedules: [schedule],
    asNeededSchedules: [asNeededSchedule],
  );

  return PrimaryCarer(
    id: 'carer-1',
    firstName: 'Emma',
    lastName: 'Taylor',
    email: 'emma@example.com',
    relationshipToChild: 'Mum',
    children: [child],
  );
}
