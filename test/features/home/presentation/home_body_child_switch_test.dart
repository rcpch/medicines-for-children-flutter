import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/domain/daily_schedule_builder.dart';
import 'package:medicines_for_children_flutter/features/home/presentation/home_page.dart';

void main() {
  testWidgets('HomeBody updates when active child changes', (tester) async {
    final childA = Child(
      id: 'a',
      firstName: 'Alice',
      lastName: 'Example',
      dateOfBirth: DateTime(2020, 1, 1),
      condition: 'Asthma',
      allergies: const [],
      medicines: const [],
      schedules: const [],
      asNeededSchedules: const [],
    );

    final childB = Child(
      id: 'b',
      firstName: 'Bob',
      lastName: 'Example',
      dateOfBirth: DateTime(2021, 1, 1),
      condition: 'Eczema',
      allergies: const [],
      medicines: const [],
      schedules: const [],
      asNeededSchedules: const [],
    );

    final carer = PrimaryCarer(
      id: 'carer-1',
      firstName: 'Pat',
      lastName: 'Carer',
      email: 'pat@example.com',
      relationshipToChild: 'Parent',
      children: [childA, childB],
    );

    final state = PrimaryCarerState(carer: carer);
    final selectedDate = DateTime(2026, 1, 19);
    final theme = ThemeData(useMaterial3: true);
    final builder = DailyScheduleBuilder();

    Future<void> pumpWithChild(Child activeChild) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeBody(
              state: state,
              onRefresh: () async {},
              theme: theme,
              dailyScheduleBuilder: builder,
              activeChild: activeChild,
              selectedDate: selectedDate,
              onSelectDate: (_) {},
              onAddSchedule: () {},
              onManageSchedules: () {},
              onRecordAsNeeded: () {},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpWithChild(childA);
    expect(find.text('Alice Example'), findsOneWidget);
    expect(find.text('Bob Example'), findsNothing);

    await pumpWithChild(childB);
    expect(find.text('Bob Example'), findsOneWidget);
    expect(find.text('Alice Example'), findsNothing);
  });
}
