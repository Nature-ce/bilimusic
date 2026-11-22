// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_chart_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicChartEntry {

 MusicChart get chart; List<MusicChartTrack> get tracks; bool get isLoading; String? get errorMessage; int get updatedAtMs;
/// Create a copy of MusicChartEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicChartEntryCopyWith<MusicChartEntry> get copyWith => _$MusicChartEntryCopyWithImpl<MusicChartEntry>(this as MusicChartEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicChartEntry&&(identical(other.chart, chart) || other.chart == chart)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,chart,const DeepCollectionEquality().hash(tracks),isLoading,errorMessage,updatedAtMs);

@override
String toString() {
  return 'MusicChartEntry(chart: $chart, tracks: $tracks, isLoading: $isLoading, errorMessage: $errorMessage, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class $MusicChartEntryCopyWith<$Res>  {
  factory $MusicChartEntryCopyWith(MusicChartEntry value, $Res Function(MusicChartEntry) _then) = _$MusicChartEntryCopyWithImpl;
@useResult
$Res call({
 MusicChart chart, List<MusicChartTrack> tracks, bool isLoading, String? errorMessage, int updatedAtMs
});


$MusicChartCopyWith<$Res> get chart;

}
/// @nodoc
class _$MusicChartEntryCopyWithImpl<$Res>
    implements $MusicChartEntryCopyWith<$Res> {
  _$MusicChartEntryCopyWithImpl(this._self, this._then);

  final MusicChartEntry _self;
  final $Res Function(MusicChartEntry) _then;

/// Create a copy of MusicChartEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chart = null,Object? tracks = null,Object? isLoading = null,Object? errorMessage = freezed,Object? updatedAtMs = null,}) {
  return _then(_self.copyWith(
chart: null == chart ? _self.chart : chart // ignore: cast_nullable_to_non_nullable
as MusicChart,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<MusicChartTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MusicChartEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MusicChartCopyWith<$Res> get chart {
  
  return $MusicChartCopyWith<$Res>(_self.chart, (value) {
    return _then(_self.copyWith(chart: value));
  });
}
}


/// Adds pattern-matching-related methods to [MusicChartEntry].
extension MusicChartEntryPatterns on MusicChartEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicChartEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicChartEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicChartEntry value)  $default,){
final _that = this;
switch (_that) {
case _MusicChartEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicChartEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MusicChartEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MusicChart chart,  List<MusicChartTrack> tracks,  bool isLoading,  String? errorMessage,  int updatedAtMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicChartEntry() when $default != null:
return $default(_that.chart,_that.tracks,_that.isLoading,_that.errorMessage,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MusicChart chart,  List<MusicChartTrack> tracks,  bool isLoading,  String? errorMessage,  int updatedAtMs)  $default,) {final _that = this;
switch (_that) {
case _MusicChartEntry():
return $default(_that.chart,_that.tracks,_that.isLoading,_that.errorMessage,_that.updatedAtMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MusicChart chart,  List<MusicChartTrack> tracks,  bool isLoading,  String? errorMessage,  int updatedAtMs)?  $default,) {final _that = this;
switch (_that) {
case _MusicChartEntry() when $default != null:
return $default(_that.chart,_that.tracks,_that.isLoading,_that.errorMessage,_that.updatedAtMs);case _:
  return null;

}
}

}

/// @nodoc


class _MusicChartEntry extends MusicChartEntry {
  const _MusicChartEntry({required this.chart, final  List<MusicChartTrack> tracks = const <MusicChartTrack>[], this.isLoading = false, this.errorMessage, this.updatedAtMs = 0}): _tracks = tracks,super._();
  

@override final  MusicChart chart;
 final  List<MusicChartTrack> _tracks;
@override@JsonKey() List<MusicChartTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override@JsonKey() final  int updatedAtMs;

/// Create a copy of MusicChartEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicChartEntryCopyWith<_MusicChartEntry> get copyWith => __$MusicChartEntryCopyWithImpl<_MusicChartEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicChartEntry&&(identical(other.chart, chart) || other.chart == chart)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs));
}


@override
int get hashCode => Object.hash(runtimeType,chart,const DeepCollectionEquality().hash(_tracks),isLoading,errorMessage,updatedAtMs);

@override
String toString() {
  return 'MusicChartEntry(chart: $chart, tracks: $tracks, isLoading: $isLoading, errorMessage: $errorMessage, updatedAtMs: $updatedAtMs)';
}


}

/// @nodoc
abstract mixin class _$MusicChartEntryCopyWith<$Res> implements $MusicChartEntryCopyWith<$Res> {
  factory _$MusicChartEntryCopyWith(_MusicChartEntry value, $Res Function(_MusicChartEntry) _then) = __$MusicChartEntryCopyWithImpl;
@override @useResult
$Res call({
 MusicChart chart, List<MusicChartTrack> tracks, bool isLoading, String? errorMessage, int updatedAtMs
});


@override $MusicChartCopyWith<$Res> get chart;

}
/// @nodoc
class __$MusicChartEntryCopyWithImpl<$Res>
    implements _$MusicChartEntryCopyWith<$Res> {
  __$MusicChartEntryCopyWithImpl(this._self, this._then);

  final _MusicChartEntry _self;
  final $Res Function(_MusicChartEntry) _then;

/// Create a copy of MusicChartEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chart = null,Object? tracks = null,Object? isLoading = null,Object? errorMessage = freezed,Object? updatedAtMs = null,}) {
  return _then(_MusicChartEntry(
chart: null == chart ? _self.chart : chart // ignore: cast_nullable_to_non_nullable
as MusicChart,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<MusicChartTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MusicChartEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MusicChartCopyWith<$Res> get chart {
  
  return $MusicChartCopyWith<$Res>(_self.chart, (value) {
    return _then(_self.copyWith(chart: value));
  });
}
}

/// @nodoc
mixin _$MusicChartState {

 Map<MusicChartPlatform, MusicChartEntry> get entries; MusicChartPlatform get selected;
/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicChartStateCopyWith<MusicChartState> get copyWith => _$MusicChartStateCopyWithImpl<MusicChartState>(this as MusicChartState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicChartState&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),selected);

@override
String toString() {
  return 'MusicChartState(entries: $entries, selected: $selected)';
}


}

/// @nodoc
abstract mixin class $MusicChartStateCopyWith<$Res>  {
  factory $MusicChartStateCopyWith(MusicChartState value, $Res Function(MusicChartState) _then) = _$MusicChartStateCopyWithImpl;
@useResult
$Res call({
 Map<MusicChartPlatform, MusicChartEntry> entries, MusicChartPlatform selected
});




}
/// @nodoc
class _$MusicChartStateCopyWithImpl<$Res>
    implements $MusicChartStateCopyWith<$Res> {
  _$MusicChartStateCopyWithImpl(this._self, this._then);

  final MusicChartState _self;
  final $Res Function(MusicChartState) _then;

/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? selected = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<MusicChartPlatform, MusicChartEntry>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,
  ));
}

}


/// Adds pattern-matching-related methods to [MusicChartState].
extension MusicChartStatePatterns on MusicChartState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicChartState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicChartState value)  $default,){
final _that = this;
switch (_that) {
case _MusicChartState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicChartState value)?  $default,){
final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<MusicChartPlatform, MusicChartEntry> entries,  MusicChartPlatform selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
return $default(_that.entries,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<MusicChartPlatform, MusicChartEntry> entries,  MusicChartPlatform selected)  $default,) {final _that = this;
switch (_that) {
case _MusicChartState():
return $default(_that.entries,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<MusicChartPlatform, MusicChartEntry> entries,  MusicChartPlatform selected)?  $default,) {final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
return $default(_that.entries,_that.selected);case _:
  return null;

}
}

}

/// @nodoc


class _MusicChartState extends MusicChartState {
  const _MusicChartState({final  Map<MusicChartPlatform, MusicChartEntry> entries = const <MusicChartPlatform, MusicChartEntry>{}, this.selected = MusicChartPlatform.netease}): _entries = entries,super._();
  

 final  Map<MusicChartPlatform, MusicChartEntry> _entries;
@override@JsonKey() Map<MusicChartPlatform, MusicChartEntry> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}

@override@JsonKey() final  MusicChartPlatform selected;

/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicChartStateCopyWith<_MusicChartState> get copyWith => __$MusicChartStateCopyWithImpl<_MusicChartState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicChartState&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),selected);

@override
String toString() {
  return 'MusicChartState(entries: $entries, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$MusicChartStateCopyWith<$Res> implements $MusicChartStateCopyWith<$Res> {
  factory _$MusicChartStateCopyWith(_MusicChartState value, $Res Function(_MusicChartState) _then) = __$MusicChartStateCopyWithImpl;
@override @useResult
$Res call({
 Map<MusicChartPlatform, MusicChartEntry> entries, MusicChartPlatform selected
});




}
/// @nodoc
class __$MusicChartStateCopyWithImpl<$Res>
    implements _$MusicChartStateCopyWith<$Res> {
  __$MusicChartStateCopyWithImpl(this._self, this._then);

  final _MusicChartState _self;
  final $Res Function(_MusicChartState) _then;

/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? selected = null,}) {
  return _then(_MusicChartState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<MusicChartPlatform, MusicChartEntry>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,
  ));
}


}

// dart format on
