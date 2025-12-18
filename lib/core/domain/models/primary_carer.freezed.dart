// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'primary_carer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PrimaryCarer _$PrimaryCarerFromJson(Map<String, dynamic> json) {
  return _PrimaryCarer.fromJson(json);
}

/// @nodoc
mixin _$PrimaryCarer {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get relationshipToChild => throw _privateConstructorUsedError;
  List<Child> get children => throw _privateConstructorUsedError;

  /// Serializes this PrimaryCarer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrimaryCarer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrimaryCarerCopyWith<PrimaryCarer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrimaryCarerCopyWith<$Res> {
  factory $PrimaryCarerCopyWith(
    PrimaryCarer value,
    $Res Function(PrimaryCarer) then,
  ) = _$PrimaryCarerCopyWithImpl<$Res, PrimaryCarer>;
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String email,
    String relationshipToChild,
    List<Child> children,
  });
}

/// @nodoc
class _$PrimaryCarerCopyWithImpl<$Res, $Val extends PrimaryCarer>
    implements $PrimaryCarerCopyWith<$Res> {
  _$PrimaryCarerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrimaryCarer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? relationshipToChild = null,
    Object? children = null,
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
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            relationshipToChild: null == relationshipToChild
                ? _value.relationshipToChild
                : relationshipToChild // ignore: cast_nullable_to_non_nullable
                      as String,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<Child>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrimaryCarerImplCopyWith<$Res>
    implements $PrimaryCarerCopyWith<$Res> {
  factory _$$PrimaryCarerImplCopyWith(
    _$PrimaryCarerImpl value,
    $Res Function(_$PrimaryCarerImpl) then,
  ) = __$$PrimaryCarerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String firstName,
    String lastName,
    String email,
    String relationshipToChild,
    List<Child> children,
  });
}

/// @nodoc
class __$$PrimaryCarerImplCopyWithImpl<$Res>
    extends _$PrimaryCarerCopyWithImpl<$Res, _$PrimaryCarerImpl>
    implements _$$PrimaryCarerImplCopyWith<$Res> {
  __$$PrimaryCarerImplCopyWithImpl(
    _$PrimaryCarerImpl _value,
    $Res Function(_$PrimaryCarerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrimaryCarer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? relationshipToChild = null,
    Object? children = null,
  }) {
    return _then(
      _$PrimaryCarerImpl(
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
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        relationshipToChild: null == relationshipToChild
            ? _value.relationshipToChild
            : relationshipToChild // ignore: cast_nullable_to_non_nullable
                  as String,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<Child>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrimaryCarerImpl implements _PrimaryCarer {
  const _$PrimaryCarerImpl({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.relationshipToChild,
    required final List<Child> children,
  }) : _children = children;

  factory _$PrimaryCarerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrimaryCarerImplFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final String relationshipToChild;
  final List<Child> _children;
  @override
  List<Child> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'PrimaryCarer(id: $id, firstName: $firstName, lastName: $lastName, email: $email, relationshipToChild: $relationshipToChild, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrimaryCarerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.relationshipToChild, relationshipToChild) ||
                other.relationshipToChild == relationshipToChild) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    firstName,
    lastName,
    email,
    relationshipToChild,
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of PrimaryCarer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrimaryCarerImplCopyWith<_$PrimaryCarerImpl> get copyWith =>
      __$$PrimaryCarerImplCopyWithImpl<_$PrimaryCarerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrimaryCarerImplToJson(this);
  }
}

abstract class _PrimaryCarer implements PrimaryCarer {
  const factory _PrimaryCarer({
    required final String id,
    required final String firstName,
    required final String lastName,
    required final String email,
    required final String relationshipToChild,
    required final List<Child> children,
  }) = _$PrimaryCarerImpl;

  factory _PrimaryCarer.fromJson(Map<String, dynamic> json) =
      _$PrimaryCarerImpl.fromJson;

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get email;
  @override
  String get relationshipToChild;
  @override
  List<Child> get children;

  /// Create a copy of PrimaryCarer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrimaryCarerImplCopyWith<_$PrimaryCarerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
