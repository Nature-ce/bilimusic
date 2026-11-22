// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_listening.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyListening {

 int get listenedMs; int get songs;
/// Create a copy of DailyListening
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyListeningCopyWith<DailyListening> get copyWith => _$DailyListeningCopyWithImpl<DailyListening>(this as DailyListening, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyListening&&(identical(other.listenedMs, listenedMs) || other.listenedMs == listenedMs)&&(identical(other.songs, songs) || other.songs == songs));
}


@override
int get hashCode => Object.hash(runtimeType,listenedMs,songs);

@override
String toString() {
  return 'DailyListening(listenedMs: $listenedMs, songs: $songs)';
}


}

/// @nodoc
abstract mixin class $DailyListeningCopyWith<$Res>  {
  factory $DailyListeningCopyWith(DailyListening value, $Res Function(DailyListening) _then) = _$DailyListeningCopyWithImpl;
@useResult
$Res call({
 int listenedMs, int songs
});




}
/// @nodoc
class _$DailyListeningCopyWithImpl<$Res>
    implements $DailyListeningCopyWith<$Res> {
  _$DailyListeningCopyWithImpl(this._self, this._then);

  final DailyListening _self;
  final $Res Function(DailyListening) _then;

/// Create a copy of DailyListening
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listenedMs = null,Object? songs = null,}) {
  return _then(_self.copyWith(
listenedMs: null == listenedMs ? _self.listenedMs : listenedMs // ignore: cast_nullable_to_non_nullable
as int,songs: null == songs ? _self.songs : songs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyListening].
extension DailyListeningPatterns on DailyListening {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyListening value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyListening() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyListening value)  $default,){
final _that = this;
switch (_that) {
case _DailyListening():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyListening value)?  $default,){
final _that = this;
switch (_that) {
case _DailyListening() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int listenedMs,  int songs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyListening() when $default != null:
return $default(_that.listenedMs,_that.songs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int listenedMs,  int songs)  $default,) {final _that = this;
switch (_that) {
case _DailyListening():
return $default(_that.listenedMs,_that.songs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int listenedMs,  int songs)?  $default,) {final _that = this;
switch (_that) {
case _DailyListening() when $default != null:
return $default(_that.listenedMs,_that.songs);case _:
  return null;

}
}

}

/// @nodoc


class _DailyListening implements DailyListening {
  const _DailyListening({this.listenedMs = 0, this.songs = 0});
  

@override@JsonKey() final  int listenedMs;
@override@JsonKey() final  int songs;

/// Create a copy of DailyListening
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyListeningCopyWith<_DailyListening> get copyWith => __$DailyListeningCopyWithImpl<_DailyListening>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyListening&&(identical(other.listenedMs, listenedMs) || other.listenedMs == listenedMs)&&(identical(other.songs, songs) || other.songs == songs));
}


@override
int get hashCode => Object.hash(runtimeType,listenedMs,songs);

@override
String toString() {
  return 'DailyListening(listenedMs: $listenedMs, songs: $songs)';
}


}

/// @nodoc
abstract mixin class _$DailyListeningCopyWith<$Res> implements $DailyListeningCopyWith<$Res> {
  factory _$DailyListeningCopyWith(_DailyListening value, $Res Function(_DailyListening) _then) = __$DailyListeningCopyWithImpl;
@override @useResult
$Res call({
 int listenedMs, int songs
});




}
/// @nodoc
class __$DailyListeningCopyWithImpl<$Res>
    implements _$DailyListeningCopyWith<$Res> {
  __$DailyListeningCopyWithImpl(this._self, this._then);

  final _DailyListening _self;
  final $Res Function(_DailyListening) _then;

/// Create a copy of DailyListening
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listenedMs = null,Object? songs = null,}) {
  return _then(_DailyListening(
listenedMs: null == listenedMs ? _self.listenedMs : listenedMs // ignore: cast_nullable_to_non_nullable
as int,songs: null == songs ? _self.songs : songs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$WeeklyListeningSummary {

 List<DailyListening> get days; int get weekListenedMs; int get weekSongs; int get lastWeekSongs;
/// Create a copy of WeeklyListeningSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyListeningSummaryCopyWith<WeeklyListeningSummary> get copyWith => _$WeeklyListeningSummaryCopyWithImpl<WeeklyListeningSummary>(this as WeeklyListeningSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyListeningSummary&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.weekListenedMs, weekListenedMs) || other.weekListenedMs == weekListenedMs)&&(identical(other.weekSongs, weekSongs) || other.weekSongs == weekSongs)&&(identical(other.lastWeekSongs, lastWeekSongs) || other.lastWeekSongs == lastWeekSongs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),weekListenedMs,weekSongs,lastWeekSongs);

@override
String toString() {
  return 'WeeklyListeningSummary(days: $days, weekListenedMs: $weekListenedMs, weekSongs: $weekSongs, lastWeekSongs: $lastWeekSongs)';
}


}

/// @nodoc
abstract mixin class $WeeklyListeningSummaryCopyWith<$Res>  {
  factory $WeeklyListeningSummaryCopyWith(WeeklyListeningSummary value, $Res Function(WeeklyListeningSummary) _then) = _$WeeklyListeningSummaryCopyWithImpl;
@useResult
$Res call({
 List<DailyListening> days, int weekListenedMs, int weekSongs, int lastWeekSongs
});




}
/// @nodoc
class _$WeeklyListeningSummaryCopyWithImpl<$Res>
    implements $WeeklyListeningSummaryCopyWith<$Res> {
  _$WeeklyListeningSummaryCopyWithImpl(this._self, this._then);

  final WeeklyListeningSummary _self;
  final $Res Function(WeeklyListeningSummary) _then;

/// Create a copy of WeeklyListeningSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? weekListenedMs = null,Object? weekSongs = null,Object? lastWeekSongs = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<DailyListening>,weekListenedMs: null == weekListenedMs ? _self.weekListenedMs : weekListenedMs // ignore: cast_nullable_to_non_nullable
as int,weekSongs: null == weekSongs ? _self.weekSongs : weekSongs // ignore: cast_nullable_to_non_nullable
as int,lastWeekSongs: null == lastWeekSongs ? _self.lastWeekSongs : lastWeekSongs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyListeningSummary].
extension WeeklyListeningSummaryPatterns on WeeklyListeningSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyListeningSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyListeningSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyListeningSummary value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyListeningSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyListeningSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyListeningSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DailyListening> days,  int weekListenedMs,  int weekSongs,  int lastWeekSongs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyListeningSummary() when $default != null:
return $default(_that.days,_that.weekListenedMs,_that.weekSongs,_that.lastWeekSongs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DailyListening> days,  int weekListenedMs,  int weekSongs,  int lastWeekSongs)  $default,) {final _that = this;
switch (_that) {
case _WeeklyListeningSummary():
return $default(_that.days,_that.weekListenedMs,_that.weekSongs,_that.lastWeekSongs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DailyListening> days,  int weekListenedMs,  int weekSongs,  int lastWeekSongs)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyListeningSummary() when $default != null:
return $default(_that.days,_that.weekListenedMs,_that.weekSongs,_that.lastWeekSongs);case _:
  return null;

}
}

}

/// @nodoc


class _WeeklyListeningSummary extends WeeklyListeningSummary {
  const _WeeklyListeningSummary({final  List<DailyListening> days = const <DailyListening>[], this.weekListenedMs = 0, this.weekSongs = 0, this.lastWeekSongs = 0}): _days = days,super._();
  

 final  List<DailyListening> _days;
@override@JsonKey() List<DailyListening> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey() final  int weekListenedMs;
@override@JsonKey() final  int weekSongs;
@override@JsonKey() final  int lastWeekSongs;

/// Create a copy of WeeklyListeningSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyListeningSummaryCopyWith<_WeeklyListeningSummary> get copyWith => __$WeeklyListeningSummaryCopyWithImpl<_WeeklyListeningSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyListeningSummary&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.weekListenedMs, weekListenedMs) || other.weekListenedMs == weekListenedMs)&&(identical(other.weekSongs, weekSongs) || other.weekSongs == weekSongs)&&(identical(other.lastWeekSongs, lastWeekSongs) || other.lastWeekSongs == lastWeekSongs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),weekListenedMs,weekSongs,lastWeekSongs);

@override
String toString() {
  return 'WeeklyListeningSummary(days: $days, weekListenedMs: $weekListenedMs, weekSongs: $weekSongs, lastWeekSongs: $lastWeekSongs)';
}


}

/// @nodoc
abstract mixin class _$WeeklyListeningSummaryCopyWith<$Res> implements $WeeklyListeningSummaryCopyWith<$Res> {
  factory _$WeeklyListeningSummaryCopyWith(_WeeklyListeningSummary value, $Res Function(_WeeklyListeningSummary) _then) = __$WeeklyListeningSummaryCopyWithImpl;
@override @useResult
$Res call({
 List<DailyListening> days, int weekListenedMs, int weekSongs, int lastWeekSongs
});




}
/// @nodoc
class __$WeeklyListeningSummaryCopyWithImpl<$Res>
    implements _$WeeklyListeningSummaryCopyWith<$Res> {
  __$WeeklyListeningSummaryCopyWithImpl(this._self, this._then);

  final _WeeklyListeningSummary _self;
  final $Res Function(_WeeklyListeningSummary) _then;

/// Create a copy of WeeklyListeningSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? weekListenedMs = null,Object? weekSongs = null,Object? lastWeekSongs = null,}) {
  return _then(_WeeklyListeningSummary(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<DailyListening>,weekListenedMs: null == weekListenedMs ? _self.weekListenedMs : weekListenedMs // ignore: cast_nullable_to_non_nullable
as int,weekSongs: null == weekSongs ? _self.weekSongs : weekSongs // ignore: cast_nullable_to_non_nullable
as int,lastWeekSongs: null == lastWeekSongs ? _self.lastWeekSongs : lastWeekSongs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
