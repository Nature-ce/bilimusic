// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_playlist_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HotPlaylistDetailState {

 HotPlaylist get playlist; List<HotPlaylistTrack> get tracks; bool get isLoading; String? get errorMessage;
/// Create a copy of HotPlaylistDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotPlaylistDetailStateCopyWith<HotPlaylistDetailState> get copyWith => _$HotPlaylistDetailStateCopyWithImpl<HotPlaylistDetailState>(this as HotPlaylistDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotPlaylistDetailState&&(identical(other.playlist, playlist) || other.playlist == playlist)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,playlist,const DeepCollectionEquality().hash(tracks),isLoading,errorMessage);

@override
String toString() {
  return 'HotPlaylistDetailState(playlist: $playlist, tracks: $tracks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $HotPlaylistDetailStateCopyWith<$Res>  {
  factory $HotPlaylistDetailStateCopyWith(HotPlaylistDetailState value, $Res Function(HotPlaylistDetailState) _then) = _$HotPlaylistDetailStateCopyWithImpl;
@useResult
$Res call({
 HotPlaylist playlist, List<HotPlaylistTrack> tracks, bool isLoading, String? errorMessage
});


$HotPlaylistCopyWith<$Res> get playlist;

}
/// @nodoc
class _$HotPlaylistDetailStateCopyWithImpl<$Res>
    implements $HotPlaylistDetailStateCopyWith<$Res> {
  _$HotPlaylistDetailStateCopyWithImpl(this._self, this._then);

  final HotPlaylistDetailState _self;
  final $Res Function(HotPlaylistDetailState) _then;

/// Create a copy of HotPlaylistDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playlist = null,Object? tracks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
playlist: null == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as HotPlaylist,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<HotPlaylistTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HotPlaylistDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HotPlaylistCopyWith<$Res> get playlist {
  
  return $HotPlaylistCopyWith<$Res>(_self.playlist, (value) {
    return _then(_self.copyWith(playlist: value));
  });
}
}


/// Adds pattern-matching-related methods to [HotPlaylistDetailState].
extension HotPlaylistDetailStatePatterns on HotPlaylistDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotPlaylistDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotPlaylistDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotPlaylistDetailState value)  $default,){
final _that = this;
switch (_that) {
case _HotPlaylistDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotPlaylistDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _HotPlaylistDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotPlaylist playlist,  List<HotPlaylistTrack> tracks,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotPlaylistDetailState() when $default != null:
return $default(_that.playlist,_that.tracks,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotPlaylist playlist,  List<HotPlaylistTrack> tracks,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HotPlaylistDetailState():
return $default(_that.playlist,_that.tracks,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotPlaylist playlist,  List<HotPlaylistTrack> tracks,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HotPlaylistDetailState() when $default != null:
return $default(_that.playlist,_that.tracks,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _HotPlaylistDetailState extends HotPlaylistDetailState {
  const _HotPlaylistDetailState({required this.playlist, final  List<HotPlaylistTrack> tracks = const <HotPlaylistTrack>[], this.isLoading = false, this.errorMessage}): _tracks = tracks,super._();
  

@override final  HotPlaylist playlist;
 final  List<HotPlaylistTrack> _tracks;
@override@JsonKey() List<HotPlaylistTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of HotPlaylistDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotPlaylistDetailStateCopyWith<_HotPlaylistDetailState> get copyWith => __$HotPlaylistDetailStateCopyWithImpl<_HotPlaylistDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotPlaylistDetailState&&(identical(other.playlist, playlist) || other.playlist == playlist)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,playlist,const DeepCollectionEquality().hash(_tracks),isLoading,errorMessage);

@override
String toString() {
  return 'HotPlaylistDetailState(playlist: $playlist, tracks: $tracks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HotPlaylistDetailStateCopyWith<$Res> implements $HotPlaylistDetailStateCopyWith<$Res> {
  factory _$HotPlaylistDetailStateCopyWith(_HotPlaylistDetailState value, $Res Function(_HotPlaylistDetailState) _then) = __$HotPlaylistDetailStateCopyWithImpl;
@override @useResult
$Res call({
 HotPlaylist playlist, List<HotPlaylistTrack> tracks, bool isLoading, String? errorMessage
});


@override $HotPlaylistCopyWith<$Res> get playlist;

}
/// @nodoc
class __$HotPlaylistDetailStateCopyWithImpl<$Res>
    implements _$HotPlaylistDetailStateCopyWith<$Res> {
  __$HotPlaylistDetailStateCopyWithImpl(this._self, this._then);

  final _HotPlaylistDetailState _self;
  final $Res Function(_HotPlaylistDetailState) _then;

/// Create a copy of HotPlaylistDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playlist = null,Object? tracks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_HotPlaylistDetailState(
playlist: null == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as HotPlaylist,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<HotPlaylistTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HotPlaylistDetailState
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
