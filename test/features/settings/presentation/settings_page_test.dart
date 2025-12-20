import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/settings_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/privacy_policy_page.dart';
import 'package:medicines_for_children_flutter/features/settings/presentation/data_deletion_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('settings page toggles telemetry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    final toggle = find.byType(SwitchListTile);
    expect(toggle, findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(prefs.getBool('telemetry_enabled'), isFalse);
  });

  testWidgets('settings page navigates to privacy policy and data deletion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);

    Navigator.of(tester.element(find.byType(PrivacyPolicyPage))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Request data deletion'));
    await tester.pumpAndSettle();
    expect(find.byType(DataDeletionPage), findsOneWidget);
  });
}
