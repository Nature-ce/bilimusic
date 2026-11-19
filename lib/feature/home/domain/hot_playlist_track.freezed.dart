// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_playlist_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HotPlaylistTrack {

 HotPlaylist get playlist; int get rank; String get title; String get artist; String get coverUrl; int get durationSeconds;
/// Create a copy of HotPlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotPlaylistTrackCopyWith<HotPlaylistTrack> get copyWith => _$HotPlaylistTrackCopyWithImpl<HotPlaylistTrack>(this as HotPlaylistTrack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotPlaylistTrack&&(identical(other.playlist, playlist) || other.playlist == playlist)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,playlist,rank,title,artist,coverUrl,durationSeconds);

@override
String toString() {
  return 'HotPlaylistTrack(playlist: $playlist, rank: $rank, title: $title, artist: $artist, coverUrl: $coverUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $HotPlaylistTrackCopyWith<$Res>  {
  factory $HotPlaylistTrackCopyWith(HotPlaylistTrack value, $Res Function(HotPlaylistTrack) _then) = _$HotPlaylistTrackCopyWithImpl;
@useResult
$Res call({
 HotPlaylist playlist, int rank, String title, String artist, String coverUrl, int durationSeconds
});


$HotPlaylistCopyWith<$Res> get playlist;

}
/// @nodoc
class _$HotPlaylistTrackCopyWithImpl<$Res>
    implements $HotPlaylistTrackCopyWith<$Res> {
  _$HotPlaylistTrackCopyWithImpl(this._self, this._then);

  final HotPlaylistTrack _self;
  final $Res Function(HotPlaylistTrack) _then;

/// Create a copy of HotPlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playlist = null,Object? rank = null,Object? title = null,Object? artist = null,Object? coverUrl = null,Object? durationSeconds = null,}) {
  return _then(_self.copyWith(
playlist: null == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as HotPlaylist,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of HotPlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HotPlaylistCopyWith<$Res> get playlist {
  
  return $HotPlaylistCopyWith<$Res>(_self.playlist, (value) {
    return _then(_self.copyWith(playlist: value));
  });
}
}


/// Adds pattern-matching-related methods to [HotPlaylistTrack].
extension HotPlaylistTrackPatterns on HotPlaylistTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotPlaylistTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotPlaylistTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotPlaylistTrack value)  $default,){
final _that = this;
switch (_that) {
case _HotPlaylistTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotPlaylistTrack value)?  $default,){
final _that = this;
switch (_that) {
case _HotPlaylistTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotPlaylist playlist,  int rank,  String title,  String artist,  String coverUrl,  int durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotPlaylistTrack() when $default != null:
return $default(_that.playlist,_that.rank,_that.title,_that.artist,_that.coverUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotPlaylist playlist,  int rank,  String title,  String artist,  String coverUrl,  int durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _HotPlaylistTrack():
return $default(_that.playlist,_that.rank,_that.title,_that.artist,_that.coverUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotPlaylist playlist,  int rank,  String title,  String artist,  String coverUrl,  int durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _HotPlaylistTrack() when $default != null:
return $default(_that.playlist,_that.rank,_that.title,_that.artist,_that.coverUrl,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _HotPlaylistTrack extends HotPlaylistTrack {
  const _HotPlaylistTrack({required this.playlist, required this.rank, required this.title, required this.artist, required this.coverUrl, this.durationSeconds = 0}): super._();
  

@override final  HotPlaylist playlist;
@override final  int rank;
@override final  String title;
@override final  String artist;
@override final  String coverUrl;
@override@JsonKey() final  int durationSeconds;

/// Create a copy of HotPlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotPlaylistTrackCopyWith<_HotPlaylistTrack> get copyWith => __$HotPlaylistTrackCopyWithImpl<_HotPlaylistTrack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotPlaylistTrack&&(identical(other.playlist, playlist) || other.playlist == playlist)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,playlist,rank,title,artist,coverUrl,durationSeconds);

@override
String toString() {
  return 'HotPlaylistTrack(playlist: $playlist, rank: $rank, title: $title, artist: $artist, coverUrl: $coverUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$HotPlaylistTrackCopyWith<$Res> implements $HotPlaylistTrackCopyWith<$Res> {
  factory _$HotPlaylistTrackCopyWith(_HotPlaylistTrack value, $Res Function(_HotPlaylistTrack) _then) = __$HotPlaylistTrackCopyWithImpl;
@override @useResult
$Res call({
 HotPlaylist playlist, int rank, String title, String artist, String coverUrl, int durationSeconds
});


@override $HotPlaylistCopyWith<$Res> get playlist;

}
/// @nodoc
class __$HotPlaylistTrackCopyWithImpl<$Res>
    implements _$HotPlaylistTrackCopyWith<$Res> {
  __$HotPlaylistTrackCopyWithImpl(this._self, this._then);

  final _HotPlaylistTrack _self;
  final $Res Function(_HotPlaylistTrack) _then;

/// Create a copy of HotPlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playlist = null,Object? rank = null,Object? title = null,Object? artist = null,Object? coverUrl = null,Object? durationSeconds = null,}) {
  return _then(_HotPlaylistTrack(
playlist: null == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as HotPlaylist,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of HotPlaylistTrack
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HotPlaylistCopyWith<$Res> get playlist {
  
  return $HotPlaylistCopyWith<$Res>(_self.playlist, (value) {
    return _then(_self.copyWith(playlist: value));
  });
}
}

// dart format on
