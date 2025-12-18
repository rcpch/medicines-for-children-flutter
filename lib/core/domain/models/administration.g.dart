// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdministrationImpl _$$AdministrationImplFromJson(Map<String, dynamic> json) =>
    _$AdministrationImpl(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: $enumDecode(_$AdministrationStatusEnumMap, json['status']),
      isAsNeeded: json['isAsNeeded'] as bool,
      administeredBy: json['administeredBy'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$AdministrationImplToJson(
  _$AdministrationImpl instance,
) => <String, dynamic>{
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
