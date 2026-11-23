// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_up_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteUpUpdate {

 int get mid; int get fetchedAtEpochMs; int? get latestPublishAtEpochMs; int get todayVideoCount; bool get failed;
/// Create a copy of FavoriteUpUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteUpUpdateCopyWith<FavoriteUpUpdate> get copyWith => _$FavoriteUpUpdateCopyWithImpl<FavoriteUpUpdate>(this as FavoriteUpUpdate, _$identity);

  /// Serializes this FavoriteUpUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteUpUpdate&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.fetchedAtEpochMs, fetchedAtEpochMs) || other.fetchedAtEpochMs == fetchedAtEpochMs)&&(identical(other.latestPublishAtEpochMs, latestPublishAtEpochMs) || other.latestPublishAtEpochMs == latestPublishAtEpochMs)&&(identical(other.todayVideoCount, todayVideoCount) || other.todayVideoCount == todayVideoCount)&&(identical(other.failed, failed) || other.failed == failed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,fetchedAtEpochMs,latestPublishAtEpochMs,todayVideoCount,failed);

@override
String toString() {
  return 'FavoriteUpUpdate(mid: $mid, fetchedAtEpochMs: $fetchedAtEpochMs, latestPublishAtEpochMs: $latestPublishAtEpochMs, todayVideoCount: $todayVideoCount, failed: $failed)';
}


}

/// @nodoc
abstract mixin class $FavoriteUpUpdateCopyWith<$Res>  {
  factory $FavoriteUpUpdateCopyWith(FavoriteUpUpdate value, $Res Function(FavoriteUpUpdate) _then) = _$FavoriteUpUpdateCopyWithImpl;
@useResult
$Res call({
 int mid, int fetchedAtEpochMs, int? latestPublishAtEpochMs, int todayVideoCount, bool failed
});




}
/// @nodoc
class _$FavoriteUpUpdateCopyWithImpl<$Res>
    implements $FavoriteUpUpdateCopyWith<$Res> {
  _$FavoriteUpUpdateCopyWithImpl(this._self, this._then);

  final FavoriteUpUpdate _self;
  final $Res Function(FavoriteUpUpdate) _then;

/// Create a copy of FavoriteUpUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = null,Object? fetchedAtEpochMs = null,Object? latestPublishAtEpochMs = freezed,Object? todayVideoCount = null,Object? failed = null,}) {
  return _then(_self.copyWith(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,fetchedAtEpochMs: null == fetchedAtEpochMs ? _self.fetchedAtEpochMs : fetchedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,latestPublishAtEpochMs: freezed == latestPublishAtEpochMs ? _self.latestPublishAtEpochMs : latestPublishAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,todayVideoCount: null == todayVideoCount ? _self.todayVideoCount : todayVideoCount // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteUpUpdate].
extension FavoriteUpUpdatePatterns on FavoriteUpUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteUpUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteUpUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteUpUpdate value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteUpUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteUpUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteUpUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mid,  int fetchedAtEpochMs,  int? latestPublishAtEpochMs,  int todayVideoCount,  bool failed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteUpUpdate() when $default != null:
return $default(_that.mid,_that.fetchedAtEpochMs,_that.latestPublishAtEpochMs,_that.todayVideoCount,_that.failed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mid,  int fetchedAtEpochMs,  int? latestPublishAtEpochMs,  int todayVideoCount,  bool failed)  $default,) {final _that = this;
switch (_that) {
case _FavoriteUpUpdate():
return $default(_that.mid,_that.fetchedAtEpochMs,_that.latestPublishAtEpochMs,_that.todayVideoCount,_that.failed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mid,  int fetchedAtEpochMs,  int? latestPublishAtEpochMs,  int todayVideoCount,  bool failed)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteUpUpdate() when $default != null:
return $default(_that.mid,_that.fetchedAtEpochMs,_that.latestPublishAtEpochMs,_that.todayVideoCount,_that.failed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteUpUpdate implements FavoriteUpUpdate {
  const _FavoriteUpUpdate({required this.mid, required this.fetchedAtEpochMs, this.latestPublishAtEpochMs, this.todayVideoCount = 0, this.failed = false});
  factory _FavoriteUpUpdate.fromJson(Map<String, dynamic> json) => _$FavoriteUpUpdateFromJson(json);

@override final  int mid;
@override final  int fetchedAtEpochMs;
@override final  int? latestPublishAtEpochMs;
@override@JsonKey() final  int todayVideoCount;
@override@JsonKey() final  bool failed;

/// Create a copy of FavoriteUpUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteUpUpdateCopyWith<_FavoriteUpUpdate> get copyWith => __$FavoriteUpUpdateCopyWithImpl<_FavoriteUpUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteUpUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteUpUpdate&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.fetchedAtEpochMs, fetchedAtEpochMs) || other.fetchedAtEpochMs == fetchedAtEpochMs)&&(identical(other.latestPublishAtEpochMs, latestPublishAtEpochMs) || other.latestPublishAtEpochMs == latestPublishAtEpochMs)&&(identical(other.todayVideoCount, todayVideoCount) || other.todayVideoCount == todayVideoCount)&&(identical(other.failed, failed) || other.failed == failed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,fetchedAtEpochMs,latestPublishAtEpochMs,todayVideoCount,failed);

@override
String toString() {
  return 'FavoriteUpUpdate(mid: $mid, fetchedAtEpochMs: $fetchedAtEpochMs, latestPublishAtEpochMs: $latestPublishAtEpochMs, todayVideoCount: $todayVideoCount, failed: $failed)';
}


}

/// @nodoc
abstract mixin class _$FavoriteUpUpdateCopyWith<$Res> implements $FavoriteUpUpdateCopyWith<$Res> {
  factory _$FavoriteUpUpdateCopyWith(_FavoriteUpUpdate value, $Res Function(_FavoriteUpUpdate) _then) = __$FavoriteUpUpdateCopyWithImpl;
@override @useResult
$Res call({
 int mid, int fetchedAtEpochMs, int? latestPublishAtEpochMs, int todayVideoCount, bool failed
});




}
/// @nodoc
class __$FavoriteUpUpdateCopyWithImpl<$Res>
    implements _$FavoriteUpUpdateCopyWith<$Res> {
  __$FavoriteUpUpdateCopyWithImpl(this._self, this._then);

  final _FavoriteUpUpdate _self;
  final $Res Function(_FavoriteUpUpdate) _then;

/// Create a copy of FavoriteUpUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = null,Object? fetchedAtEpochMs = null,Object? latestPublishAtEpochMs = freezed,Object? todayVideoCount = null,Object? failed = null,}) {
  return _then(_FavoriteUpUpdate(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,fetchedAtEpochMs: null == fetchedAtEpochMs ? _self.fetchedAtEpochMs : fetchedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,latestPublishAtEpochMs: freezed == latestPublishAtEpochMs ? _self.latestPublishAtEpochMs : latestPublishAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,todayVideoCount: null == todayVideoCount ? _self.todayVideoCount : todayVideoCount // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
