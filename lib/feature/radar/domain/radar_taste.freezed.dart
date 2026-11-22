// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'radar_taste.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RadarTaste {

 Map<String, double> get artists; Map<String, double> get dislikedTracks; Set<String> get recentTrackKeys; List<String> get likedTitleBlobs; int get sampleCount;
/// Create a copy of RadarTaste
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadarTasteCopyWith<RadarTaste> get copyWith => _$RadarTasteCopyWithImpl<RadarTaste>(this as RadarTaste, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadarTaste&&const DeepCollectionEquality().equals(other.artists, artists)&&const DeepCollectionEquality().equals(other.dislikedTracks, dislikedTracks)&&const DeepCollectionEquality().equals(other.recentTrackKeys, recentTrackKeys)&&const DeepCollectionEquality().equals(other.likedTitleBlobs, likedTitleBlobs)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(artists),const DeepCollectionEquality().hash(dislikedTracks),const DeepCollectionEquality().hash(recentTrackKeys),const DeepCollectionEquality().hash(likedTitleBlobs),sampleCount);

@override
String toString() {
  return 'RadarTaste(artists: $artists, dislikedTracks: $dislikedTracks, recentTrackKeys: $recentTrackKeys, likedTitleBlobs: $likedTitleBlobs, sampleCount: $sampleCount)';
}


}

/// @nodoc
abstract mixin class $RadarTasteCopyWith<$Res>  {
  factory $RadarTasteCopyWith(RadarTaste value, $Res Function(RadarTaste) _then) = _$RadarTasteCopyWithImpl;
@useResult
$Res call({
 Map<String, double> artists, Map<String, double> dislikedTracks, Set<String> recentTrackKeys, List<String> likedTitleBlobs, int sampleCount
});




}
/// @nodoc
class _$RadarTasteCopyWithImpl<$Res>
    implements $RadarTasteCopyWith<$Res> {
  _$RadarTasteCopyWithImpl(this._self, this._then);

  final RadarTaste _self;
  final $Res Function(RadarTaste) _then;

/// Create a copy of RadarTaste
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? artists = null,Object? dislikedTracks = null,Object? recentTrackKeys = null,Object? likedTitleBlobs = null,Object? sampleCount = null,}) {
  return _then(_self.copyWith(
artists: null == artists ? _self.artists : artists // ignore: cast_nullable_to_non_nullable
as Map<String, double>,dislikedTracks: null == dislikedTracks ? _self.dislikedTracks : dislikedTracks // ignore: cast_nullable_to_non_nullable
as Map<String, double>,recentTrackKeys: null == recentTrackKeys ? _self.recentTrackKeys : recentTrackKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,likedTitleBlobs: null == likedTitleBlobs ? _self.likedTitleBlobs : likedTitleBlobs // ignore: cast_nullable_to_non_nullable
as List<String>,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RadarTaste].
extension RadarTastePatterns on RadarTaste {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RadarTaste value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RadarTaste() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RadarTaste value)  $default,){
final _that = this;
switch (_that) {
case _RadarTaste():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RadarTaste value)?  $default,){
final _that = this;
switch (_that) {
case _RadarTaste() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, double> artists,  Map<String, double> dislikedTracks,  Set<String> recentTrackKeys,  List<String> likedTitleBlobs,  int sampleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RadarTaste() when $default != null:
return $default(_that.artists,_that.dislikedTracks,_that.recentTrackKeys,_that.likedTitleBlobs,_that.sampleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, double> artists,  Map<String, double> dislikedTracks,  Set<String> recentTrackKeys,  List<String> likedTitleBlobs,  int sampleCount)  $default,) {final _that = this;
switch (_that) {
case _RadarTaste():
return $default(_that.artists,_that.dislikedTracks,_that.recentTrackKeys,_that.likedTitleBlobs,_that.sampleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, double> artists,  Map<String, double> dislikedTracks,  Set<String> recentTrackKeys,  List<String> likedTitleBlobs,  int sampleCount)?  $default,) {final _that = this;
switch (_that) {
case _RadarTaste() when $default != null:
return $default(_that.artists,_that.dislikedTracks,_that.recentTrackKeys,_that.likedTitleBlobs,_that.sampleCount);case _:
  return null;

}
}

}

/// @nodoc


class _RadarTaste extends RadarTaste {
  const _RadarTaste({final  Map<String, double> artists = const <String, double>{}, final  Map<String, double> dislikedTracks = const <String, double>{}, final  Set<String> recentTrackKeys = const <String>{}, final  List<String> likedTitleBlobs = const <String>[], this.sampleCount = 0}): _artists = artists,_dislikedTracks = dislikedTracks,_recentTrackKeys = recentTrackKeys,_likedTitleBlobs = likedTitleBlobs,super._();
  

 final  Map<String, double> _artists;
@override@JsonKey() Map<String, double> get artists {
  if (_artists is EqualUnmodifiableMapView) return _artists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_artists);
}

 final  Map<String, double> _dislikedTracks;
@override@JsonKey() Map<String, double> get dislikedTracks {
  if (_dislikedTracks is EqualUnmodifiableMapView) return _dislikedTracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dislikedTracks);
}

 final  Set<String> _recentTrackKeys;
@override@JsonKey() Set<String> get recentTrackKeys {
  if (_recentTrackKeys is EqualUnmodifiableSetView) return _recentTrackKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_recentTrackKeys);
}

 final  List<String> _likedTitleBlobs;
@override@JsonKey() List<String> get likedTitleBlobs {
  if (_likedTitleBlobs is EqualUnmodifiableListView) return _likedTitleBlobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedTitleBlobs);
}

@override@JsonKey() final  int sampleCount;

/// Create a copy of RadarTaste
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RadarTasteCopyWith<_RadarTaste> get copyWith => __$RadarTasteCopyWithImpl<_RadarTaste>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RadarTaste&&const DeepCollectionEquality().equals(other._artists, _artists)&&const DeepCollectionEquality().equals(other._dislikedTracks, _dislikedTracks)&&const DeepCollectionEquality().equals(other._recentTrackKeys, _recentTrackKeys)&&const DeepCollectionEquality().equals(other._likedTitleBlobs, _likedTitleBlobs)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_artists),const DeepCollectionEquality().hash(_dislikedTracks),const DeepCollectionEquality().hash(_recentTrackKeys),const DeepCollectionEquality().hash(_likedTitleBlobs),sampleCount);

@override
String toString() {
  return 'RadarTaste(artists: $artists, dislikedTracks: $dislikedTracks, recentTrackKeys: $recentTrackKeys, likedTitleBlobs: $likedTitleBlobs, sampleCount: $sampleCount)';
}


}

/// @nodoc
abstract mixin class _$RadarTasteCopyWith<$Res> implements $RadarTasteCopyWith<$Res> {
  factory _$RadarTasteCopyWith(_RadarTaste value, $Res Function(_RadarTaste) _then) = __$RadarTasteCopyWithImpl;
@override @useResult
$Res call({
 Map<String, double> artists, Map<String, double> dislikedTracks, Set<String> recentTrackKeys, List<String> likedTitleBlobs, int sampleCount
});




}
/// @nodoc
class __$RadarTasteCopyWithImpl<$Res>
    implements _$RadarTasteCopyWith<$Res> {
  __$RadarTasteCopyWithImpl(this._self, this._then);

  final _RadarTaste _self;
  final $Res Function(_RadarTaste) _then;

/// Create a copy of RadarTaste
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? artists = null,Object? dislikedTracks = null,Object? recentTrackKeys = null,Object? likedTitleBlobs = null,Object? sampleCount = null,}) {
  return _then(_RadarTaste(
artists: null == artists ? _self._artists : artists // ignore: cast_nullable_to_non_nullable
as Map<String, double>,dislikedTracks: null == dislikedTracks ? _self._dislikedTracks : dislikedTracks // ignore: cast_nullable_to_non_nullable
as Map<String, double>,recentTrackKeys: null == recentTrackKeys ? _self._recentTrackKeys : recentTrackKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,likedTitleBlobs: null == likedTitleBlobs ? _self._likedTitleBlobs : likedTitleBlobs // ignore: cast_nullable_to_non_nullable
as List<String>,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
