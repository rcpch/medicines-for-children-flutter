// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildImpl _$$ChildImplFromJson(Map<String, dynamic> json) => _$ChildImpl(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  condition: json['condition'] as String,
  allergies: (json['allergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicines: (json['medicines'] as List<dynamic>)
      .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
      .toList(),
  schedules: (json['schedules'] as List<dynamic>)
      .map((e) => MedicineSchedule.fromJson(e as Map<String, dynamic>))
      .toList(),
  asNeededSchedules: (json['asNeededSchedules'] as List<dynamic>)
      .map((e) => AsNeededSchedule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ChildImplToJson(_$ChildImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'condition': instance.condition,
      'allergies': instance.allergies,
      'medicines': instance.medicines,
      'schedules': instance.schedules,
      'asNeededSchedules': instance.asNeededSchedules,
    };
