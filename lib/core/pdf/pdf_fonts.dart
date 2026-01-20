// Shared PDF font loading helpers.
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

// Loads the PDF theme using bundled Montserrat fonts.
Future<pw.ThemeData> loadPdfTheme() async {
  final regular = await rootBundle.load(
    'assets/fonts/Montserrat/static/Montserrat-Regular.ttf',
  );
  final bold = await rootBundle.load(
    'assets/fonts/Montserrat/static/Montserrat-Bold.ttf',
  );

  return pw.ThemeData.withFont(
    base: pw.Font.ttf(regular),
    bold: pw.Font.ttf(bold),
  );
}
