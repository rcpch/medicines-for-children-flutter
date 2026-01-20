// Medicine domain model.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine.freezed.dart';
part 'medicine.g.dart';

// Categorizes how a medicine is taken.
@JsonEnum()
enum MedicineType { everyday, asNeeded, both }

// Tracks whether a medicine is currently in use.
@JsonEnum()
enum MedicineStatus { inUse, noLongerUsed }

// Represents a medicine with dosing and metadata.
@freezed
abstract class Medicine with _$Medicine {
  const factory Medicine({
    required String id,
    required String name,
    required String alias,
    required MedicineType type,
    required String dose,
    required String doseUnit,
    required String route,
    required String frequency,
    @Default(MedicineStatus.inUse) MedicineStatus status,
    String? notes,
    String? photoUrl,
    @Default(<String>[]) List<String> photoUrls,
  }) = _Medicine;

  // Builds a medicine model from a JSON map.
  factory Medicine.fromJson(Map<String, dynamic> json) =>
      _$MedicineFromJson(json);
}
