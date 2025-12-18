// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'administration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Administration _$AdministrationFromJson(Map<String, dynamic> json) {
  return _Administration.fromJson(json);
}

/// @nodoc
mixin _$Administration {
  String get id => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;
  AdministrationStatus get status => throw _privateConstructorUsedError;
  bool get isAsNeeded => throw _privateConstructorUsedError;
  String? get administeredBy => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Administration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Administration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdministrationCopyWith<Administration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdministrationCopyWith<$Res> {
  factory $AdministrationCopyWith(
    Administration value,
    $Res Function(Administration) then,
  ) = _$AdministrationCopyWithImpl<$Res, Administration>;
  @useResult
  $Res call({
    String id,
    DateTime dateTime,
    AdministrationStatus status,
    bool isAsNeeded,
    String? administeredBy,
    String? notes,
  });
}

/// @nodoc
class _$AdministrationCopyWithImpl<$Res, $Val extends Administration>
    implements $AdministrationCopyWith<$Res> {
  _$AdministrationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Administration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateTime = null,
    Object? status = null,
    Object? isAsNeeded = null,
    Object? administeredBy = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dateTime: null == dateTime
                ? _value.dateTime
                : dateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AdministrationStatus,
            isAsNeeded: null == isAsNeeded
                ? _value.isAsNeeded
                : isAsNeeded // ignore: cast_nullable_to_non_nullable
                      as bool,
            administeredBy: freezed == administeredBy
                ? _value.administeredBy
                : administeredBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdministrationImplCopyWith<$Res>
    implements $AdministrationCopyWith<$Res> {
  factory _$$AdministrationImplCopyWith(
    _$AdministrationImpl value,
    $Res Function(_$AdministrationImpl) then,
  ) = __$$AdministrationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime dateTime,
    AdministrationStatus status,
    bool isAsNeeded,
    String? administeredBy,
    String? notes,
  });
}

/// @nodoc
class __$$AdministrationImplCopyWithImpl<$Res>
    extends _$AdministrationCopyWithImpl<$Res, _$AdministrationImpl>
    implements _$$AdministrationImplCopyWith<$Res> {
  __$$AdministrationImplCopyWithImpl(
    _$AdministrationImpl _value,
    $Res Function(_$AdministrationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Administration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateTime = null,
    Object? status = null,
    Object? isAsNeeded = null,
    Object? administeredBy = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$AdministrationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dateTime: null == dateTime
            ? _value.dateTime
            : dateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AdministrationStatus,
        isAsNeeded: null == isAsNeeded
            ? _value.isAsNeeded
            : isAsNeeded // ignore: cast_nullable_to_non_nullable
                  as bool,
        administeredBy: freezed == administeredBy
            ? _value.administeredBy
            : administeredBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdministrationImpl implements _Administration {
  const _$AdministrationImpl({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.isAsNeeded,
    this.administeredBy,
    this.notes,
  });

  factory _$AdministrationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdministrationImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime dateTime;
  @override
  final AdministrationStatus status;
  @override
  final bool isAsNeeded;
  @override
  final String? administeredBy;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Administration(id: $id, dateTime: $dateTime, status: $status, isAsNeeded: $isAsNeeded, administeredBy: $administeredBy, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdministrationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isAsNeeded, isAsNeeded) ||
                other.isAsNeeded == isAsNeeded) &&
            (identical(other.administeredBy, administeredBy) ||
                other.administeredBy == administeredBy) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    dateTime,
    status,
    isAsNeeded,
    administeredBy,
    notes,
  );

  /// Create a copy of Administration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdministrationImplCopyWith<_$AdministrationImpl> get copyWith =>
      __$$AdministrationImplCopyWithImpl<_$AdministrationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdministrationImplToJson(this);
  }
}

abstract class _Administration implements Administration {
  const factory _Administration({
    required final String id,
    required final DateTime dateTime,
    required final AdministrationStatus status,
    required final bool isAsNeeded,
    final String? administeredBy,
    final String? notes,
  }) = _$AdministrationImpl;

  factory _Administration.fromJson(Map<String, dynamic> json) =
      _$AdministrationImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get dateTime;
  @override
  AdministrationStatus get status;
  @override
  bool get isAsNeeded;
  @override
  String? get administeredBy;
  @override
  String? get notes;

  /// Create a copy of Administration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdministrationImplCopyWith<_$AdministrationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
