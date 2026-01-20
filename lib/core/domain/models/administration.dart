// Administration domain model (dose event).
import 'package:freezed_annotation/freezed_annotation.dart';

part 'administration.freezed.dart';
part 'administration.g.dart';

/// Status values for a medication administration.
@JsonEnum()
enum AdministrationStatus { scheduled, given, skipped }

/// Represents a single administration event for a medicine.
@freezed
abstract class Administration with _$Administration {
  const factory Administration({
    required String id,
    required DateTime dateTime,
    required AdministrationStatus status,
    required bool isAsNeeded,
    String? administeredBy,
    String? notes,
  }) = _Administration;

  /// Builds an administration model from a JSON map.
  factory Administration.fromJson(Map<String, dynamic> json) =>
      _$AdministrationFromJson(json);
}
