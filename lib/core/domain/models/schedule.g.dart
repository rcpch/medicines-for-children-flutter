// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicineSchedule _$MedicineScheduleFromJson(Map<String, dynamic> json) =>
    _MedicineSchedule(
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

Map<String, dynamic> _$MedicineScheduleToJson(_MedicineSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicineId': instance.medicineId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'times': instance.times,
      'weekdaysActive': instance.weekdaysActive,
      'administrations': instance.administrations,
    };

_AsNeededSchedule _$AsNeededScheduleFromJson(Map<String, dynamic> json) =>
    _AsNeededSchedule(
      id: json['id'] as String,
      medicineId: json['medicineId'] as String,
      administrations: (json['administrations'] as List<dynamic>)
          .map((e) => Administration.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AsNeededScheduleToJson(_AsNeededSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicineId': instance.medicineId,
      'administrations': instance.administrations,
    };
