import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/features/user_guide/presentation/user_guide_page.dart';

void main() {
  testWidgets('User guide shows Feedback entry', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: UserGuidePage())),
    );

    final listFinder = find.byType(Scrollable);
    await tester.fling(listFinder, const Offset(0, -2000), 1000);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('guide-feedback')), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
    expect(
      find.text('Report bugs or suggest improvements on GitHub.'),
      findsOneWidget,
    );
  });
}
