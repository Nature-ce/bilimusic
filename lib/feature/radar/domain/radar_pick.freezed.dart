// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radar_pick.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RadarPick {

 HotPlaylistTrack get track; RadarReason get reason; double get score; String? get reasonDetail;
/// Create a copy of RadarPick
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadarPickCopyWith<RadarPick> get copyWith => _$RadarPickCopyWithImpl<RadarPick>(this as RadarPick, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadarPick&&(identical(other.track, track) || other.track == track)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.score, score) || other.score == score)&&(identical(other.reasonDetail, reasonDetail) || other.reasonDetail == reasonDetail));
}


@override
int get hashCode => Object.hash(runtimeType,track,reason,score,reasonDetail);

@override
String toString() {
  return 'RadarPick(track: $track, reason: $reason, score: $score, reasonDetail: $reasonDetail)';
}


}

/// @nodoc
abstract mixin class $RadarPickCopyWith<$Res>  {
  factory $RadarPickCopyWith(RadarPick value, $Res Function(RadarPick) _then) = _$RadarPickCopyWithImpl;
@useResult
$Res call({
 HotPlaylistTrack track, RadarReason reason, double score, String? reasonDetail
});


$HotPlaylistTrackCopyWith<$Res> get track;

}
/// @nodoc
class _$RadarPickCopyWithImpl<$Res>
    implements $RadarPickCopyWith<$Res> {
  _$RadarPickCopyWithImpl(this._self, this._then);

  final RadarPick _self;
  final $Res Function(RadarPick) _then;

/// Create a copy of RadarPick
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? track = null,Object? reason = null,Object? score = null,Object? reasonDetail = freezed,}) {
  return _then(_self.copyWith(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as HotPlaylistTrack,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RadarReason,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasonDetail: freezed == reasonDetail ? _self.reasonDetail : reasonDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RadarPick
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HotPlaylistTrackCopyWith<$Res> get track {
  
  return $HotPlaylistTrackCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}


/// Adds pattern-matching-related methods to [RadarPick].
extension RadarPickPatterns on RadarPick {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RadarPick value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RadarPick() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RadarPick value)  $default,){
final _that = this;
switch (_that) {
case _RadarPick():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RadarPick value)?  $default,){
final _that = this;
switch (_that) {
case _RadarPick() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotPlaylistTrack track,  RadarReason reason,  double score,  String? reasonDetail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RadarPick() when $default != null:
return $default(_that.track,_that.reason,_that.score,_that.reasonDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotPlaylistTrack track,  RadarReason reason,  double score,  String? reasonDetail)  $default,) {final _that = this;
switch (_that) {
case _RadarPick():
return $default(_that.track,_that.reason,_that.score,_that.reasonDetail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotPlaylistTrack track,  RadarReason reason,  double score,  String? reasonDetail)?  $default,) {final _that = this;
switch (_that) {
case _RadarPick() when $default != null:
return $default(_that.track,_that.reason,_that.score,_that.reasonDetail);case _:
  return null;

}
}

}

/// @nodoc


class _RadarPick extends RadarPick {
  const _RadarPick({required this.track, required this.reason, this.score = 0, this.reasonDetail}): super._();
  

@override final  HotPlaylistTrack track;
@override final  RadarReason reason;
@override@JsonKey() final  double score;
@override final  String? reasonDetail;

/// Create a copy of RadarPick
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RadarPickCopyWith<_RadarPick> get copyWith => __$RadarPickCopyWithImpl<_RadarPick>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RadarPick&&(identical(other.track, track) || other.track == track)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.score, score) || other.score == score)&&(identical(other.reasonDetail, reasonDetail) || other.reasonDetail == reasonDetail));
}


@override
int get hashCode => Object.hash(runtimeType,track,reason,score,reasonDetail);

@override
String toString() {
  return 'RadarPick(track: $track, reason: $reason, score: $score, reasonDetail: $reasonDetail)';
}


}

/// @nodoc
abstract mixin class _$RadarPickCopyWith<$Res> implements $RadarPickCopyWith<$Res> {
  factory _$RadarPickCopyWith(_RadarPick value, $Res Function(_RadarPick) _then) = __$RadarPickCopyWithImpl;
@override @useResult
$Res call({
 HotPlaylistTrack track, RadarReason reason, double score, String? reasonDetail
});


@override $HotPlaylistTrackCopyWith<$Res> get track;

}
/// @nodoc
class __$RadarPickCopyWithImpl<$Res>
    implements _$RadarPickCopyWith<$Res> {
  __$RadarPickCopyWithImpl(this._self, this._then);

  final _RadarPick _self;
  final $Res Function(_RadarPick) _then;

/// Create a copy of RadarPick
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? track = null,Object? reason = null,Object? score = null,Object? reasonDetail = freezed,}) {
  return _then(_RadarPick(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as HotPlaylistTrack,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RadarReason,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasonDetail: freezed == reasonDetail ? _self.reasonDetail : reasonDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RadarPick
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HotPlaylistTrackCopyWith<$Res> get track {
  
  return $HotPlaylistTrackCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}

// dart format on
