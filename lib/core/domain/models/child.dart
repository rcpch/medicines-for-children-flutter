// Child domain model.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/domain/models/schedule.dart';

part 'child.freezed.dart';
part 'child.g.dart';

/// Represents a child profile and their medicines.
@freezed
abstract class Child with _$Child {
  const factory Child({
    required String id,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String condition,
    required List<String> allergies,
    String? notes,
    String? photoUrl,
    required List<Medicine> medicines,
    required List<MedicineSchedule> schedules,
    required List<AsNeededSchedule> asNeededSchedules,
  }) = _Child;

  /// Builds a child model from a JSON map.
  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);
}
