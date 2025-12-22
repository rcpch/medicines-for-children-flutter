// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Administration _$AdministrationFromJson(Map<String, dynamic> json) =>
    _Administration(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: $enumDecode(_$AdministrationStatusEnumMap, json['status']),
      isAsNeeded: json['isAsNeeded'] as bool,
      administeredBy: json['administeredBy'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AdministrationToJson(_Administration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dateTime': instance.dateTime.toIso8601String(),
      'status': _$AdministrationStatusEnumMap[instance.status]!,
      'isAsNeeded': instance.isAsNeeded,
      'administeredBy': instance.administeredBy,
      'notes': instance.notes,
    };

const _$AdministrationStatusEnumMap = {
  AdministrationStatus.scheduled: 'scheduled',
  AdministrationStatus.given: 'given',
  AdministrationStatus.skipped: 'skipped',
};
