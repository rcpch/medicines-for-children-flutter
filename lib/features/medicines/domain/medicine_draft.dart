// Draft model for medicine form edits.
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';

class MedicineDraft {
  const MedicineDraft({
    required this.name,
    required this.alias,
    required this.type,
    required this.dose,
    required this.doseUnit,
    required this.route,
    required this.frequency,
    this.status = MedicineStatus.inUse,
    this.notes,
    this.photoUrl,
    this.photoUrls = const [],
  });

  final String name;
  final String alias;
  final MedicineType type;
  final String dose;
  final String doseUnit;
  final String route;
  final String frequency;
  final MedicineStatus status;
  final String? notes;
  final String? photoUrl;
  final List<String> photoUrls;
}
