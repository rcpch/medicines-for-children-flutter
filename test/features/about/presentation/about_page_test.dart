import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/features/about/presentation/about_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('About page shows app name and version', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Medicines for Children',
      packageName: 'medicines_for_children_flutter',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: 'test',
    );

    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();

    expect(find.text('Medicines for Children'), findsOneWidget);
    expect(find.text('Version: 1.2.3+4'), findsOneWidget);
    expect(find.textContaining('Platform:'), findsOneWidget);

    expect(find.byKey(const ValueKey('about-github')), findsOneWidget);
    expect(find.byKey(const ValueKey('about-mfc-website')), findsOneWidget);
  });
}
