// App theme definitions and styling tokens.
import 'package:flutter/material.dart';
import 'package:medicines_for_children_flutter/core/theme/rcpch_colours.dart';

// Centralized theme configuration for the app.
class AppTheme {
  static const String _bodyFontFamily = 'Montserrat';
  static const String _headingFontFamily = 'Quicksand';
  static const FontWeight _headingWeight = FontWeight.w600;

  // Applies RCPCH typography styles to a base text theme.
  static TextTheme _applyRcpchTypography(
    TextTheme base, {
    required Color color,
  }) {
    // Updates heading styles to use the configured font and weight.
    TextStyle? heading(TextStyle? style) => style?.copyWith(
      fontFamily: _headingFontFamily,
      fontWeight: _headingWeight,
    );

    final themed = base.apply(
      fontFamily: _bodyFontFamily,
      bodyColor: color,
      displayColor: color,
    );

    return themed.copyWith(
      displayLarge: heading(themed.displayLarge),
      displayMedium: heading(themed.displayMedium),
      displaySmall: heading(themed.displaySmall),
      headlineLarge: heading(themed.headlineLarge),
      headlineMedium: heading(themed.headlineMedium),
      headlineSmall: heading(themed.headlineSmall),
      titleLarge: heading(themed.titleLarge),
      titleMedium: heading(themed.titleMedium),
      titleSmall: heading(themed.titleSmall),
    );
  }

  // Builds the default light theme for the app.
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: rcpchStrongBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: rcpchStrongBlue,
          primaryContainer: rcpchStrongBlueLightTint3,
          secondary: rcpchPink,
          secondaryContainer: rcpchPinkLightTint3,
          tertiary: rcpchPurple,
          tertiaryContainer: rcpchPurpleLightTint3,
          error: rcpchRed,
          errorContainer: rcpchRedLightTint3,
          surface: rcpchWhite,
          surfaceContainerHighest: rcpchLightestGrey,
          onSurface: rcpchCharcoalDark,
          onSurfaceVariant: rcpchCharcoal,
          outline: rcpchMidGrey,
        );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: _bodyFontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: rcpchWhite,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: rcpchWhite,
        foregroundColor: rcpchDarkBlue,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: rcpchPink,
        foregroundColor: rcpchWhite,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: rcpchStrongBlue,
          foregroundColor: rcpchWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: rcpchLightBlue,
          foregroundColor: rcpchWhite,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: rcpchPurple,
          side: const BorderSide(color: rcpchPurple),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: rcpchStrongBlue),
      ),
      textTheme: _applyRcpchTypography(
        base.textTheme,
        color: rcpchCharcoalDark,
      ),
      primaryTextTheme: _applyRcpchTypography(
        base.primaryTextTheme,
        color: rcpchCharcoalDark,
      ),
    );
  }

  // Builds a high contrast theme for accessibility.
  static ThemeData get highContrast {
    final base = ThemeData(
      colorScheme: const ColorScheme.highContrastLight(),
      useMaterial3: true,
      fontFamily: _bodyFontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: _applyRcpchTypography(base.textTheme, color: Colors.black),
      primaryTextTheme: _applyRcpchTypography(
        base.primaryTextTheme,
        color: Colors.black,
      ),
    );
  }

  // Builds the dark theme variant for low-light environments.
  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: rcpchStrongBlue,
          brightness: Brightness.dark,
        ).copyWith(
          primary: rcpchStrongBlueLightTint1,
          secondary: rcpchPinkLightTint2,
          tertiary: rcpchPurpleLightTint2,
          error: rcpchRedLightTint1,
          surface: const Color(0xFF0C1416),
          onSurface: rcpchWhite,
        );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: _bodyFontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0C1416),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: rcpchPink,
        foregroundColor: rcpchWhite,
      ),
      textTheme: _applyRcpchTypography(base.textTheme, color: Colors.white),
      primaryTextTheme: _applyRcpchTypography(
        base.primaryTextTheme,
        color: Colors.white,
      ),
    );
  }
}
