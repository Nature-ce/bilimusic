// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radar_play_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RadarPlayRecord {

 String get stableId; String get title; String get artist; int get playedMs; int get durationMs; int get playCount; int get updatedAtMs;
/// Create a copy of RadarPlayRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadarPlayRecordCopyWith<RadarPlayRecord> get copyWith => _$RadarPlayRecordCopyWithImpl<RadarPlayRecord>(this as RadarPlayRecord, _$identity);

  /// Serializes this RadarPlayRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadarPlayRecord&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.playedMs, playedMs) || other.playedMs == playedMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stableId,title,artist,playedMs,durationMs,playCount,updatedAtMs);

@override
String toString() {
  return 'RadarPlayRecord(stableId: $stableId, title: $title, artist: $artist, playedMs: $playedMs, durationMs: $durationMs, playCount: $playCount, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class $RadarPlayRecordCopyWith<$Res>  {
  factory $RadarPlayRecordCopyWith(RadarPlayRecord value, $Res Function(RadarPlayRecord) _then) = _$RadarPlayRecordCopyWithImpl;
@useResult
$Res call({
 String stableId, String title, String artist, int playedMs, int durationMs, int playCount, int updatedAtMs
});




}
/// @nodoc
class _$RadarPlayRecordCopyWithImpl<$Res>
    implements $RadarPlayRecordCopyWith<$Res> {
  _$RadarPlayRecordCopyWithImpl(this._self, this._then);

  final RadarPlayRecord _self;
  final $Res Function(RadarPlayRecord) _then;

/// Create a copy of RadarPlayRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = null,Object? title = null,Object? artist = null,Object? playedMs = null,Object? durationMs = null,Object? playCount = null,Object? updatedAtMs = null,}) {
  return _then(_self.copyWith(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,playedMs: null == playedMs ? _self.playedMs : playedMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RadarPlayRecord].
extension RadarPlayRecordPatterns on RadarPlayRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RadarPlayRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RadarPlayRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RadarPlayRecord value)  $default,){
final _that = this;
switch (_that) {
case _RadarPlayRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RadarPlayRecord value)?  $default,){
final _that = this;
switch (_that) {
case _RadarPlayRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stableId,  String title,  String artist,  int playedMs,  int durationMs,  int playCount,  int updatedAtMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RadarPlayRecord() when $default != null:
return $default(_that.stableId,_that.title,_that.artist,_that.playedMs,_that.durationMs,_that.playCount,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stableId,  String title,  String artist,  int playedMs,  int durationMs,  int playCount,  int updatedAtMs)  $default,) {final _that = this;
switch (_that) {
case _RadarPlayRecord():
return $default(_that.stableId,_that.title,_that.artist,_that.playedMs,_that.durationMs,_that.playCount,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stableId,  String title,  String artist,  int playedMs,  int durationMs,  int playCount,  int updatedAtMs)?  $default,) {final _that = this;
switch (_that) {
case _RadarPlayRecord() when $default != null:
return $default(_that.stableId,_that.title,_that.artist,_that.playedMs,_that.durationMs,_that.playCount,_that.updatedAtMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RadarPlayRecord extends RadarPlayRecord {
  const _RadarPlayRecord({required this.stableId, required this.title, required this.artist, this.playedMs = 0, this.durationMs = 0, this.playCount = 1, this.updatedAtMs = 0}): super._();
  factory _RadarPlayRecord.fromJson(Map<String, dynamic> json) => _$RadarPlayRecordFromJson(json);

@override final  String stableId;
@override final  String title;
@override final  String artist;
@override@JsonKey() final  int playedMs;
@override@JsonKey() final  int durationMs;
@override@JsonKey() final  int playCount;
@override@JsonKey() final  int updatedAtMs;

/// Create a copy of RadarPlayRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RadarPlayRecordCopyWith<_RadarPlayRecord> get copyWith => __$RadarPlayRecordCopyWithImpl<_RadarPlayRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RadarPlayRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RadarPlayRecord&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.playedMs, playedMs) || other.playedMs == playedMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stableId,title,artist,playedMs,durationMs,playCount,updatedAtMs);

@override
String toString() {
  return 'RadarPlayRecord(stableId: $stableId, title: $title, artist: $artist, playedMs: $playedMs, durationMs: $durationMs, playCount: $playCount, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class _$RadarPlayRecordCopyWith<$Res> implements $RadarPlayRecordCopyWith<$Res> {
  factory _$RadarPlayRecordCopyWith(_RadarPlayRecord value, $Res Function(_RadarPlayRecord) _then) = __$RadarPlayRecordCopyWithImpl;
@override @useResult
$Res call({
 String stableId, String title, String artist, int playedMs, int durationMs, int playCount, int updatedAtMs
});




}
/// @nodoc
class __$RadarPlayRecordCopyWithImpl<$Res>
    implements _$RadarPlayRecordCopyWith<$Res> {
  __$RadarPlayRecordCopyWithImpl(this._self, this._then);

  final _RadarPlayRecord _self;
  final $Res Function(_RadarPlayRecord) _then;

/// Create a copy of RadarPlayRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = null,Object? title = null,Object? artist = null,Object? playedMs = null,Object? durationMs = null,Object? playCount = null,Object? updatedAtMs = null,}) {
  return _then(_RadarPlayRecord(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,playedMs: null == playedMs ? _self.playedMs : playedMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
