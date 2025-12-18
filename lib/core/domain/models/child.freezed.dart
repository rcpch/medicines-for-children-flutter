// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Child _$ChildFromJson(Map<String, dynamic> json) {
  return _Child.fromJson(json);
}

/// @nodoc
mixin _$Child {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<Medicine> get medicines => throw _privateConstructorUsedError;
  List<MedicineSchedule> get schedules => throw _privateConstructorUsedError;
  List<AsNeededSchedule> get asNeededSchedules =>
      throw _privateConstructorUsedError;

  /// Serializes this Child to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildCopyWith<Child> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildCopyWith<$Res> {
  factory $ChildCopyWith(Child value, $Res Function(Child) then) =
      _$ChildCopyWithImpl<$Res, Child>;
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    DateTime dateOfBirth,
    String condition,
    List<String> allergies,
    List<Medicine> medicines,
    List<MedicineSchedule> schedules,
    List<AsNeededSchedule> asNeededSchedules,
  });
}

/// @nodoc
class _$ChildCopyWithImpl<$Res, $Val extends Child>
    implements $ChildCopyWith<$Res> {
  _$ChildCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? dateOfBirth = null,
    Object? condition = null,
    Object? allergies = null,
    Object? medicines = null,
    Object? schedules = null,
    Object? asNeededSchedules = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            condition: null == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String,
            allergies: null == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            medicines: null == medicines
                ? _value.medicines
                : medicines // ignore: cast_nullable_to_non_nullable
                      as List<Medicine>,
            schedules: null == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<MedicineSchedule>,
            asNeededSchedules: null == asNeededSchedules
                ? _value.asNeededSchedules
                : asNeededSchedules // ignore: cast_nullable_to_non_nullable
                      as List<AsNeededSchedule>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChildImplCopyWith<$Res> implements $ChildCopyWith<$Res> {
  factory _$$ChildImplCopyWith(
    _$ChildImpl value,
    $Res Function(_$ChildImpl) then,
  ) = __$$ChildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    DateTime dateOfBirth,
    String condition,
    List<String> allergies,
    List<Medicine> medicines,
    List<MedicineSchedule> schedules,
    List<AsNeededSchedule> asNeededSchedules,
  });
}

/// @nodoc
class __$$ChildImplCopyWithImpl<$Res>
    extends _$ChildCopyWithImpl<$Res, _$ChildImpl>
    implements _$$ChildImplCopyWith<$Res> {
  __$$ChildImplCopyWithImpl(
    _$ChildImpl _value,
    $Res Function(_$ChildImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? dateOfBirth = null,
    Object? condition = null,
    Object? allergies = null,
    Object? medicines = null,
    Object? schedules = null,
    Object? asNeededSchedules = null,
  }) {
    return _then(
      _$ChildImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        condition: null == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String,
        allergies: null == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        medicines: null == medicines
            ? _value._medicines
            : medicines // ignore: cast_nullable_to_non_nullable
                  as List<Medicine>,
        schedules: null == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<MedicineSchedule>,
        asNeededSchedules: null == asNeededSchedules
            ? _value._asNeededSchedules
            : asNeededSchedules // ignore: cast_nullable_to_non_nullable
                  as List<AsNeededSchedule>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildImpl implements _Child {
  const _$ChildImpl({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.condition,
    required final List<String> allergies,
    required final List<Medicine> medicines,
    required final List<MedicineSchedule> schedules,
    required final List<AsNeededSchedule> asNeededSchedules,
  }) : _allergies = allergies,
       _medicines = medicines,
       _schedules = schedules,
       _asNeededSchedules = asNeededSchedules;

  factory _$ChildImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildImplFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final DateTime dateOfBirth;
  @override
  final String condition;
  final List<String> _allergies;
  @override
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<Medicine> _medicines;
  @override
  List<Medicine> get medicines {
    if (_medicines is EqualUnmodifiableListView) return _medicines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medicines);
  }

  final List<MedicineSchedule> _schedules;
  @override
  List<MedicineSchedule> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  final List<AsNeededSchedule> _asNeededSchedules;
  @override
  List<AsNeededSchedule> get asNeededSchedules {
    if (_asNeededSchedules is EqualUnmodifiableListView)
      return _asNeededSchedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_asNeededSchedules);
  }

  @override
  String toString() {
    return 'Child(id: $id, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, condition: $condition, allergies: $allergies, medicines: $medicines, schedules: $schedules, asNeededSchedules: $asNeededSchedules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._medicines,
              _medicines,
            ) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            const DeepCollectionEquality().equals(
              other._asNeededSchedules,
              _asNeededSchedules,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    firstName,
    lastName,
    dateOfBirth,
    condition,
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_medicines),
    const DeepCollectionEquality().hash(_schedules),
    const DeepCollectionEquality().hash(_asNeededSchedules),
  );

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      __$$ChildImplCopyWithImpl<_$ChildImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildImplToJson(this);
  }
}

abstract class _Child implements Child {
  const factory _Child({
    required final String id,
    required final String firstName,
    required final String lastName,
    required final DateTime dateOfBirth,
    required final String condition,
    required final List<String> allergies,
    required final List<Medicine> medicines,
    required final List<MedicineSchedule> schedules,
    required final List<AsNeededSchedule> asNeededSchedules,
  }) = _$ChildImpl;

  factory _Child.fromJson(Map<String, dynamic> json) = _$ChildImpl.fromJson;

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  DateTime get dateOfBirth;
  @override
  String get condition;
  @override
  List<String> get allergies;
  @override
  List<Medicine> get medicines;
  @override
  List<MedicineSchedule> get schedules;
  @override
  List<AsNeededSchedule> get asNeededSchedules;

  /// Create a copy of Child
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildImplCopyWith<_$ChildImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
