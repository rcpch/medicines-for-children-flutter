// PDF generation for medication schedules.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/models/child.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/primary_carer.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';
import 'package:medicines_for_children_flutter/core/pdf/pdf_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SchedulePdfService {
  Future<Uint8List> buildPdf({
    required PrimaryCarer carer,
    required Child child,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final doc = pw.Document();
    final theme = await loadPdfTheme();

    final medicinesById = {for (final med in child.medicines) med.id: med};
    final dateRange =
        '${DateFormat.yMMMd().format(dateFrom)} - ${DateFormat.yMMMd().format(dateTo)}';

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'Medicines schedule',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Child: ${_childName(child)}'),
          pw.Text('Carer: ${carer.firstName} ${carer.lastName}'.trim()),
          pw.Text('Schedule range: $dateRange'),
          pw.SizedBox(height: 16),
          if (child.schedules.isEmpty)
            pw.Text('No schedules recorded.')
          else
            ...child.schedules.map((schedule) {
              final medicine = medicinesById[schedule.medicineId];
              return _scheduleBlock(schedule, medicine);
            }),
          if (child.asNeededSchedules.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'As-needed medicines',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            ...child.asNeededSchedules.map((schedule) {
              final medicine = medicinesById[schedule.medicineId];
              return pw.Text(
                medicine == null ? 'Medicine' : _medicineName(medicine),
              );
            }),
          ],
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _scheduleBlock(MedicineSchedule schedule, Medicine? medicine) {
    final times = schedule.times.isEmpty
        ? 'No times recorded'
        : schedule.times.join(', ');
    final dateRange =
        '${DateFormat.yMMMd().format(schedule.startDate)} - ${DateFormat.yMMMd().format(schedule.endDate)}';
    final title = medicine == null ? 'Medicine' : _medicineName(medicine);

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
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Times: $times', style: const pw.TextStyle(fontSize: 11)),
          if (medicine != null)
            pw.Text(
              'Dose: ${medicine.dose} ${medicine.doseUnit} · Route: ${medicine.route}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          pw.Text('Range: $dateRange', style: const pw.TextStyle(fontSize: 11)),
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

final schedulePdfServiceProvider = Provider<SchedulePdfService>((ref) {
  return SchedulePdfService();
});
