import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';

abstract class PrimaryCarerRepository {
  Future<PrimaryCarer> fetchPrimaryCarer();
}

class MockPrimaryCarerRepository implements PrimaryCarerRepository {
  @override
  Future<PrimaryCarer> fetchPrimaryCarer() async {
    final now = DateTime.now();
    final amoxicillin = Medicine(
      id: 'med-amo',
      name: 'Amoxicillin',
      alias: 'Amoxil',
      type: MedicineType.everyday,
      dose: '5',
      doseUnit: 'ml',
      route: 'oral',
      frequency: 'Twice daily',
      notes: 'Give after breakfast and dinner',
      photoUrl: null,
    );

    final inhaler = Medicine(
      id: 'med-salbutamol',
      name: 'Salbutamol',
      alias: 'Blue inhaler',
      type: MedicineType.asNeeded,
      dose: '2',
      doseUnit: 'puffs',
      route: 'inhaled',
      frequency: 'As needed',
      notes: 'Use spacer provided',
    );

    final schedule = MedicineSchedule(
      id: 'sched-amo-morning-evening',
      medicineId: amoxicillin.id,
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now.add(const Duration(days: 7)),
      times: const ['08:00', '19:00'],
      weekdaysActive: List<bool>.filled(7, true),
      administrations: [
        Administration(
          id: 'admin-1',
          dateTime: now.subtract(const Duration(hours: 12)),
          status: AdministrationStatus.given,
          isAsNeeded: false,
          administeredBy: 'Primary carer',
          notes: 'Taken with juice',
        ),
      ],
    );

    final asNeededSchedule = AsNeededSchedule(
      id: 'asneeded-salbutamol',
      medicineId: inhaler.id,
      administrations: [
        Administration(
          id: 'admin-2',
          dateTime: now.subtract(const Duration(days: 1, hours: 3)),
          status: AdministrationStatus.given,
          isAsNeeded: true,
          administeredBy: 'School nurse',
          notes: 'Used after PE',
        ),
      ],
    );

    final child = Child(
      id: 'child-001',
      firstName: 'Ava',
      lastName: 'Taylor',
      dateOfBirth: DateTime(now.year - 8, now.month, now.day),
      condition: 'Asthma',
      allergies: const ['Penicillin'],
      medicines: [amoxicillin, inhaler],
      schedules: [schedule],
      asNeededSchedules: [asNeededSchedule],
    );

    return PrimaryCarer(
      id: 'pc-001',
      firstName: 'Emma',
      lastName: 'Taylor',
      email: 'emma@example.com',
      relationshipToChild: 'Mum',
      children: [child],
    );
  }
}

final primaryCarerRepositoryProvider = Provider<PrimaryCarerRepository>((ref) {
  return MockPrimaryCarerRepository();
});
