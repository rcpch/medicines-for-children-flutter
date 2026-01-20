// Medication schedule domain model.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medicines_for_children_flutter/core/domain/models/administration.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

// Represents a scheduled medicine regimen with specific times.
@freezed
abstract class MedicineSchedule with _$MedicineSchedule {
  const factory MedicineSchedule({
    required String id,
    required String medicineId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> times,
    required List<bool> weekdaysActive,
    required List<Administration> administrations,
  }) = _MedicineSchedule;

  // Builds a medicine schedule model from a JSON map.
  factory MedicineSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicineScheduleFromJson(json);
}

// Represents an as-needed medicine schedule.
@freezed
abstract class AsNeededSchedule with _$AsNeededSchedule {
  const factory AsNeededSchedule({
    required String id,
    required String medicineId,
    required List<Administration> administrations,
  }) = _AsNeededSchedule;

  // Builds an as-needed schedule model from a JSON map.
  factory AsNeededSchedule.fromJson(Map<String, dynamic> json) =>
      _$AsNeededScheduleFromJson(json);
}
