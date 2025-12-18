// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicineScheduleImpl _$$MedicineScheduleImplFromJson(
  Map<String, dynamic> json,
) => _$MedicineScheduleImpl(
  id: json['id'] as String,
  medicineId: json['medicineId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  times: (json['times'] as List<dynamic>).map((e) => e as String).toList(),
  weekdaysActive: (json['weekdaysActive'] as List<dynamic>)
      .map((e) => e as bool)
      .toList(),
  administrations: (json['administrations'] as List<dynamic>)
      .map((e) => Administration.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$MedicineScheduleImplToJson(
  _$MedicineScheduleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicineId': instance.medicineId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'times': instance.times,
  'weekdaysActive': instance.weekdaysActive,
  'administrations': instance.administrations,
};

_$AsNeededScheduleImpl _$$AsNeededScheduleImplFromJson(
  Map<String, dynamic> json,
) => _$AsNeededScheduleImpl(
  id: json['id'] as String,
  medicineId: json['medicineId'] as String,
  administrations: (json['administrations'] as List<dynamic>)
      .map((e) => Administration.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AsNeededScheduleImplToJson(
  _$AsNeededScheduleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicineId': instance.medicineId,
  'administrations': instance.administrations,
};
