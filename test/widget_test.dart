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

void main() {
  testWidgets('renders splash placeholder', (tester) async {
    const config = AppConfig(
      environment: AppEnvironment.dev,
      firebaseProjectId: 'test-project',
      firebaseStorageBucket: 'test-bucket',
      firebaseMessagingSenderId: '123',
      firebaseAndroidAppId: 'android',
      firebaseIosAppId: 'ios',
      firebaseWebAppId: 'web',
      sharedScheduleApiBaseUrl: 'https://api',
      sharedScheduleApiKey: 'key',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(config)],
        child: const MedicinesApp(),
      ),
    );

    expect(find.text('Medicines for Children'), findsOneWidget);
    expect(find.textContaining('bootstrap'), findsOneWidget);
  });
}
