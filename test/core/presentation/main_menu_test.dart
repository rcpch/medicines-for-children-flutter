import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/presentation/main_menu.dart';

void main() {
  testWidgets('Main menu includes About', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [MainMenu()])),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<MainMenuAction>));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
  });
}
