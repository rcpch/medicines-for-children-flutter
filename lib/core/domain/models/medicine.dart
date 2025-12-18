import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine.freezed.dart';
part 'medicine.g.dart';

@JsonEnum()
enum MedicineType { everyday, asNeeded, both }

@freezed
class Medicine with _$Medicine {
  const factory Medicine({
    required String id,
    required String name,
    required String alias,
    required MedicineType type,
    required String dose,
    required String doseUnit,
    required String route,
    required String frequency,
    String? notes,
    String? photoUrl,
  }) = _Medicine;

  factory Medicine.fromJson(Map<String, dynamic> json) => _$MedicineFromJson(json);
}
