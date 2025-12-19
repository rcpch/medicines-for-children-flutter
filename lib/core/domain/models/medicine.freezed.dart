// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Medicine {

 String get id; String get name; String get alias; MedicineType get type; String get dose; String get doseUnit; String get route; String get frequency; MedicineStatus get status; String? get notes; String? get photoUrl; List<String> get photoUrls;
/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicineCopyWith<Medicine> get copyWith => _$MedicineCopyWithImpl<Medicine>(this as Medicine, _$identity);

  /// Serializes this Medicine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Medicine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.type, type) || other.type == type)&&(identical(other.dose, dose) || other.dose == dose)&&(identical(other.doseUnit, doseUnit) || other.doseUnit == doseUnit)&&(identical(other.route, route) || other.route == route)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,alias,type,dose,doseUnit,route,frequency,status,notes,photoUrl,const DeepCollectionEquality().hash(photoUrls));

@override
String toString() {
  return 'Medicine(id: $id, name: $name, alias: $alias, type: $type, dose: $dose, doseUnit: $doseUnit, route: $route, frequency: $frequency, status: $status, notes: $notes, photoUrl: $photoUrl, photoUrls: $photoUrls)';
}


}

/// @nodoc
abstract mixin class $MedicineCopyWith<$Res>  {
  factory $MedicineCopyWith(Medicine value, $Res Function(Medicine) _then) = _$MedicineCopyWithImpl;
@useResult
$Res call({
 String id, String name, String alias, MedicineType type, String dose, String doseUnit, String route, String frequency, MedicineStatus status, String? notes, String? photoUrl, List<String> photoUrls
});




}
/// @nodoc
class _$MedicineCopyWithImpl<$Res>
    implements $MedicineCopyWith<$Res> {
  _$MedicineCopyWithImpl(this._self, this._then);

  final Medicine _self;
  final $Res Function(Medicine) _then;

/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? alias = null,Object? type = null,Object? dose = null,Object? doseUnit = null,Object? route = null,Object? frequency = null,Object? status = null,Object? notes = freezed,Object? photoUrl = freezed,Object? photoUrls = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,alias: null == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineType,dose: null == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String,doseUnit: null == doseUnit ? _self.doseUnit : doseUnit // ignore: cast_nullable_to_non_nullable
as String,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MedicineStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Medicine].
extension MedicinePatterns on Medicine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Medicine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Medicine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Medicine value)  $default,){
final _that = this;
switch (_that) {
case _Medicine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Medicine value)?  $default,){
final _that = this;
switch (_that) {
case _Medicine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String alias,  MedicineType type,  String dose,  String doseUnit,  String route,  String frequency,  MedicineStatus status,  String? notes,  String? photoUrl,  List<String> photoUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Medicine() when $default != null:
return $default(_that.id,_that.name,_that.alias,_that.type,_that.dose,_that.doseUnit,_that.route,_that.frequency,_that.status,_that.notes,_that.photoUrl,_that.photoUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String alias,  MedicineType type,  String dose,  String doseUnit,  String route,  String frequency,  MedicineStatus status,  String? notes,  String? photoUrl,  List<String> photoUrls)  $default,) {final _that = this;
switch (_that) {
case _Medicine():
return $default(_that.id,_that.name,_that.alias,_that.type,_that.dose,_that.doseUnit,_that.route,_that.frequency,_that.status,_that.notes,_that.photoUrl,_that.photoUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String alias,  MedicineType type,  String dose,  String doseUnit,  String route,  String frequency,  MedicineStatus status,  String? notes,  String? photoUrl,  List<String> photoUrls)?  $default,) {final _that = this;
switch (_that) {
case _Medicine() when $default != null:
return $default(_that.id,_that.name,_that.alias,_that.type,_that.dose,_that.doseUnit,_that.route,_that.frequency,_that.status,_that.notes,_that.photoUrl,_that.photoUrls);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Medicine implements Medicine {
  const _Medicine({required this.id, required this.name, required this.alias, required this.type, required this.dose, required this.doseUnit, required this.route, required this.frequency, this.status = MedicineStatus.inUse, this.notes, this.photoUrl, final  List<String> photoUrls = const <String>[]}): _photoUrls = photoUrls;
  factory _Medicine.fromJson(Map<String, dynamic> json) => _$MedicineFromJson(json);

@override final  String id;
@override final  String name;
@override final  String alias;
@override final  MedicineType type;
@override final  String dose;
@override final  String doseUnit;
@override final  String route;
@override final  String frequency;
@override@JsonKey() final  MedicineStatus status;
@override final  String? notes;
@override final  String? photoUrl;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}


/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicineCopyWith<_Medicine> get copyWith => __$MedicineCopyWithImpl<_Medicine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Medicine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.type, type) || other.type == type)&&(identical(other.dose, dose) || other.dose == dose)&&(identical(other.doseUnit, doseUnit) || other.doseUnit == doseUnit)&&(identical(other.route, route) || other.route == route)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,alias,type,dose,doseUnit,route,frequency,status,notes,photoUrl,const DeepCollectionEquality().hash(_photoUrls));

@override
String toString() {
  return 'Medicine(id: $id, name: $name, alias: $alias, type: $type, dose: $dose, doseUnit: $doseUnit, route: $route, frequency: $frequency, status: $status, notes: $notes, photoUrl: $photoUrl, photoUrls: $photoUrls)';
}


}

/// @nodoc
abstract mixin class _$MedicineCopyWith<$Res> implements $MedicineCopyWith<$Res> {
  factory _$MedicineCopyWith(_Medicine value, $Res Function(_Medicine) _then) = __$MedicineCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String alias, MedicineType type, String dose, String doseUnit, String route, String frequency, MedicineStatus status, String? notes, String? photoUrl, List<String> photoUrls
});




}
/// @nodoc
class __$MedicineCopyWithImpl<$Res>
    implements _$MedicineCopyWith<$Res> {
  __$MedicineCopyWithImpl(this._self, this._then);

  final _Medicine _self;
  final $Res Function(_Medicine) _then;

/// Create a copy of Medicine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? alias = null,Object? type = null,Object? dose = null,Object? doseUnit = null,Object? route = null,Object? frequency = null,Object? status = null,Object? notes = freezed,Object? photoUrl = freezed,Object? photoUrls = null,}) {
  return _then(_Medicine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,alias: null == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicineType,dose: null == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String,doseUnit: null == doseUnit ? _self.doseUnit : doseUnit // ignore: cast_nullable_to_non_nullable
as String,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MedicineStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
