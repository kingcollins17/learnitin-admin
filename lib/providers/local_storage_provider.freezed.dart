// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_storage_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalStoreState {

 String? get accessToken;
/// Create a copy of LocalStoreState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalStoreStateCopyWith<LocalStoreState> get copyWith => _$LocalStoreStateCopyWithImpl<LocalStoreState>(this as LocalStoreState, _$identity);

  /// Serializes this LocalStoreState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalStoreState&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken);

@override
String toString() {
  return 'LocalStoreState(accessToken: $accessToken)';
}


}

/// @nodoc
abstract mixin class $LocalStoreStateCopyWith<$Res>  {
  factory $LocalStoreStateCopyWith(LocalStoreState value, $Res Function(LocalStoreState) _then) = _$LocalStoreStateCopyWithImpl;
@useResult
$Res call({
 String? accessToken
});




}
/// @nodoc
class _$LocalStoreStateCopyWithImpl<$Res>
    implements $LocalStoreStateCopyWith<$Res> {
  _$LocalStoreStateCopyWithImpl(this._self, this._then);

  final LocalStoreState _self;
  final $Res Function(LocalStoreState) _then;

/// Create a copy of LocalStoreState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = freezed,}) {
  return _then(_self.copyWith(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalStoreState].
extension LocalStoreStatePatterns on LocalStoreState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalStoreState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalStoreState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalStoreState value)  $default,){
final _that = this;
switch (_that) {
case _LocalStoreState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalStoreState value)?  $default,){
final _that = this;
switch (_that) {
case _LocalStoreState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? accessToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalStoreState() when $default != null:
return $default(_that.accessToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? accessToken)  $default,) {final _that = this;
switch (_that) {
case _LocalStoreState():
return $default(_that.accessToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? accessToken)?  $default,) {final _that = this;
switch (_that) {
case _LocalStoreState() when $default != null:
return $default(_that.accessToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalStoreState implements LocalStoreState {
  const _LocalStoreState({this.accessToken});
  factory _LocalStoreState.fromJson(Map<String, dynamic> json) => _$LocalStoreStateFromJson(json);

@override final  String? accessToken;

/// Create a copy of LocalStoreState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalStoreStateCopyWith<_LocalStoreState> get copyWith => __$LocalStoreStateCopyWithImpl<_LocalStoreState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalStoreStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalStoreState&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken);

@override
String toString() {
  return 'LocalStoreState(accessToken: $accessToken)';
}


}

/// @nodoc
abstract mixin class _$LocalStoreStateCopyWith<$Res> implements $LocalStoreStateCopyWith<$Res> {
  factory _$LocalStoreStateCopyWith(_LocalStoreState value, $Res Function(_LocalStoreState) _then) = __$LocalStoreStateCopyWithImpl;
@override @useResult
$Res call({
 String? accessToken
});




}
/// @nodoc
class __$LocalStoreStateCopyWithImpl<$Res>
    implements _$LocalStoreStateCopyWith<$Res> {
  __$LocalStoreStateCopyWithImpl(this._self, this._then);

  final _LocalStoreState _self;
  final $Res Function(_LocalStoreState) _then;

/// Create a copy of LocalStoreState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = freezed,}) {
  return _then(_LocalStoreState(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
