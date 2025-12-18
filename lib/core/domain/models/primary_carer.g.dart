// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'primary_carer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrimaryCarerImpl _$$PrimaryCarerImplFromJson(Map<String, dynamic> json) =>
    _$PrimaryCarerImpl(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      relationshipToChild: json['relationshipToChild'] as String,
      children: (json['children'] as List<dynamic>)
          .map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PrimaryCarerImplToJson(_$PrimaryCarerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'relationshipToChild': instance.relationshipToChild,
      'children': instance.children,
    };
