// App theme definitions and styling tokens.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicines_for_children_flutter/core/theme/rcpch_colours.dart';

class AppTheme {
  static const FontWeight _headingWeight = FontWeight.w600;

  static TextTheme _applyRcpchTypography(
    TextTheme base, {
    required Color color,
  }) {
    final body = GoogleFonts.montserratTextTheme(base);
    final headings = GoogleFonts.quicksandTextTheme(base);

    TextStyle? heading(TextStyle? style) =>
        style?.copyWith(fontWeight: _headingWeight);

    return body
        .copyWith(
          displayLarge: heading(headings.displayLarge),
          displayMedium: heading(headings.displayMedium),
          displaySmall: heading(headings.displaySmall),
          headlineLarge: heading(headings.headlineLarge),
          headlineMedium: heading(headings.headlineMedium),
          headlineSmall: heading(headings.headlineSmall),
          titleLarge: heading(headings.titleLarge),
          titleMedium: heading(headings.titleMedium),
          titleSmall: heading(headings.titleSmall),
        )
        .apply(bodyColor: color, displayColor: color);
  }

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

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

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
    );
  }

  static ThemeData get highContrast {
    final base = ThemeData(
      colorScheme: const ColorScheme.highContrastLight(),
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: _applyRcpchTypography(base.textTheme, color: Colors.black),
    );
  }

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

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0C1416),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: rcpchPink,
        foregroundColor: rcpchWhite,
      ),
      textTheme: _applyRcpchTypography(base.textTheme, color: Colors.white),
    );
  }
}
