import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/features/child_profile/presentation/child_profile_page.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_controller.dart';
import 'package:medicines_for_children_flutter/features/home/application/primary_carer_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows child profile details', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final carer = PrimaryCarer(
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
          notes: 'Use spacer.',
          medicines: const [],
          schedules: const [],
          asNeededSchedules: const [],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          primaryCarerStateProvider.overrideWithValue(
            PrimaryCarerState(carer: carer),
          ),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: ChildProfilePage()),
      ),
    );

    expect(find.text('Ava Taylor'), findsOneWidget);
    expect(find.text('Asthma'), findsOneWidget);
    expect(find.text('Penicillin'), findsOneWidget);
    expect(find.text('Use spacer.'), findsOneWidget);
  });
}
