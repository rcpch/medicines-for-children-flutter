// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicineSchedule _$MedicineScheduleFromJson(Map<String, dynamic> json) {
  return _MedicineSchedule.fromJson(json);
}

/// @nodoc
mixin _$MedicineSchedule {
  String get id => throw _privateConstructorUsedError;
  String get medicineId => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  List<String> get times => throw _privateConstructorUsedError;
  List<bool> get weekdaysActive => throw _privateConstructorUsedError;
  List<Administration> get administrations =>
      throw _privateConstructorUsedError;

  /// Serializes this MedicineSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicineScheduleCopyWith<MedicineSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicineScheduleCopyWith<$Res> {
  factory $MedicineScheduleCopyWith(
    MedicineSchedule value,
    $Res Function(MedicineSchedule) then,
  ) = _$MedicineScheduleCopyWithImpl<$Res, MedicineSchedule>;
  @useResult
  $Res call({
    String id,
    String medicineId,
    DateTime startDate,
    DateTime endDate,
    List<String> times,
    List<bool> weekdaysActive,
    List<Administration> administrations,
  });
}

/// @nodoc
class _$MedicineScheduleCopyWithImpl<$Res, $Val extends MedicineSchedule>
    implements $MedicineScheduleCopyWith<$Res> {
  _$MedicineScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicineId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? times = null,
    Object? weekdaysActive = null,
    Object? administrations = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            medicineId: null == medicineId
                ? _value.medicineId
                : medicineId // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            times: null == times
                ? _value.times
                : times // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            weekdaysActive: null == weekdaysActive
                ? _value.weekdaysActive
                : weekdaysActive // ignore: cast_nullable_to_non_nullable
                      as List<bool>,
            administrations: null == administrations
                ? _value.administrations
                : administrations // ignore: cast_nullable_to_non_nullable
                      as List<Administration>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicineScheduleImplCopyWith<$Res>
    implements $MedicineScheduleCopyWith<$Res> {
  factory _$$MedicineScheduleImplCopyWith(
    _$MedicineScheduleImpl value,
    $Res Function(_$MedicineScheduleImpl) then,
  ) = __$$MedicineScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String medicineId,
    DateTime startDate,
    DateTime endDate,
    List<String> times,
    List<bool> weekdaysActive,
    List<Administration> administrations,
  });
}

/// @nodoc
class __$$MedicineScheduleImplCopyWithImpl<$Res>
    extends _$MedicineScheduleCopyWithImpl<$Res, _$MedicineScheduleImpl>
    implements _$$MedicineScheduleImplCopyWith<$Res> {
  __$$MedicineScheduleImplCopyWithImpl(
    _$MedicineScheduleImpl _value,
    $Res Function(_$MedicineScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicineId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? times = null,
    Object? weekdaysActive = null,
    Object? administrations = null,
  }) {
    return _then(
      _$MedicineScheduleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        medicineId: null == medicineId
            ? _value.medicineId
            : medicineId // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        times: null == times
            ? _value._times
            : times // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        weekdaysActive: null == weekdaysActive
            ? _value._weekdaysActive
            : weekdaysActive // ignore: cast_nullable_to_non_nullable
                  as List<bool>,
        administrations: null == administrations
            ? _value._administrations
            : administrations // ignore: cast_nullable_to_non_nullable
                  as List<Administration>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicineScheduleImpl implements _MedicineSchedule {
  const _$MedicineScheduleImpl({
    required this.id,
    required this.medicineId,
    required this.startDate,
    required this.endDate,
    required final List<String> times,
    required final List<bool> weekdaysActive,
    required final List<Administration> administrations,
  }) : _times = times,
       _weekdaysActive = weekdaysActive,
       _administrations = administrations;

  factory _$MedicineScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicineScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String medicineId;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  final List<String> _times;
  @override
  List<String> get times {
    if (_times is EqualUnmodifiableListView) return _times;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_times);
  }

  final List<bool> _weekdaysActive;
  @override
  List<bool> get weekdaysActive {
    if (_weekdaysActive is EqualUnmodifiableListView) return _weekdaysActive;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdaysActive);
  }

  final List<Administration> _administrations;
  @override
  List<Administration> get administrations {
    if (_administrations is EqualUnmodifiableListView) return _administrations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_administrations);
  }

  @override
  String toString() {
    return 'MedicineSchedule(id: $id, medicineId: $medicineId, startDate: $startDate, endDate: $endDate, times: $times, weekdaysActive: $weekdaysActive, administrations: $administrations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicineScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.medicineId, medicineId) ||
                other.medicineId == medicineId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._times, _times) &&
            const DeepCollectionEquality().equals(
              other._weekdaysActive,
              _weekdaysActive,
            ) &&
            const DeepCollectionEquality().equals(
              other._administrations,
              _administrations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    medicineId,
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_times),
    const DeepCollectionEquality().hash(_weekdaysActive),
    const DeepCollectionEquality().hash(_administrations),
  );

  /// Create a copy of MedicineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicineScheduleImplCopyWith<_$MedicineScheduleImpl> get copyWith =>
      __$$MedicineScheduleImplCopyWithImpl<_$MedicineScheduleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicineScheduleImplToJson(this);
  }
}

abstract class _MedicineSchedule implements MedicineSchedule {
  const factory _MedicineSchedule({
    required final String id,
    required final String medicineId,
    required final DateTime startDate,
    required final DateTime endDate,
    required final List<String> times,
    required final List<bool> weekdaysActive,
    required final List<Administration> administrations,
  }) = _$MedicineScheduleImpl;

  factory _MedicineSchedule.fromJson(Map<String, dynamic> json) =
      _$MedicineScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get medicineId;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  List<String> get times;
  @override
  List<bool> get weekdaysActive;
  @override
  List<Administration> get administrations;

  /// Create a copy of MedicineSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicineScheduleImplCopyWith<_$MedicineScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AsNeededSchedule _$AsNeededScheduleFromJson(Map<String, dynamic> json) {
  return _AsNeededSchedule.fromJson(json);
}

/// @nodoc
mixin _$AsNeededSchedule {
  String get id => throw _privateConstructorUsedError;
  String get medicineId => throw _privateConstructorUsedError;
  List<Administration> get administrations =>
      throw _privateConstructorUsedError;

  /// Serializes this AsNeededSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AsNeededSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AsNeededScheduleCopyWith<AsNeededSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AsNeededScheduleCopyWith<$Res> {
  factory $AsNeededScheduleCopyWith(
    AsNeededSchedule value,
    $Res Function(AsNeededSchedule) then,
  ) = _$AsNeededScheduleCopyWithImpl<$Res, AsNeededSchedule>;
  @useResult
  $Res call({
    String id,
    String medicineId,
    List<Administration> administrations,
  });
}

/// @nodoc
class _$AsNeededScheduleCopyWithImpl<$Res, $Val extends AsNeededSchedule>
    implements $AsNeededScheduleCopyWith<$Res> {
  _$AsNeededScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AsNeededSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicineId = null,
    Object? administrations = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            medicineId: null == medicineId
                ? _value.medicineId
                : medicineId // ignore: cast_nullable_to_non_nullable
                      as String,
            administrations: null == administrations
                ? _value.administrations
                : administrations // ignore: cast_nullable_to_non_nullable
                      as List<Administration>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AsNeededScheduleImplCopyWith<$Res>
    implements $AsNeededScheduleCopyWith<$Res> {
  factory _$$AsNeededScheduleImplCopyWith(
    _$AsNeededScheduleImpl value,
    $Res Function(_$AsNeededScheduleImpl) then,
  ) = __$$AsNeededScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String medicineId,
    List<Administration> administrations,
  });
}

/// @nodoc
class __$$AsNeededScheduleImplCopyWithImpl<$Res>
    extends _$AsNeededScheduleCopyWithImpl<$Res, _$AsNeededScheduleImpl>
    implements _$$AsNeededScheduleImplCopyWith<$Res> {
  __$$AsNeededScheduleImplCopyWithImpl(
    _$AsNeededScheduleImpl _value,
    $Res Function(_$AsNeededScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AsNeededSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicineId = null,
    Object? administrations = null,
  }) {
    return _then(
      _$AsNeededScheduleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        medicineId: null == medicineId
            ? _value.medicineId
            : medicineId // ignore: cast_nullable_to_non_nullable
                  as String,
        administrations: null == administrations
            ? _value._administrations
            : administrations // ignore: cast_nullable_to_non_nullable
                  as List<Administration>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AsNeededScheduleImpl implements _AsNeededSchedule {
  const _$AsNeededScheduleImpl({
    required this.id,
    required this.medicineId,
    required final List<Administration> administrations,
  }) : _administrations = administrations;

  factory _$AsNeededScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AsNeededScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String medicineId;
  final List<Administration> _administrations;
  @override
  List<Administration> get administrations {
    if (_administrations is EqualUnmodifiableListView) return _administrations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_administrations);
  }

  @override
  String toString() {
    return 'AsNeededSchedule(id: $id, medicineId: $medicineId, administrations: $administrations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AsNeededScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.medicineId, medicineId) ||
                other.medicineId == medicineId) &&
            const DeepCollectionEquality().equals(
              other._administrations,
              _administrations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    medicineId,
    const DeepCollectionEquality().hash(_administrations),
  );

  /// Create a copy of AsNeededSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AsNeededScheduleImplCopyWith<_$AsNeededScheduleImpl> get copyWith =>
      __$$AsNeededScheduleImplCopyWithImpl<_$AsNeededScheduleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AsNeededScheduleImplToJson(this);
  }
}

abstract class _AsNeededSchedule implements AsNeededSchedule {
  const factory _AsNeededSchedule({
    required final String id,
    required final String medicineId,
    required final List<Administration> administrations,
  }) = _$AsNeededScheduleImpl;

  factory _AsNeededSchedule.fromJson(Map<String, dynamic> json) =
      _$AsNeededScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get medicineId;
  @override
  List<Administration> get administrations;

  /// Create a copy of AsNeededSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AsNeededScheduleImplCopyWith<_$AsNeededScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
