// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_detail_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChartDetailData {

 List<MusicChartTrack> get tracks; int get updatedAtMs;
/// Create a copy of ChartDetailData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartDetailDataCopyWith<ChartDetailData> get copyWith => _$ChartDetailDataCopyWithImpl<ChartDetailData>(this as ChartDetailData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartDetailData&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tracks),updatedAtMs);

@override
String toString() {
  return 'ChartDetailData(tracks: $tracks, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class $ChartDetailDataCopyWith<$Res>  {
  factory $ChartDetailDataCopyWith(ChartDetailData value, $Res Function(ChartDetailData) _then) = _$ChartDetailDataCopyWithImpl;
@useResult
$Res call({
 List<MusicChartTrack> tracks, int updatedAtMs
});




}
/// @nodoc
class _$ChartDetailDataCopyWithImpl<$Res>
    implements $ChartDetailDataCopyWith<$Res> {
  _$ChartDetailDataCopyWithImpl(this._self, this._then);

  final ChartDetailData _self;
  final $Res Function(ChartDetailData) _then;

/// Create a copy of ChartDetailData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tracks = null,Object? updatedAtMs = null,}) {
  return _then(_self.copyWith(
tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<MusicChartTrack>,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartDetailData].
extension ChartDetailDataPatterns on ChartDetailData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartDetailData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartDetailData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartDetailData value)  $default,){
final _that = this;
switch (_that) {
case _ChartDetailData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartDetailData value)?  $default,){
final _that = this;
switch (_that) {
case _ChartDetailData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MusicChartTrack> tracks,  int updatedAtMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartDetailData() when $default != null:
return $default(_that.tracks,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MusicChartTrack> tracks,  int updatedAtMs)  $default,) {final _that = this;
switch (_that) {
case _ChartDetailData():
return $default(_that.tracks,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MusicChartTrack> tracks,  int updatedAtMs)?  $default,) {final _that = this;
switch (_that) {
case _ChartDetailData() when $default != null:
return $default(_that.tracks,_that.updatedAtMs);case _:
  return null;

}
}

}

/// @nodoc


class _ChartDetailData implements ChartDetailData {
  const _ChartDetailData({required final  List<MusicChartTrack> tracks, required this.updatedAtMs}): _tracks = tracks;
  

 final  List<MusicChartTrack> _tracks;
@override List<MusicChartTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override final  int updatedAtMs;

/// Create a copy of ChartDetailData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartDetailDataCopyWith<_ChartDetailData> get copyWith => __$ChartDetailDataCopyWithImpl<_ChartDetailData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartDetailData&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tracks),updatedAtMs);

@override
String toString() {
  return 'ChartDetailData(tracks: $tracks, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class _$ChartDetailDataCopyWith<$Res> implements $ChartDetailDataCopyWith<$Res> {
  factory _$ChartDetailDataCopyWith(_ChartDetailData value, $Res Function(_ChartDetailData) _then) = __$ChartDetailDataCopyWithImpl;
@override @useResult
$Res call({
 List<MusicChartTrack> tracks, int updatedAtMs
});




}
/// @nodoc
class __$ChartDetailDataCopyWithImpl<$Res>
    implements _$ChartDetailDataCopyWith<$Res> {
  __$ChartDetailDataCopyWithImpl(this._self, this._then);

  final _ChartDetailData _self;
  final $Res Function(_ChartDetailData) _then;

/// Create a copy of ChartDetailData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tracks = null,Object? updatedAtMs = null,}) {
  return _then(_ChartDetailData(
tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<MusicChartTrack>,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
