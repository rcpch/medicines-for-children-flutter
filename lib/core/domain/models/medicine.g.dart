// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Medicine _$MedicineFromJson(Map<String, dynamic> json) => _Medicine(
  id: json['id'] as String,
  name: json['name'] as String,
  alias: json['alias'] as String,
  type: $enumDecode(_$MedicineTypeEnumMap, json['type']),
  dose: json['dose'] as String,
  doseUnit: json['doseUnit'] as String,
  route: json['route'] as String,
  frequency: json['frequency'] as String,
  notes: json['notes'] as String?,
  photoUrl: json['photoUrl'] as String?,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$MedicineToJson(_Medicine instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'alias': instance.alias,
  'type': _$MedicineTypeEnumMap[instance.type]!,
  'dose': instance.dose,
  'doseUnit': instance.doseUnit,
  'route': instance.route,
  'frequency': instance.frequency,
  'notes': instance.notes,
  'photoUrl': instance.photoUrl,
  'photoUrls': instance.photoUrls,
};

const _$MedicineTypeEnumMap = {
  MedicineType.everyday: 'everyday',
  MedicineType.asNeeded: 'asNeeded',
  MedicineType.both: 'both',
};
