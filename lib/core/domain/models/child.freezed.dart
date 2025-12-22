// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Child {

 String get id; String get firstName; String get lastName; DateTime get dateOfBirth; String get condition; List<String> get allergies; String? get notes; String? get photoUrl; List<Medicine> get medicines; List<MedicineSchedule> get schedules; List<AsNeededSchedule> get asNeededSchedules;
/// Create a copy of Child
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildCopyWith<Child> get copyWith => _$ChildCopyWithImpl<Child>(this as Child, _$identity);

  /// Serializes this Child to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Child&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.condition, condition) || other.condition == condition)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other.medicines, medicines)&&const DeepCollectionEquality().equals(other.schedules, schedules)&&const DeepCollectionEquality().equals(other.asNeededSchedules, asNeededSchedules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,dateOfBirth,condition,const DeepCollectionEquality().hash(allergies),notes,photoUrl,const DeepCollectionEquality().hash(medicines),const DeepCollectionEquality().hash(schedules),const DeepCollectionEquality().hash(asNeededSchedules));

@override
String toString() {
  return 'Child(id: $id, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, condition: $condition, allergies: $allergies, notes: $notes, photoUrl: $photoUrl, medicines: $medicines, schedules: $schedules, asNeededSchedules: $asNeededSchedules)';
}


}

/// @nodoc
abstract mixin class $ChildCopyWith<$Res>  {
  factory $ChildCopyWith(Child value, $Res Function(Child) _then) = _$ChildCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, DateTime dateOfBirth, String condition, List<String> allergies, String? notes, String? photoUrl, List<Medicine> medicines, List<MedicineSchedule> schedules, List<AsNeededSchedule> asNeededSchedules
});




}
/// @nodoc
class _$ChildCopyWithImpl<$Res>
    implements $ChildCopyWith<$Res> {
  _$ChildCopyWithImpl(this._self, this._then);

  final Child _self;
  final $Res Function(Child) _then;

/// Create a copy of Child
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? dateOfBirth = null,Object? condition = null,Object? allergies = null,Object? notes = freezed,Object? photoUrl = freezed,Object? medicines = null,Object? schedules = null,Object? asNeededSchedules = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,medicines: null == medicines ? _self.medicines : medicines // ignore: cast_nullable_to_non_nullable
as List<Medicine>,schedules: null == schedules ? _self.schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<MedicineSchedule>,asNeededSchedules: null == asNeededSchedules ? _self.asNeededSchedules : asNeededSchedules // ignore: cast_nullable_to_non_nullable
as List<AsNeededSchedule>,
  ));
}

}


/// Adds pattern-matching-related methods to [Child].
extension ChildPatterns on Child {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Child value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Child() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Child value)  $default,){
final _that = this;
switch (_that) {
case _Child():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Child value)?  $default,){
final _that = this;
switch (_that) {
case _Child() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  DateTime dateOfBirth,  String condition,  List<String> allergies,  String? notes,  String? photoUrl,  List<Medicine> medicines,  List<MedicineSchedule> schedules,  List<AsNeededSchedule> asNeededSchedules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Child() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.dateOfBirth,_that.condition,_that.allergies,_that.notes,_that.photoUrl,_that.medicines,_that.schedules,_that.asNeededSchedules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  DateTime dateOfBirth,  String condition,  List<String> allergies,  String? notes,  String? photoUrl,  List<Medicine> medicines,  List<MedicineSchedule> schedules,  List<AsNeededSchedule> asNeededSchedules)  $default,) {final _that = this;
switch (_that) {
case _Child():
return $default(_that.id,_that.firstName,_that.lastName,_that.dateOfBirth,_that.condition,_that.allergies,_that.notes,_that.photoUrl,_that.medicines,_that.schedules,_that.asNeededSchedules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  DateTime dateOfBirth,  String condition,  List<String> allergies,  String? notes,  String? photoUrl,  List<Medicine> medicines,  List<MedicineSchedule> schedules,  List<AsNeededSchedule> asNeededSchedules)?  $default,) {final _that = this;
switch (_that) {
case _Child() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.dateOfBirth,_that.condition,_that.allergies,_that.notes,_that.photoUrl,_that.medicines,_that.schedules,_that.asNeededSchedules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Child implements Child {
  const _Child({required this.id, required this.firstName, required this.lastName, required this.dateOfBirth, required this.condition, required final  List<String> allergies, this.notes, this.photoUrl, required final  List<Medicine> medicines, required final  List<MedicineSchedule> schedules, required final  List<AsNeededSchedule> asNeededSchedules}): _allergies = allergies,_medicines = medicines,_schedules = schedules,_asNeededSchedules = asNeededSchedules;
  factory _Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  DateTime dateOfBirth;
@override final  String condition;
 final  List<String> _allergies;
@override List<String> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}

@override final  String? notes;
@override final  String? photoUrl;
 final  List<Medicine> _medicines;
@override List<Medicine> get medicines {
  if (_medicines is EqualUnmodifiableListView) return _medicines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medicines);
}

 final  List<MedicineSchedule> _schedules;
@override List<MedicineSchedule> get schedules {
  if (_schedules is EqualUnmodifiableListView) return _schedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedules);
}

 final  List<AsNeededSchedule> _asNeededSchedules;
@override List<AsNeededSchedule> get asNeededSchedules {
  if (_asNeededSchedules is EqualUnmodifiableListView) return _asNeededSchedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_asNeededSchedules);
}


/// Create a copy of Child
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildCopyWith<_Child> get copyWith => __$ChildCopyWithImpl<_Child>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChildToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Child&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.condition, condition) || other.condition == condition)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other._medicines, _medicines)&&const DeepCollectionEquality().equals(other._schedules, _schedules)&&const DeepCollectionEquality().equals(other._asNeededSchedules, _asNeededSchedules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,dateOfBirth,condition,const DeepCollectionEquality().hash(_allergies),notes,photoUrl,const DeepCollectionEquality().hash(_medicines),const DeepCollectionEquality().hash(_schedules),const DeepCollectionEquality().hash(_asNeededSchedules));

@override
String toString() {
  return 'Child(id: $id, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, condition: $condition, allergies: $allergies, notes: $notes, photoUrl: $photoUrl, medicines: $medicines, schedules: $schedules, asNeededSchedules: $asNeededSchedules)';
}


}

/// @nodoc
abstract mixin class _$ChildCopyWith<$Res> implements $ChildCopyWith<$Res> {
  factory _$ChildCopyWith(_Child value, $Res Function(_Child) _then) = __$ChildCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, DateTime dateOfBirth, String condition, List<String> allergies, String? notes, String? photoUrl, List<Medicine> medicines, List<MedicineSchedule> schedules, List<AsNeededSchedule> asNeededSchedules
});




}
/// @nodoc
class __$ChildCopyWithImpl<$Res>
    implements _$ChildCopyWith<$Res> {
  __$ChildCopyWithImpl(this._self, this._then);

  final _Child _self;
  final $Res Function(_Child) _then;

/// Create a copy of Child
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? dateOfBirth = null,Object? condition = null,Object? allergies = null,Object? notes = freezed,Object? photoUrl = freezed,Object? medicines = null,Object? schedules = null,Object? asNeededSchedules = null,}) {
  return _then(_Child(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,medicines: null == medicines ? _self._medicines : medicines // ignore: cast_nullable_to_non_nullable
as List<Medicine>,schedules: null == schedules ? _self._schedules : schedules // ignore: cast_nullable_to_non_nullable
as List<MedicineSchedule>,asNeededSchedules: null == asNeededSchedules ? _self._asNeededSchedules : asNeededSchedules // ignore: cast_nullable_to_non_nullable
as List<AsNeededSchedule>,
  ));
}


}

// dart format on
