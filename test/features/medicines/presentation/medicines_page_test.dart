import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';
import 'package:medicines_for_children_flutter/features/medicines/presentation/medicines_page.dart';

void main() {
  testWidgets('filters medicines by type', (tester) async {
    final carer = _sampleCarer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          primaryCarerStateProvider.overrideWithValue(
            PrimaryCarerState(carer: carer),
          ),
        ],
        child: const MaterialApp(home: MedicinesPage()),
      ),
    );

    expect(find.text('Amoxicillin'), findsOneWidget);
    expect(find.text('Daily Vitamin'), findsOneWidget);
    expect(find.text('Salbutamol'), findsNothing);

    await tester.tap(find.text('As-needed'));
    await tester.pumpAndSettle();

    expect(find.text('Amoxicillin'), findsNothing);
    expect(find.text('Daily Vitamin'), findsOneWidget);
    expect(find.text('Salbutamol'), findsOneWidget);
  });
}

PrimaryCarer _sampleCarer() {
  return PrimaryCarer(
    id: 'carer-1',
    firstName: 'Emma',
    lastName: 'Taylor',
    email: 'emma@example.com',
    relationshipToChild: 'Mum',
    children: [
      Child(
        id: 'child-1',
        firstName: 'Ava',
        lastName: 'Taylor',
        dateOfBirth: DateTime(2018, 5, 12),
        condition: 'Asthma',
        allergies: const ['Penicillin'],
        notes: 'Uses spacer with inhaler.',
        medicines: [
          Medicine(
            id: 'med-1',
            name: 'Amoxicillin',
            alias: 'Amoxil',
            type: MedicineType.everyday,
            dose: '5',
            doseUnit: 'ml',
            route: 'oral',
            frequency: 'Twice daily',
          ),
          Medicine(
            id: 'med-2',
            name: 'Salbutamol',
            alias: 'Blue inhaler',
            type: MedicineType.asNeeded,
            dose: '2',
            doseUnit: 'puffs',
            route: 'inhaled',
            frequency: 'As needed',
          ),
          Medicine(
            id: 'med-3',
            name: 'Daily Vitamin',
            alias: 'Vitamin D',
            type: MedicineType.both,
            dose: '1',
            doseUnit: 'tablet',
            route: 'oral',
            frequency: 'Daily',
          ),
        ],
        schedules: const [],
        asNeededSchedules: const [],
      ),
    ],
  );
}
