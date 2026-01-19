import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicines_for_children_flutter/core/config/app_theme.dart';

void main() {
  test('AppTheme uses Montserrat for body text', () {
    expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'Montserrat');
    expect(AppTheme.dark.textTheme.bodyMedium?.fontFamily, 'Montserrat');
    expect(
      AppTheme.highContrast.textTheme.bodyMedium?.fontFamily,
      'Montserrat',
    );
  });

  test('AppTheme uses Quicksand semi-bold for headings', () {
    final titleLarge = AppTheme.light.textTheme.titleLarge;
    expect(titleLarge?.fontFamily, 'Quicksand');
    expect(titleLarge?.fontWeight, FontWeight.w600);
  });
}
