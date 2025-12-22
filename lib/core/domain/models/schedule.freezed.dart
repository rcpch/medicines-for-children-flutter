// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicineSchedule {

 String get id; String get medicineId; DateTime get startDate; DateTime get endDate; List<String> get times; List<bool> get weekdaysActive; List<Administration> get administrations;
/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineScheduleCopyWith<MedicineSchedule> get copyWith => _$MedicineScheduleCopyWithImpl<MedicineSchedule>(this as MedicineSchedule, _$identity);

  /// Serializes this MedicineSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicineSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.medicineId, medicineId) || other.medicineId == medicineId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.times, times)&&const DeepCollectionEquality().equals(other.weekdaysActive, weekdaysActive)&&const DeepCollectionEquality().equals(other.administrations, administrations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,medicineId,startDate,endDate,const DeepCollectionEquality().hash(times),const DeepCollectionEquality().hash(weekdaysActive),const DeepCollectionEquality().hash(administrations));

@override
String toString() {
  return 'MedicineSchedule(id: $id, medicineId: $medicineId, startDate: $startDate, endDate: $endDate, times: $times, weekdaysActive: $weekdaysActive, administrations: $administrations)';
}


}

/// @nodoc
abstract mixin class $MedicineScheduleCopyWith<$Res>  {
  factory $MedicineScheduleCopyWith(MedicineSchedule value, $Res Function(MedicineSchedule) _then) = _$MedicineScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String medicineId, DateTime startDate, DateTime endDate, List<String> times, List<bool> weekdaysActive, List<Administration> administrations
});




}
/// @nodoc
class _$MedicineScheduleCopyWithImpl<$Res>
    implements $MedicineScheduleCopyWith<$Res> {
  _$MedicineScheduleCopyWithImpl(this._self, this._then);

  final MedicineSchedule _self;
  final $Res Function(MedicineSchedule) _then;

/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? medicineId = null,Object? startDate = null,Object? endDate = null,Object? times = null,Object? weekdaysActive = null,Object? administrations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicineId: null == medicineId ? _self.medicineId : medicineId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,times: null == times ? _self.times : times // ignore: cast_nullable_to_non_nullable
as List<String>,weekdaysActive: null == weekdaysActive ? _self.weekdaysActive : weekdaysActive // ignore: cast_nullable_to_non_nullable
as List<bool>,administrations: null == administrations ? _self.administrations : administrations // ignore: cast_nullable_to_non_nullable
as List<Administration>,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicineSchedule].
extension MedicineSchedulePatterns on MedicineSchedule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicineSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicineSchedule value)  $default,){
final _that = this;
switch (_that) {
case _MedicineSchedule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicineSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String medicineId,  DateTime startDate,  DateTime endDate,  List<String> times,  List<bool> weekdaysActive,  List<Administration> administrations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
return $default(_that.id,_that.medicineId,_that.startDate,_that.endDate,_that.times,_that.weekdaysActive,_that.administrations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String medicineId,  DateTime startDate,  DateTime endDate,  List<String> times,  List<bool> weekdaysActive,  List<Administration> administrations)  $default,) {final _that = this;
switch (_that) {
case _MedicineSchedule():
return $default(_that.id,_that.medicineId,_that.startDate,_that.endDate,_that.times,_that.weekdaysActive,_that.administrations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String medicineId,  DateTime startDate,  DateTime endDate,  List<String> times,  List<bool> weekdaysActive,  List<Administration> administrations)?  $default,) {final _that = this;
switch (_that) {
case _MedicineSchedule() when $default != null:
return $default(_that.id,_that.medicineId,_that.startDate,_that.endDate,_that.times,_that.weekdaysActive,_that.administrations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicineSchedule implements MedicineSchedule {
  const _MedicineSchedule({required this.id, required this.medicineId, required this.startDate, required this.endDate, required final  List<String> times, required final  List<bool> weekdaysActive, required final  List<Administration> administrations}): _times = times,_weekdaysActive = weekdaysActive,_administrations = administrations;
  factory _MedicineSchedule.fromJson(Map<String, dynamic> json) => _$MedicineScheduleFromJson(json);

@override final  String id;
@override final  String medicineId;
@override final  DateTime startDate;
@override final  DateTime endDate;
 final  List<String> _times;
@override List<String> get times {
  if (_times is EqualUnmodifiableListView) return _times;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_times);
}

 final  List<bool> _weekdaysActive;
@override List<bool> get weekdaysActive {
  if (_weekdaysActive is EqualUnmodifiableListView) return _weekdaysActive;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekdaysActive);
}

 final  List<Administration> _administrations;
@override List<Administration> get administrations {
  if (_administrations is EqualUnmodifiableListView) return _administrations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_administrations);
}


/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineScheduleCopyWith<_MedicineSchedule> get copyWith => __$MedicineScheduleCopyWithImpl<_MedicineSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicineScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicineSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.medicineId, medicineId) || other.medicineId == medicineId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._times, _times)&&const DeepCollectionEquality().equals(other._weekdaysActive, _weekdaysActive)&&const DeepCollectionEquality().equals(other._administrations, _administrations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,medicineId,startDate,endDate,const DeepCollectionEquality().hash(_times),const DeepCollectionEquality().hash(_weekdaysActive),const DeepCollectionEquality().hash(_administrations));

@override
String toString() {
  return 'MedicineSchedule(id: $id, medicineId: $medicineId, startDate: $startDate, endDate: $endDate, times: $times, weekdaysActive: $weekdaysActive, administrations: $administrations)';
}


}

/// @nodoc
abstract mixin class _$MedicineScheduleCopyWith<$Res> implements $MedicineScheduleCopyWith<$Res> {
  factory _$MedicineScheduleCopyWith(_MedicineSchedule value, $Res Function(_MedicineSchedule) _then) = __$MedicineScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String medicineId, DateTime startDate, DateTime endDate, List<String> times, List<bool> weekdaysActive, List<Administration> administrations
});




}
/// @nodoc
class __$MedicineScheduleCopyWithImpl<$Res>
    implements _$MedicineScheduleCopyWith<$Res> {
  __$MedicineScheduleCopyWithImpl(this._self, this._then);

  final _MedicineSchedule _self;
  final $Res Function(_MedicineSchedule) _then;

/// Create a copy of MedicineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? medicineId = null,Object? startDate = null,Object? endDate = null,Object? times = null,Object? weekdaysActive = null,Object? administrations = null,}) {
  return _then(_MedicineSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicineId: null == medicineId ? _self.medicineId : medicineId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,times: null == times ? _self._times : times // ignore: cast_nullable_to_non_nullable
as List<String>,weekdaysActive: null == weekdaysActive ? _self._weekdaysActive : weekdaysActive // ignore: cast_nullable_to_non_nullable
as List<bool>,administrations: null == administrations ? _self._administrations : administrations // ignore: cast_nullable_to_non_nullable
as List<Administration>,
  ));
}


}


/// @nodoc
mixin _$AsNeededSchedule {

 String get id; String get medicineId; List<Administration> get administrations;
/// Create a copy of AsNeededSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsNeededScheduleCopyWith<AsNeededSchedule> get copyWith => _$AsNeededScheduleCopyWithImpl<AsNeededSchedule>(this as AsNeededSchedule, _$identity);

  /// Serializes this AsNeededSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsNeededSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.medicineId, medicineId) || other.medicineId == medicineId)&&const DeepCollectionEquality().equals(other.administrations, administrations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,medicineId,const DeepCollectionEquality().hash(administrations));

@override
String toString() {
  return 'AsNeededSchedule(id: $id, medicineId: $medicineId, administrations: $administrations)';
}


}

/// @nodoc
abstract mixin class $AsNeededScheduleCopyWith<$Res>  {
  factory $AsNeededScheduleCopyWith(AsNeededSchedule value, $Res Function(AsNeededSchedule) _then) = _$AsNeededScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String medicineId, List<Administration> administrations
});




}
/// @nodoc
class _$AsNeededScheduleCopyWithImpl<$Res>
    implements $AsNeededScheduleCopyWith<$Res> {
  _$AsNeededScheduleCopyWithImpl(this._self, this._then);

  final AsNeededSchedule _self;
  final $Res Function(AsNeededSchedule) _then;

/// Create a copy of AsNeededSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? medicineId = null,Object? administrations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicineId: null == medicineId ? _self.medicineId : medicineId // ignore: cast_nullable_to_non_nullable
as String,administrations: null == administrations ? _self.administrations : administrations // ignore: cast_nullable_to_non_nullable
as List<Administration>,
  ));
}

}


/// Adds pattern-matching-related methods to [AsNeededSchedule].
extension AsNeededSchedulePatterns on AsNeededSchedule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AsNeededSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AsNeededSchedule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AsNeededSchedule value)  $default,){
final _that = this;
switch (_that) {
case _AsNeededSchedule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AsNeededSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _AsNeededSchedule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String medicineId,  List<Administration> administrations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AsNeededSchedule() when $default != null:
return $default(_that.id,_that.medicineId,_that.administrations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String medicineId,  List<Administration> administrations)  $default,) {final _that = this;
switch (_that) {
case _AsNeededSchedule():
return $default(_that.id,_that.medicineId,_that.administrations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String medicineId,  List<Administration> administrations)?  $default,) {final _that = this;
switch (_that) {
case _AsNeededSchedule() when $default != null:
return $default(_that.id,_that.medicineId,_that.administrations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AsNeededSchedule implements AsNeededSchedule {
  const _AsNeededSchedule({required this.id, required this.medicineId, required final  List<Administration> administrations}): _administrations = administrations;
  factory _AsNeededSchedule.fromJson(Map<String, dynamic> json) => _$AsNeededScheduleFromJson(json);

@override final  String id;
@override final  String medicineId;
 final  List<Administration> _administrations;
@override List<Administration> get administrations {
  if (_administrations is EqualUnmodifiableListView) return _administrations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_administrations);
}


/// Create a copy of AsNeededSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AsNeededScheduleCopyWith<_AsNeededSchedule> get copyWith => __$AsNeededScheduleCopyWithImpl<_AsNeededSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AsNeededScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AsNeededSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.medicineId, medicineId) || other.medicineId == medicineId)&&const DeepCollectionEquality().equals(other._administrations, _administrations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,medicineId,const DeepCollectionEquality().hash(_administrations));

@override
String toString() {
  return 'AsNeededSchedule(id: $id, medicineId: $medicineId, administrations: $administrations)';
}


}

/// @nodoc
abstract mixin class _$AsNeededScheduleCopyWith<$Res> implements $AsNeededScheduleCopyWith<$Res> {
  factory _$AsNeededScheduleCopyWith(_AsNeededSchedule value, $Res Function(_AsNeededSchedule) _then) = __$AsNeededScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String medicineId, List<Administration> administrations
});




}
/// @nodoc
class __$AsNeededScheduleCopyWithImpl<$Res>
    implements _$AsNeededScheduleCopyWith<$Res> {
  __$AsNeededScheduleCopyWithImpl(this._self, this._then);

  final _AsNeededSchedule _self;
  final $Res Function(_AsNeededSchedule) _then;

/// Create a copy of AsNeededSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? medicineId = null,Object? administrations = null,}) {
  return _then(_AsNeededSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicineId: null == medicineId ? _self.medicineId : medicineId // ignore: cast_nullable_to_non_nullable
as String,administrations: null == administrations ? _self._administrations : administrations // ignore: cast_nullable_to_non_nullable
as List<Administration>,
  ));
}


}

// dart format on
