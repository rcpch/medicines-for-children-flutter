import 'package:freezed_annotation/freezed_annotation.dart';

part 'administration.freezed.dart';
part 'administration.g.dart';

@JsonEnum()
enum AdministrationStatus { scheduled, given, skipped }

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

  factory Administration.fromJson(Map<String, dynamic> json) =>
      _$AdministrationFromJson(json);
}
