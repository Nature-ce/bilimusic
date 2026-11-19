// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_playlist_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HotPlaylistState {

 MusicChartPlatform get platform; List<HotPlaylist> get playlists; bool get isLoading; String? get errorMessage;
/// Create a copy of HotPlaylistState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotPlaylistStateCopyWith<HotPlaylistState> get copyWith => _$HotPlaylistStateCopyWithImpl<HotPlaylistState>(this as HotPlaylistState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotPlaylistState&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other.playlists, playlists)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,platform,const DeepCollectionEquality().hash(playlists),isLoading,errorMessage);

@override
String toString() {
  return 'HotPlaylistState(platform: $platform, playlists: $playlists, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $HotPlaylistStateCopyWith<$Res>  {
  factory $HotPlaylistStateCopyWith(HotPlaylistState value, $Res Function(HotPlaylistState) _then) = _$HotPlaylistStateCopyWithImpl;
@useResult
$Res call({
 MusicChartPlatform platform, List<HotPlaylist> playlists, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$HotPlaylistStateCopyWithImpl<$Res>
    implements $HotPlaylistStateCopyWith<$Res> {
  _$HotPlaylistStateCopyWithImpl(this._self, this._then);

  final HotPlaylistState _self;
  final $Res Function(HotPlaylistState) _then;

/// Create a copy of HotPlaylistState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? playlists = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,playlists: null == playlists ? _self.playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<HotPlaylist>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HotPlaylistState].
extension HotPlaylistStatePatterns on HotPlaylistState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotPlaylistState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotPlaylistState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotPlaylistState value)  $default,){
final _that = this;
switch (_that) {
case _HotPlaylistState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotPlaylistState value)?  $default,){
final _that = this;
switch (_that) {
case _HotPlaylistState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  List<HotPlaylist> playlists,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotPlaylistState() when $default != null:
return $default(_that.platform,_that.playlists,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  List<HotPlaylist> playlists,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HotPlaylistState():
return $default(_that.platform,_that.playlists,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MusicChartPlatform platform,  List<HotPlaylist> playlists,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HotPlaylistState() when $default != null:
return $default(_that.platform,_that.playlists,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _HotPlaylistState extends HotPlaylistState {
  const _HotPlaylistState({this.platform = MusicChartPlatform.netease, final  List<HotPlaylist> playlists = const <HotPlaylist>[], this.isLoading = false, this.errorMessage}): _playlists = playlists,super._();
  

@override@JsonKey() final  MusicChartPlatform platform;
 final  List<HotPlaylist> _playlists;
@override@JsonKey() List<HotPlaylist> get playlists {
  if (_playlists is EqualUnmodifiableListView) return _playlists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlists);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of HotPlaylistState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotPlaylistStateCopyWith<_HotPlaylistState> get copyWith => __$HotPlaylistStateCopyWithImpl<_HotPlaylistState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotPlaylistState&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other._playlists, _playlists)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,platform,const DeepCollectionEquality().hash(_playlists),isLoading,errorMessage);

@override
String toString() {
  return 'HotPlaylistState(platform: $platform, playlists: $playlists, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HotPlaylistStateCopyWith<$Res> implements $HotPlaylistStateCopyWith<$Res> {
  factory _$HotPlaylistStateCopyWith(_HotPlaylistState value, $Res Function(_HotPlaylistState) _then) = __$HotPlaylistStateCopyWithImpl;
@override @useResult
$Res call({
 MusicChartPlatform platform, List<HotPlaylist> playlists, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$HotPlaylistStateCopyWithImpl<$Res>
    implements _$HotPlaylistStateCopyWith<$Res> {
  __$HotPlaylistStateCopyWithImpl(this._self, this._then);

  final _HotPlaylistState _self;
  final $Res Function(_HotPlaylistState) _then;

/// Create a copy of HotPlaylistState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? playlists = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_HotPlaylistState(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,playlists: null == playlists ? _self._playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<HotPlaylist>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
