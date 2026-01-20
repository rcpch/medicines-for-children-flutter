import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/features/splash/presentation/splash_page.dart';

void main() {
  testWidgets('Splash shows logo, title, and pre-alpha banner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Medicines For Children'), findsOneWidget);
    expect(find.text('PRE-ALPHA Evaluation Release'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
