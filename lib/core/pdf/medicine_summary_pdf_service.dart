// PDF generation for medicine summaries.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MedicineSummaryPdfService {
  Future<Uint8List> buildPdf({
    required PrimaryCarer carer,
    required Child child,
  }) async {
    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'Medicines summary',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Child: ${_childName(child)}'),
          pw.Text('Carer: ${carer.firstName} ${carer.lastName}'.trim()),
          pw.SizedBox(height: 12),
          pw.Text(
            'Medicines',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (child.medicines.isEmpty)
            pw.Text('No medicines recorded.')
          else
            ...child.medicines.map((medicine) => _medicineBlock(medicine)),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _medicineBlock(Medicine medicine) {
    final details = <String>[
      'Dose: ${medicine.dose} ${medicine.doseUnit}',
      'Route: ${medicine.route}',
      'Frequency: ${medicine.frequency}',
      if (medicine.notes != null && medicine.notes!.trim().isNotEmpty)
        'Notes: ${medicine.notes}',
    ];

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _medicineName(medicine),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...details.map(
            (line) => pw.Text(line, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  String _childName(Child child) {
    final name = '${child.firstName} ${child.lastName}'.trim();
    return name.isEmpty ? 'Child' : name;
  }

  String _medicineName(Medicine medicine) {
    if (medicine.alias.trim().isEmpty) {
      return medicine.name;
    }
    return '${medicine.name} (${medicine.alias})';
  }
}

final medicineSummaryPdfServiceProvider = Provider<MedicineSummaryPdfService>((
  ref,
) {
  return MedicineSummaryPdfService();
});
