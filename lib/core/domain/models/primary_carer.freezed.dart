// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'primary_carer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrimaryCarer {

 String get id; String get firstName; String get lastName; String get email; String get relationshipToChild; List<Child> get children;
/// Create a copy of PrimaryCarer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrimaryCarerCopyWith<PrimaryCarer> get copyWith => _$PrimaryCarerCopyWithImpl<PrimaryCarer>(this as PrimaryCarer, _$identity);

  /// Serializes this PrimaryCarer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrimaryCarer&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.relationshipToChild, relationshipToChild) || other.relationshipToChild == relationshipToChild)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,relationshipToChild,const DeepCollectionEquality().hash(children));

@override
String toString() {
  return 'PrimaryCarer(id: $id, firstName: $firstName, lastName: $lastName, email: $email, relationshipToChild: $relationshipToChild, children: $children)';
}


}

/// @nodoc
abstract mixin class $PrimaryCarerCopyWith<$Res>  {
  factory $PrimaryCarerCopyWith(PrimaryCarer value, $Res Function(PrimaryCarer) _then) = _$PrimaryCarerCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String email, String relationshipToChild, List<Child> children
});




}
/// @nodoc
class _$PrimaryCarerCopyWithImpl<$Res>
    implements $PrimaryCarerCopyWith<$Res> {
  _$PrimaryCarerCopyWithImpl(this._self, this._then);

  final PrimaryCarer _self;
  final $Res Function(PrimaryCarer) _then;

/// Create a copy of PrimaryCarer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? relationshipToChild = null,Object? children = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,relationshipToChild: null == relationshipToChild ? _self.relationshipToChild : relationshipToChild // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<Child>,
  ));
}

}


/// Adds pattern-matching-related methods to [PrimaryCarer].
extension PrimaryCarerPatterns on PrimaryCarer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrimaryCarer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrimaryCarer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrimaryCarer value)  $default,){
final _that = this;
switch (_that) {
case _PrimaryCarer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrimaryCarer value)?  $default,){
final _that = this;
switch (_that) {
case _PrimaryCarer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String relationshipToChild,  List<Child> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrimaryCarer() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.relationshipToChild,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String relationshipToChild,  List<Child> children)  $default,) {final _that = this;
switch (_that) {
case _PrimaryCarer():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.relationshipToChild,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String email,  String relationshipToChild,  List<Child> children)?  $default,) {final _that = this;
switch (_that) {
case _PrimaryCarer() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.relationshipToChild,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrimaryCarer implements PrimaryCarer {
  const _PrimaryCarer({required this.id, required this.firstName, required this.lastName, required this.email, required this.relationshipToChild, required final  List<Child> children}): _children = children;
  factory _PrimaryCarer.fromJson(Map<String, dynamic> json) => _$PrimaryCarerFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  String relationshipToChild;
 final  List<Child> _children;
@override List<Child> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of PrimaryCarer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrimaryCarerCopyWith<_PrimaryCarer> get copyWith => __$PrimaryCarerCopyWithImpl<_PrimaryCarer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrimaryCarerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrimaryCarer&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.relationshipToChild, relationshipToChild) || other.relationshipToChild == relationshipToChild)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,relationshipToChild,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'PrimaryCarer(id: $id, firstName: $firstName, lastName: $lastName, email: $email, relationshipToChild: $relationshipToChild, children: $children)';
}


}

/// @nodoc
abstract mixin class _$PrimaryCarerCopyWith<$Res> implements $PrimaryCarerCopyWith<$Res> {
  factory _$PrimaryCarerCopyWith(_PrimaryCarer value, $Res Function(_PrimaryCarer) _then) = __$PrimaryCarerCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String email, String relationshipToChild, List<Child> children
});




}
/// @nodoc
class __$PrimaryCarerCopyWithImpl<$Res>
    implements _$PrimaryCarerCopyWith<$Res> {
  __$PrimaryCarerCopyWithImpl(this._self, this._then);

  final _PrimaryCarer _self;
  final $Res Function(_PrimaryCarer) _then;

/// Create a copy of PrimaryCarer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? relationshipToChild = null,Object? children = null,}) {
  return _then(_PrimaryCarer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,relationshipToChild: null == relationshipToChild ? _self.relationshipToChild : relationshipToChild // ignore: cast_nullable_to_non_nullable
as String,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<Child>,
  ));
}


}

// dart format on
