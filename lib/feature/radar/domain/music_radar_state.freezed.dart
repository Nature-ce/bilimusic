// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_radar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicRadarState {

 List<HotPlaylistTrack> get tracks; List<RadarPick> get picks; bool get isScanning; bool get isLoadingMore; int get scanCount; int get listenedCount; bool get isPersonalized; String? get errorMessage;
/// Create a copy of MusicRadarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicRadarStateCopyWith<MusicRadarState> get copyWith => _$MusicRadarStateCopyWithImpl<MusicRadarState>(this as MusicRadarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicRadarState&&const DeepCollectionEquality().equals(other.tracks, tracks)&&const DeepCollectionEquality().equals(other.picks, picks)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.scanCount, scanCount) || other.scanCount == scanCount)&&(identical(other.listenedCount, listenedCount) || other.listenedCount == listenedCount)&&(identical(other.isPersonalized, isPersonalized) || other.isPersonalized == isPersonalized)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tracks),const DeepCollectionEquality().hash(picks),isScanning,isLoadingMore,scanCount,listenedCount,isPersonalized,errorMessage);

@override
String toString() {
  return 'MusicRadarState(tracks: $tracks, picks: $picks, isScanning: $isScanning, isLoadingMore: $isLoadingMore, scanCount: $scanCount, listenedCount: $listenedCount, isPersonalized: $isPersonalized, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MusicRadarStateCopyWith<$Res>  {
  factory $MusicRadarStateCopyWith(MusicRadarState value, $Res Function(MusicRadarState) _then) = _$MusicRadarStateCopyWithImpl;
@useResult
$Res call({
 List<HotPlaylistTrack> tracks, List<RadarPick> picks, bool isScanning, bool isLoadingMore, int scanCount, int listenedCount, bool isPersonalized, String? errorMessage
});




}
/// @nodoc
class _$MusicRadarStateCopyWithImpl<$Res>
    implements $MusicRadarStateCopyWith<$Res> {
  _$MusicRadarStateCopyWithImpl(this._self, this._then);

  final MusicRadarState _self;
  final $Res Function(MusicRadarState) _then;

/// Create a copy of MusicRadarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tracks = null,Object? picks = null,Object? isScanning = null,Object? isLoadingMore = null,Object? scanCount = null,Object? listenedCount = null,Object? isPersonalized = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<HotPlaylistTrack>,picks: null == picks ? _self.picks : picks // ignore: cast_nullable_to_non_nullable
as List<RadarPick>,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,scanCount: null == scanCount ? _self.scanCount : scanCount // ignore: cast_nullable_to_non_nullable
as int,listenedCount: null == listenedCount ? _self.listenedCount : listenedCount // ignore: cast_nullable_to_non_nullable
as int,isPersonalized: null == isPersonalized ? _self.isPersonalized : isPersonalized // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MusicRadarState].
extension MusicRadarStatePatterns on MusicRadarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicRadarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicRadarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicRadarState value)  $default,){
final _that = this;
switch (_that) {
case _MusicRadarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicRadarState value)?  $default,){
final _that = this;
switch (_that) {
case _MusicRadarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HotPlaylistTrack> tracks,  List<RadarPick> picks,  bool isScanning,  bool isLoadingMore,  int scanCount,  int listenedCount,  bool isPersonalized,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicRadarState() when $default != null:
return $default(_that.tracks,_that.picks,_that.isScanning,_that.isLoadingMore,_that.scanCount,_that.listenedCount,_that.isPersonalized,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HotPlaylistTrack> tracks,  List<RadarPick> picks,  bool isScanning,  bool isLoadingMore,  int scanCount,  int listenedCount,  bool isPersonalized,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _MusicRadarState():
return $default(_that.tracks,_that.picks,_that.isScanning,_that.isLoadingMore,_that.scanCount,_that.listenedCount,_that.isPersonalized,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HotPlaylistTrack> tracks,  List<RadarPick> picks,  bool isScanning,  bool isLoadingMore,  int scanCount,  int listenedCount,  bool isPersonalized,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _MusicRadarState() when $default != null:
return $default(_that.tracks,_that.picks,_that.isScanning,_that.isLoadingMore,_that.scanCount,_that.listenedCount,_that.isPersonalized,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MusicRadarState extends MusicRadarState {
  const _MusicRadarState({final  List<HotPlaylistTrack> tracks = const <HotPlaylistTrack>[], final  List<RadarPick> picks = const <RadarPick>[], this.isScanning = false, this.isLoadingMore = false, this.scanCount = 0, this.listenedCount = 0, this.isPersonalized = false, this.errorMessage}): _tracks = tracks,_picks = picks,super._();
  

 final  List<HotPlaylistTrack> _tracks;
@override@JsonKey() List<HotPlaylistTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

 final  List<RadarPick> _picks;
@override@JsonKey() List<RadarPick> get picks {
  if (_picks is EqualUnmodifiableListView) return _picks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_picks);
}

@override@JsonKey() final  bool isScanning;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  int scanCount;
@override@JsonKey() final  int listenedCount;
@override@JsonKey() final  bool isPersonalized;
@override final  String? errorMessage;

/// Create a copy of MusicRadarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicRadarStateCopyWith<_MusicRadarState> get copyWith => __$MusicRadarStateCopyWithImpl<_MusicRadarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicRadarState&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&const DeepCollectionEquality().equals(other._picks, _picks)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.scanCount, scanCount) || other.scanCount == scanCount)&&(identical(other.listenedCount, listenedCount) || other.listenedCount == listenedCount)&&(identical(other.isPersonalized, isPersonalized) || other.isPersonalized == isPersonalized)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tracks),const DeepCollectionEquality().hash(_picks),isScanning,isLoadingMore,scanCount,listenedCount,isPersonalized,errorMessage);

@override
String toString() {
  return 'MusicRadarState(tracks: $tracks, picks: $picks, isScanning: $isScanning, isLoadingMore: $isLoadingMore, scanCount: $scanCount, listenedCount: $listenedCount, isPersonalized: $isPersonalized, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MusicRadarStateCopyWith<$Res> implements $MusicRadarStateCopyWith<$Res> {
  factory _$MusicRadarStateCopyWith(_MusicRadarState value, $Res Function(_MusicRadarState) _then) = __$MusicRadarStateCopyWithImpl;
@override @useResult
$Res call({
 List<HotPlaylistTrack> tracks, List<RadarPick> picks, bool isScanning, bool isLoadingMore, int scanCount, int listenedCount, bool isPersonalized, String? errorMessage
});




}
/// @nodoc
class __$MusicRadarStateCopyWithImpl<$Res>
    implements _$MusicRadarStateCopyWith<$Res> {
  __$MusicRadarStateCopyWithImpl(this._self, this._then);

  final _MusicRadarState _self;
  final $Res Function(_MusicRadarState) _then;

/// Create a copy of MusicRadarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tracks = null,Object? picks = null,Object? isScanning = null,Object? isLoadingMore = null,Object? scanCount = null,Object? listenedCount = null,Object? isPersonalized = null,Object? errorMessage = freezed,}) {
  return _then(_MusicRadarState(
tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<HotPlaylistTrack>,picks: null == picks ? _self._picks : picks // ignore: cast_nullable_to_non_nullable
as List<RadarPick>,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,scanCount: null == scanCount ? _self.scanCount : scanCount // ignore: cast_nullable_to_non_nullable
as int,listenedCount: null == listenedCount ? _self.listenedCount : listenedCount // ignore: cast_nullable_to_non_nullable
as int,isPersonalized: null == isPersonalized ? _self.isPersonalized : isPersonalized // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
