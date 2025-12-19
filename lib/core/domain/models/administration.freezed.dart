// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'administration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Administration {

 String get id; DateTime get dateTime; AdministrationStatus get status; bool get isAsNeeded; String? get administeredBy; String? get notes;
/// Create a copy of Administration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdministrationCopyWith<Administration> get copyWith => _$AdministrationCopyWithImpl<Administration>(this as Administration, _$identity);

  /// Serializes this Administration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Administration&&(identical(other.id, id) || other.id == id)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.isAsNeeded, isAsNeeded) || other.isAsNeeded == isAsNeeded)&&(identical(other.administeredBy, administeredBy) || other.administeredBy == administeredBy)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateTime,status,isAsNeeded,administeredBy,notes);

@override
String toString() {
  return 'Administration(id: $id, dateTime: $dateTime, status: $status, isAsNeeded: $isAsNeeded, administeredBy: $administeredBy, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $AdministrationCopyWith<$Res>  {
  factory $AdministrationCopyWith(Administration value, $Res Function(Administration) _then) = _$AdministrationCopyWithImpl;
@useResult
$Res call({
 String id, DateTime dateTime, AdministrationStatus status, bool isAsNeeded, String? administeredBy, String? notes
});




}
/// @nodoc
class _$AdministrationCopyWithImpl<$Res>
    implements $AdministrationCopyWith<$Res> {
  _$AdministrationCopyWithImpl(this._self, this._then);

  final Administration _self;
  final $Res Function(Administration) _then;

/// Create a copy of Administration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dateTime = null,Object? status = null,Object? isAsNeeded = null,Object? administeredBy = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AdministrationStatus,isAsNeeded: null == isAsNeeded ? _self.isAsNeeded : isAsNeeded // ignore: cast_nullable_to_non_nullable
as bool,administeredBy: freezed == administeredBy ? _self.administeredBy : administeredBy // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Administration].
extension AdministrationPatterns on Administration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Administration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Administration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Administration value)  $default,){
final _that = this;
switch (_that) {
case _Administration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Administration value)?  $default,){
final _that = this;
switch (_that) {
case _Administration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime dateTime,  AdministrationStatus status,  bool isAsNeeded,  String? administeredBy,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Administration() when $default != null:
return $default(_that.id,_that.dateTime,_that.status,_that.isAsNeeded,_that.administeredBy,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime dateTime,  AdministrationStatus status,  bool isAsNeeded,  String? administeredBy,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Administration():
return $default(_that.id,_that.dateTime,_that.status,_that.isAsNeeded,_that.administeredBy,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime dateTime,  AdministrationStatus status,  bool isAsNeeded,  String? administeredBy,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Administration() when $default != null:
return $default(_that.id,_that.dateTime,_that.status,_that.isAsNeeded,_that.administeredBy,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Administration implements Administration {
  const _Administration({required this.id, required this.dateTime, required this.status, required this.isAsNeeded, this.administeredBy, this.notes});
  factory _Administration.fromJson(Map<String, dynamic> json) => _$AdministrationFromJson(json);

@override final  String id;
@override final  DateTime dateTime;
@override final  AdministrationStatus status;
@override final  bool isAsNeeded;
@override final  String? administeredBy;
@override final  String? notes;

/// Create a copy of Administration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdministrationCopyWith<_Administration> get copyWith => __$AdministrationCopyWithImpl<_Administration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdministrationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Administration&&(identical(other.id, id) || other.id == id)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.isAsNeeded, isAsNeeded) || other.isAsNeeded == isAsNeeded)&&(identical(other.administeredBy, administeredBy) || other.administeredBy == administeredBy)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dateTime,status,isAsNeeded,administeredBy,notes);

@override
String toString() {
  return 'Administration(id: $id, dateTime: $dateTime, status: $status, isAsNeeded: $isAsNeeded, administeredBy: $administeredBy, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$AdministrationCopyWith<$Res> implements $AdministrationCopyWith<$Res> {
  factory _$AdministrationCopyWith(_Administration value, $Res Function(_Administration) _then) = __$AdministrationCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime dateTime, AdministrationStatus status, bool isAsNeeded, String? administeredBy, String? notes
});




}
/// @nodoc
class __$AdministrationCopyWithImpl<$Res>
    implements _$AdministrationCopyWith<$Res> {
  __$AdministrationCopyWithImpl(this._self, this._then);

  final _Administration _self;
  final $Res Function(_Administration) _then;

/// Create a copy of Administration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dateTime = null,Object? status = null,Object? isAsNeeded = null,Object? administeredBy = freezed,Object? notes = freezed,}) {
  return _then(_Administration(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AdministrationStatus,isAsNeeded: null == isAsNeeded ? _self.isAsNeeded : isAsNeeded // ignore: cast_nullable_to_non_nullable
as bool,administeredBy: freezed == administeredBy ? _self.administeredBy : administeredBy // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
