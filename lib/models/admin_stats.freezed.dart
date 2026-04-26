// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminStats {

@JsonKey(name: 'total_users') int? get totalUsers;@JsonKey(name: 'active_users') int? get activeUsers;@JsonKey(name: 'total_superusers') int? get totalSuperusers;@JsonKey(name: 'total_courses') int? get totalCourses;@JsonKey(name: 'total_lessons') int? get totalLessons;@JsonKey(name: 'total_audio_lessons') int? get totalAudioLessons;
/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminStatsCopyWith<AdminStats> get copyWith => _$AdminStatsCopyWithImpl<AdminStats>(this as AdminStats, _$identity);

  /// Serializes this AdminStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.totalSuperusers, totalSuperusers) || other.totalSuperusers == totalSuperusers)&&(identical(other.totalCourses, totalCourses) || other.totalCourses == totalCourses)&&(identical(other.totalLessons, totalLessons) || other.totalLessons == totalLessons)&&(identical(other.totalAudioLessons, totalAudioLessons) || other.totalAudioLessons == totalAudioLessons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeUsers,totalSuperusers,totalCourses,totalLessons,totalAudioLessons);

@override
String toString() {
  return 'AdminStats(totalUsers: $totalUsers, activeUsers: $activeUsers, totalSuperusers: $totalSuperusers, totalCourses: $totalCourses, totalLessons: $totalLessons, totalAudioLessons: $totalAudioLessons)';
}


}

/// @nodoc
abstract mixin class $AdminStatsCopyWith<$Res>  {
  factory $AdminStatsCopyWith(AdminStats value, $Res Function(AdminStats) _then) = _$AdminStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_users') int? totalUsers,@JsonKey(name: 'active_users') int? activeUsers,@JsonKey(name: 'total_superusers') int? totalSuperusers,@JsonKey(name: 'total_courses') int? totalCourses,@JsonKey(name: 'total_lessons') int? totalLessons,@JsonKey(name: 'total_audio_lessons') int? totalAudioLessons
});




}
/// @nodoc
class _$AdminStatsCopyWithImpl<$Res>
    implements $AdminStatsCopyWith<$Res> {
  _$AdminStatsCopyWithImpl(this._self, this._then);

  final AdminStats _self;
  final $Res Function(AdminStats) _then;

/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = freezed,Object? activeUsers = freezed,Object? totalSuperusers = freezed,Object? totalCourses = freezed,Object? totalLessons = freezed,Object? totalAudioLessons = freezed,}) {
  return _then(_self.copyWith(
totalUsers: freezed == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int?,activeUsers: freezed == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int?,totalSuperusers: freezed == totalSuperusers ? _self.totalSuperusers : totalSuperusers // ignore: cast_nullable_to_non_nullable
as int?,totalCourses: freezed == totalCourses ? _self.totalCourses : totalCourses // ignore: cast_nullable_to_non_nullable
as int?,totalLessons: freezed == totalLessons ? _self.totalLessons : totalLessons // ignore: cast_nullable_to_non_nullable
as int?,totalAudioLessons: freezed == totalAudioLessons ? _self.totalAudioLessons : totalAudioLessons // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminStats].
extension AdminStatsPatterns on AdminStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminStats value)  $default,){
final _that = this;
switch (_that) {
case _AdminStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminStats value)?  $default,){
final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_users')  int? totalUsers, @JsonKey(name: 'active_users')  int? activeUsers, @JsonKey(name: 'total_superusers')  int? totalSuperusers, @JsonKey(name: 'total_courses')  int? totalCourses, @JsonKey(name: 'total_lessons')  int? totalLessons, @JsonKey(name: 'total_audio_lessons')  int? totalAudioLessons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
return $default(_that.totalUsers,_that.activeUsers,_that.totalSuperusers,_that.totalCourses,_that.totalLessons,_that.totalAudioLessons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_users')  int? totalUsers, @JsonKey(name: 'active_users')  int? activeUsers, @JsonKey(name: 'total_superusers')  int? totalSuperusers, @JsonKey(name: 'total_courses')  int? totalCourses, @JsonKey(name: 'total_lessons')  int? totalLessons, @JsonKey(name: 'total_audio_lessons')  int? totalAudioLessons)  $default,) {final _that = this;
switch (_that) {
case _AdminStats():
return $default(_that.totalUsers,_that.activeUsers,_that.totalSuperusers,_that.totalCourses,_that.totalLessons,_that.totalAudioLessons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_users')  int? totalUsers, @JsonKey(name: 'active_users')  int? activeUsers, @JsonKey(name: 'total_superusers')  int? totalSuperusers, @JsonKey(name: 'total_courses')  int? totalCourses, @JsonKey(name: 'total_lessons')  int? totalLessons, @JsonKey(name: 'total_audio_lessons')  int? totalAudioLessons)?  $default,) {final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
return $default(_that.totalUsers,_that.activeUsers,_that.totalSuperusers,_that.totalCourses,_that.totalLessons,_that.totalAudioLessons);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminStats implements AdminStats {
  const _AdminStats({@JsonKey(name: 'total_users') this.totalUsers, @JsonKey(name: 'active_users') this.activeUsers, @JsonKey(name: 'total_superusers') this.totalSuperusers, @JsonKey(name: 'total_courses') this.totalCourses, @JsonKey(name: 'total_lessons') this.totalLessons, @JsonKey(name: 'total_audio_lessons') this.totalAudioLessons});
  factory _AdminStats.fromJson(Map<String, dynamic> json) => _$AdminStatsFromJson(json);

@override@JsonKey(name: 'total_users') final  int? totalUsers;
@override@JsonKey(name: 'active_users') final  int? activeUsers;
@override@JsonKey(name: 'total_superusers') final  int? totalSuperusers;
@override@JsonKey(name: 'total_courses') final  int? totalCourses;
@override@JsonKey(name: 'total_lessons') final  int? totalLessons;
@override@JsonKey(name: 'total_audio_lessons') final  int? totalAudioLessons;

/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminStatsCopyWith<_AdminStats> get copyWith => __$AdminStatsCopyWithImpl<_AdminStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.totalSuperusers, totalSuperusers) || other.totalSuperusers == totalSuperusers)&&(identical(other.totalCourses, totalCourses) || other.totalCourses == totalCourses)&&(identical(other.totalLessons, totalLessons) || other.totalLessons == totalLessons)&&(identical(other.totalAudioLessons, totalAudioLessons) || other.totalAudioLessons == totalAudioLessons));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeUsers,totalSuperusers,totalCourses,totalLessons,totalAudioLessons);

@override
String toString() {
  return 'AdminStats(totalUsers: $totalUsers, activeUsers: $activeUsers, totalSuperusers: $totalSuperusers, totalCourses: $totalCourses, totalLessons: $totalLessons, totalAudioLessons: $totalAudioLessons)';
}


}

/// @nodoc
abstract mixin class _$AdminStatsCopyWith<$Res> implements $AdminStatsCopyWith<$Res> {
  factory _$AdminStatsCopyWith(_AdminStats value, $Res Function(_AdminStats) _then) = __$AdminStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_users') int? totalUsers,@JsonKey(name: 'active_users') int? activeUsers,@JsonKey(name: 'total_superusers') int? totalSuperusers,@JsonKey(name: 'total_courses') int? totalCourses,@JsonKey(name: 'total_lessons') int? totalLessons,@JsonKey(name: 'total_audio_lessons') int? totalAudioLessons
});




}
/// @nodoc
class __$AdminStatsCopyWithImpl<$Res>
    implements _$AdminStatsCopyWith<$Res> {
  __$AdminStatsCopyWithImpl(this._self, this._then);

  final _AdminStats _self;
  final $Res Function(_AdminStats) _then;

/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = freezed,Object? activeUsers = freezed,Object? totalSuperusers = freezed,Object? totalCourses = freezed,Object? totalLessons = freezed,Object? totalAudioLessons = freezed,}) {
  return _then(_AdminStats(
totalUsers: freezed == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int?,activeUsers: freezed == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int?,totalSuperusers: freezed == totalSuperusers ? _self.totalSuperusers : totalSuperusers // ignore: cast_nullable_to_non_nullable
as int?,totalCourses: freezed == totalCourses ? _self.totalCourses : totalCourses // ignore: cast_nullable_to_non_nullable
as int?,totalLessons: freezed == totalLessons ? _self.totalLessons : totalLessons // ignore: cast_nullable_to_non_nullable
as int?,totalAudioLessons: freezed == totalAudioLessons ? _self.totalAudioLessons : totalAudioLessons // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
