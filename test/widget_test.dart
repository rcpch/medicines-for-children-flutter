// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/app/app.dart';
import 'package:medicines_for_children_flutter/core/config/app_config.dart';
import 'package:medicines_for_children_flutter/core/data/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders splash placeholder', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const config = AppConfig(
      environment: AppEnvironment.dev,
      sharedScheduleApiBaseUrl: 'https://api',
      sharedScheduleApiKey: 'key',
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MedicinesApp(),
      ),
    );

    expect(find.text('Medicines For Children'), findsOneWidget);
    expect(find.text('PRE-ALPHA Evaluation Release'), findsOneWidget);
  });
}
