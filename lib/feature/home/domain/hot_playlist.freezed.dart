// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HotPlaylist {

 MusicChartPlatform get platform; String get id; String get name; String get coverUrl; int get playCount; int get trackCount; int get favoriteCount; String get creator; String get description;
/// Create a copy of HotPlaylist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotPlaylistCopyWith<HotPlaylist> get copyWith => _$HotPlaylistCopyWithImpl<HotPlaylist>(this as HotPlaylist, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotPlaylist&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,platform,id,name,coverUrl,playCount,trackCount,favoriteCount,creator,description);

@override
String toString() {
  return 'HotPlaylist(platform: $platform, id: $id, name: $name, coverUrl: $coverUrl, playCount: $playCount, trackCount: $trackCount, favoriteCount: $favoriteCount, creator: $creator, description: $description)';
}


}

/// @nodoc
abstract mixin class $HotPlaylistCopyWith<$Res>  {
  factory $HotPlaylistCopyWith(HotPlaylist value, $Res Function(HotPlaylist) _then) = _$HotPlaylistCopyWithImpl;
@useResult
$Res call({
 MusicChartPlatform platform, String id, String name, String coverUrl, int playCount, int trackCount, int favoriteCount, String creator, String description
});




}
/// @nodoc
class _$HotPlaylistCopyWithImpl<$Res>
    implements $HotPlaylistCopyWith<$Res> {
  _$HotPlaylistCopyWithImpl(this._self, this._then);

  final HotPlaylist _self;
  final $Res Function(HotPlaylist) _then;

/// Create a copy of HotPlaylist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? id = null,Object? name = null,Object? coverUrl = null,Object? playCount = null,Object? trackCount = null,Object? favoriteCount = null,Object? creator = null,Object? description = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HotPlaylist].
extension HotPlaylistPatterns on HotPlaylist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotPlaylist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotPlaylist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotPlaylist value)  $default,){
final _that = this;
switch (_that) {
case _HotPlaylist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotPlaylist value)?  $default,){
final _that = this;
switch (_that) {
case _HotPlaylist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  String id,  String name,  String coverUrl,  int playCount,  int trackCount,  int favoriteCount,  String creator,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotPlaylist() when $default != null:
return $default(_that.platform,_that.id,_that.name,_that.coverUrl,_that.playCount,_that.trackCount,_that.favoriteCount,_that.creator,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  String id,  String name,  String coverUrl,  int playCount,  int trackCount,  int favoriteCount,  String creator,  String description)  $default,) {final _that = this;
switch (_that) {
case _HotPlaylist():
return $default(_that.platform,_that.id,_that.name,_that.coverUrl,_that.playCount,_that.trackCount,_that.favoriteCount,_that.creator,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MusicChartPlatform platform,  String id,  String name,  String coverUrl,  int playCount,  int trackCount,  int favoriteCount,  String creator,  String description)?  $default,) {final _that = this;
switch (_that) {
case _HotPlaylist() when $default != null:
return $default(_that.platform,_that.id,_that.name,_that.coverUrl,_that.playCount,_that.trackCount,_that.favoriteCount,_that.creator,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _HotPlaylist extends HotPlaylist {
  const _HotPlaylist({required this.platform, required this.id, required this.name, required this.coverUrl, this.playCount = 0, this.trackCount = 0, this.favoriteCount = 0, this.creator = '', this.description = ''}): super._();
  

@override final  MusicChartPlatform platform;
@override final  String id;
@override final  String name;
@override final  String coverUrl;
@override@JsonKey() final  int playCount;
@override@JsonKey() final  int trackCount;
@override@JsonKey() final  int favoriteCount;
@override@JsonKey() final  String creator;
@override@JsonKey() final  String description;

/// Create a copy of HotPlaylist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotPlaylistCopyWith<_HotPlaylist> get copyWith => __$HotPlaylistCopyWithImpl<_HotPlaylist>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotPlaylist&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,platform,id,name,coverUrl,playCount,trackCount,favoriteCount,creator,description);

@override
String toString() {
  return 'HotPlaylist(platform: $platform, id: $id, name: $name, coverUrl: $coverUrl, playCount: $playCount, trackCount: $trackCount, favoriteCount: $favoriteCount, creator: $creator, description: $description)';
}


}

/// @nodoc
abstract mixin class _$HotPlaylistCopyWith<$Res> implements $HotPlaylistCopyWith<$Res> {
  factory _$HotPlaylistCopyWith(_HotPlaylist value, $Res Function(_HotPlaylist) _then) = __$HotPlaylistCopyWithImpl;
@override @useResult
$Res call({
 MusicChartPlatform platform, String id, String name, String coverUrl, int playCount, int trackCount, int favoriteCount, String creator, String description
});




}
/// @nodoc
class __$HotPlaylistCopyWithImpl<$Res>
    implements _$HotPlaylistCopyWith<$Res> {
  __$HotPlaylistCopyWithImpl(this._self, this._then);

  final _HotPlaylist _self;
  final $Res Function(_HotPlaylist) _then;

/// Create a copy of HotPlaylist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? id = null,Object? name = null,Object? coverUrl = null,Object? playCount = null,Object? trackCount = null,Object? favoriteCount = null,Object? creator = null,Object? description = null,}) {
  return _then(_HotPlaylist(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,favoriteCount: null == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
