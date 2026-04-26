// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppNotificationState {

 List<int> get selectedUserIds;
/// Create a copy of AppNotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationStateCopyWith<AppNotificationState> get copyWith => _$AppNotificationStateCopyWithImpl<AppNotificationState>(this as AppNotificationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotificationState&&const DeepCollectionEquality().equals(other.selectedUserIds, selectedUserIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedUserIds));

@override
String toString() {
  return 'AppNotificationState(selectedUserIds: $selectedUserIds)';
}


}

/// @nodoc
abstract mixin class $AppNotificationStateCopyWith<$Res>  {
  factory $AppNotificationStateCopyWith(AppNotificationState value, $Res Function(AppNotificationState) _then) = _$AppNotificationStateCopyWithImpl;
@useResult
$Res call({
 List<int> selectedUserIds
});




}
/// @nodoc
class _$AppNotificationStateCopyWithImpl<$Res>
    implements $AppNotificationStateCopyWith<$Res> {
  _$AppNotificationStateCopyWithImpl(this._self, this._then);

  final AppNotificationState _self;
  final $Res Function(AppNotificationState) _then;

/// Create a copy of AppNotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedUserIds = null,}) {
  return _then(_self.copyWith(
selectedUserIds: null == selectedUserIds ? _self.selectedUserIds : selectedUserIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotificationState].
extension AppNotificationStatePatterns on AppNotificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotificationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotificationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotificationState value)  $default,){
final _that = this;
switch (_that) {
case _AppNotificationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotificationState value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotificationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> selectedUserIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotificationState() when $default != null:
return $default(_that.selectedUserIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> selectedUserIds)  $default,) {final _that = this;
switch (_that) {
case _AppNotificationState():
return $default(_that.selectedUserIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> selectedUserIds)?  $default,) {final _that = this;
switch (_that) {
case _AppNotificationState() when $default != null:
return $default(_that.selectedUserIds);case _:
  return null;

}
}

}

/// @nodoc


class _AppNotificationState extends AppNotificationState {
  const _AppNotificationState({final  List<int> selectedUserIds = const []}): _selectedUserIds = selectedUserIds,super._();
  

 final  List<int> _selectedUserIds;
@override@JsonKey() List<int> get selectedUserIds {
  if (_selectedUserIds is EqualUnmodifiableListView) return _selectedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedUserIds);
}


/// Create a copy of AppNotificationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationStateCopyWith<_AppNotificationState> get copyWith => __$AppNotificationStateCopyWithImpl<_AppNotificationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotificationState&&const DeepCollectionEquality().equals(other._selectedUserIds, _selectedUserIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedUserIds));

@override
String toString() {
  return 'AppNotificationState(selectedUserIds: $selectedUserIds)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationStateCopyWith<$Res> implements $AppNotificationStateCopyWith<$Res> {
  factory _$AppNotificationStateCopyWith(_AppNotificationState value, $Res Function(_AppNotificationState) _then) = __$AppNotificationStateCopyWithImpl;
@override @useResult
$Res call({
 List<int> selectedUserIds
});




}
/// @nodoc
class __$AppNotificationStateCopyWithImpl<$Res>
    implements _$AppNotificationStateCopyWith<$Res> {
  __$AppNotificationStateCopyWithImpl(this._self, this._then);

  final _AppNotificationState _self;
  final $Res Function(_AppNotificationState) _then;

/// Create a copy of AppNotificationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedUserIds = null,}) {
  return _then(_AppNotificationState(
selectedUserIds: null == selectedUserIds ? _self._selectedUserIds : selectedUserIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
