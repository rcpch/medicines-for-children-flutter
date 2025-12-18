// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Medicine _$MedicineFromJson(Map<String, dynamic> json) {
  return _Medicine.fromJson(json);
}

/// @nodoc
mixin _$Medicine {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  MedicineType get type => throw _privateConstructorUsedError;
  String get dose => throw _privateConstructorUsedError;
  String get doseUnit => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this Medicine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicineCopyWith<Medicine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicineCopyWith<$Res> {
  factory $MedicineCopyWith(Medicine value, $Res Function(Medicine) then) =
      _$MedicineCopyWithImpl<$Res, Medicine>;
  @useResult
  $Res call({
    String id,
    String name,
    String alias,
    MedicineType type,
    String dose,
    String doseUnit,
    String route,
    String frequency,
    String? notes,
    String? photoUrl,
  });
}

/// @nodoc
class _$MedicineCopyWithImpl<$Res, $Val extends Medicine>
    implements $MedicineCopyWith<$Res> {
  _$MedicineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? alias = null,
    Object? type = null,
    Object? dose = null,
    Object? doseUnit = null,
    Object? route = null,
    Object? frequency = null,
    Object? notes = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            alias: null == alias
                ? _value.alias
                : alias // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MedicineType,
            dose: null == dose
                ? _value.dose
                : dose // ignore: cast_nullable_to_non_nullable
                      as String,
            doseUnit: null == doseUnit
                ? _value.doseUnit
                : doseUnit // ignore: cast_nullable_to_non_nullable
                      as String,
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicineImplCopyWith<$Res>
    implements $MedicineCopyWith<$Res> {
  factory _$$MedicineImplCopyWith(
    _$MedicineImpl value,
    $Res Function(_$MedicineImpl) then,
  ) = __$$MedicineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String alias,
    MedicineType type,
    String dose,
    String doseUnit,
    String route,
    String frequency,
    String? notes,
    String? photoUrl,
  });
}

/// @nodoc
class __$$MedicineImplCopyWithImpl<$Res>
    extends _$MedicineCopyWithImpl<$Res, _$MedicineImpl>
    implements _$$MedicineImplCopyWith<$Res> {
  __$$MedicineImplCopyWithImpl(
    _$MedicineImpl _value,
    $Res Function(_$MedicineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? alias = null,
    Object? type = null,
    Object? dose = null,
    Object? doseUnit = null,
    Object? route = null,
    Object? frequency = null,
    Object? notes = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _$MedicineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        alias: null == alias
            ? _value.alias
            : alias // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MedicineType,
        dose: null == dose
            ? _value.dose
            : dose // ignore: cast_nullable_to_non_nullable
                  as String,
        doseUnit: null == doseUnit
            ? _value.doseUnit
            : doseUnit // ignore: cast_nullable_to_non_nullable
                  as String,
        route: null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicineImpl implements _Medicine {
  const _$MedicineImpl({
    required this.id,
    required this.name,
    required this.alias,
    required this.type,
    required this.dose,
    required this.doseUnit,
    required this.route,
    required this.frequency,
    this.notes,
    this.photoUrl,
  });

  factory _$MedicineImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicineImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String alias;
  @override
  final MedicineType type;
  @override
  final String dose;
  @override
  final String doseUnit;
  @override
  final String route;
  @override
  final String frequency;
  @override
  final String? notes;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, alias: $alias, type: $type, dose: $dose, doseUnit: $doseUnit, route: $route, frequency: $frequency, notes: $notes, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.dose, dose) || other.dose == dose) &&
            (identical(other.doseUnit, doseUnit) ||
                other.doseUnit == doseUnit) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    alias,
    type,
    dose,
    doseUnit,
    route,
    frequency,
    notes,
    photoUrl,
  );

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      __$$MedicineImplCopyWithImpl<_$MedicineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicineImplToJson(this);
  }
}

abstract class _Medicine implements Medicine {
  const factory _Medicine({
    required final String id,
    required final String name,
    required final String alias,
    required final MedicineType type,
    required final String dose,
    required final String doseUnit,
    required final String route,
    required final String frequency,
    final String? notes,
    final String? photoUrl,
  }) = _$MedicineImpl;

  factory _Medicine.fromJson(Map<String, dynamic> json) =
      _$MedicineImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get alias;
  @override
  MedicineType get type;
  @override
  String get dose;
  @override
  String get doseUnit;
  @override
  String get route;
  @override
  String get frequency;
  @override
  String? get notes;
  @override
  String? get photoUrl;

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
