// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listening_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListeningReportSong {

 String get stableId; String get title; String get author; String get coverUrl; int get listenedMs; int get plays;
/// Create a copy of ListeningReportSong
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListeningReportSongCopyWith<ListeningReportSong> get copyWith => _$ListeningReportSongCopyWithImpl<ListeningReportSong>(this as ListeningReportSong, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListeningReportSong&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.listenedMs, listenedMs) || other.listenedMs == listenedMs)&&(identical(other.plays, plays) || other.plays == plays));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,author,coverUrl,listenedMs,plays);

@override
String toString() {
  return 'ListeningReportSong(stableId: $stableId, title: $title, author: $author, coverUrl: $coverUrl, listenedMs: $listenedMs, plays: $plays)';
}


}

/// @nodoc
abstract mixin class $ListeningReportSongCopyWith<$Res>  {
  factory $ListeningReportSongCopyWith(ListeningReportSong value, $Res Function(ListeningReportSong) _then) = _$ListeningReportSongCopyWithImpl;
@useResult
$Res call({
 String stableId, String title, String author, String coverUrl, int listenedMs, int plays
});




}
/// @nodoc
class _$ListeningReportSongCopyWithImpl<$Res>
    implements $ListeningReportSongCopyWith<$Res> {
  _$ListeningReportSongCopyWithImpl(this._self, this._then);

  final ListeningReportSong _self;
  final $Res Function(ListeningReportSong) _then;

/// Create a copy of ListeningReportSong
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? listenedMs = null,Object? plays = null,}) {
  return _then(_self.copyWith(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,listenedMs: null == listenedMs ? _self.listenedMs : listenedMs // ignore: cast_nullable_to_non_nullable
as int,plays: null == plays ? _self.plays : plays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ListeningReportSong].
extension ListeningReportSongPatterns on ListeningReportSong {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListeningReportSong value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListeningReportSong() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListeningReportSong value)  $default,){
final _that = this;
switch (_that) {
case _ListeningReportSong():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListeningReportSong value)?  $default,){
final _that = this;
switch (_that) {
case _ListeningReportSong() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stableId,  String title,  String author,  String coverUrl,  int listenedMs,  int plays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListeningReportSong() when $default != null:
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.listenedMs,_that.plays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stableId,  String title,  String author,  String coverUrl,  int listenedMs,  int plays)  $default,) {final _that = this;
switch (_that) {
case _ListeningReportSong():
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.listenedMs,_that.plays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stableId,  String title,  String author,  String coverUrl,  int listenedMs,  int plays)?  $default,) {final _that = this;
switch (_that) {
case _ListeningReportSong() when $default != null:
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.listenedMs,_that.plays);case _:
  return null;

}
}

}

/// @nodoc


class _ListeningReportSong implements ListeningReportSong {
  const _ListeningReportSong({required this.stableId, this.title = '', this.author = '', this.coverUrl = '', this.listenedMs = 0, this.plays = 0});
  

@override final  String stableId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  int listenedMs;
@override@JsonKey() final  int plays;

/// Create a copy of ListeningReportSong
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListeningReportSongCopyWith<_ListeningReportSong> get copyWith => __$ListeningReportSongCopyWithImpl<_ListeningReportSong>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListeningReportSong&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.listenedMs, listenedMs) || other.listenedMs == listenedMs)&&(identical(other.plays, plays) || other.plays == plays));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,author,coverUrl,listenedMs,plays);

@override
String toString() {
  return 'ListeningReportSong(stableId: $stableId, title: $title, author: $author, coverUrl: $coverUrl, listenedMs: $listenedMs, plays: $plays)';
}


}

/// @nodoc
abstract mixin class _$ListeningReportSongCopyWith<$Res> implements $ListeningReportSongCopyWith<$Res> {
  factory _$ListeningReportSongCopyWith(_ListeningReportSong value, $Res Function(_ListeningReportSong) _then) = __$ListeningReportSongCopyWithImpl;
@override @useResult
$Res call({
 String stableId, String title, String author, String coverUrl, int listenedMs, int plays
});




}
/// @nodoc
class __$ListeningReportSongCopyWithImpl<$Res>
    implements _$ListeningReportSongCopyWith<$Res> {
  __$ListeningReportSongCopyWithImpl(this._self, this._then);

  final _ListeningReportSong _self;
  final $Res Function(_ListeningReportSong) _then;

/// Create a copy of ListeningReportSong
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? listenedMs = null,Object? plays = null,}) {
  return _then(_ListeningReportSong(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,listenedMs: null == listenedMs ? _self.listenedMs : listenedMs // ignore: cast_nullable_to_non_nullable
as int,plays: null == plays ? _self.plays : plays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ListeningReport {

 List<DailyListening> get days; List<DailyListening> get lastWeekDays; List<ListeningReportSong> get topSongs; int get weekListenedMs; int get lastWeekListenedMs; int get weekSongs; int get lastWeekSongs; int get newSongCount; int get streakDays; int get elapsedDays; bool get topSongsAreCumulative; DateTime? get weekStart;
/// Create a copy of ListeningReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListeningReportCopyWith<ListeningReport> get copyWith => _$ListeningReportCopyWithImpl<ListeningReport>(this as ListeningReport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListeningReport&&const DeepCollectionEquality().equals(other.days, days)&&const DeepCollectionEquality().equals(other.lastWeekDays, lastWeekDays)&&const DeepCollectionEquality().equals(other.topSongs, topSongs)&&(identical(other.weekListenedMs, weekListenedMs) || other.weekListenedMs == weekListenedMs)&&(identical(other.lastWeekListenedMs, lastWeekListenedMs) || other.lastWeekListenedMs == lastWeekListenedMs)&&(identical(other.weekSongs, weekSongs) || other.weekSongs == weekSongs)&&(identical(other.lastWeekSongs, lastWeekSongs) || other.lastWeekSongs == lastWeekSongs)&&(identical(other.newSongCount, newSongCount) || other.newSongCount == newSongCount)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.elapsedDays, elapsedDays) || other.elapsedDays == elapsedDays)&&(identical(other.topSongsAreCumulative, topSongsAreCumulative) || other.topSongsAreCumulative == topSongsAreCumulative)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),const DeepCollectionEquality().hash(lastWeekDays),const DeepCollectionEquality().hash(topSongs),weekListenedMs,lastWeekListenedMs,weekSongs,lastWeekSongs,newSongCount,streakDays,elapsedDays,topSongsAreCumulative,weekStart);

@override
String toString() {
  return 'ListeningReport(days: $days, lastWeekDays: $lastWeekDays, topSongs: $topSongs, weekListenedMs: $weekListenedMs, lastWeekListenedMs: $lastWeekListenedMs, weekSongs: $weekSongs, lastWeekSongs: $lastWeekSongs, newSongCount: $newSongCount, streakDays: $streakDays, elapsedDays: $elapsedDays, topSongsAreCumulative: $topSongsAreCumulative, weekStart: $weekStart)';
}


}

/// @nodoc
abstract mixin class $ListeningReportCopyWith<$Res>  {
  factory $ListeningReportCopyWith(ListeningReport value, $Res Function(ListeningReport) _then) = _$ListeningReportCopyWithImpl;
@useResult
$Res call({
 List<DailyListening> days, List<DailyListening> lastWeekDays, List<ListeningReportSong> topSongs, int weekListenedMs, int lastWeekListenedMs, int weekSongs, int lastWeekSongs, int newSongCount, int streakDays, int elapsedDays, bool topSongsAreCumulative, DateTime? weekStart
});




}
/// @nodoc
class _$ListeningReportCopyWithImpl<$Res>
    implements $ListeningReportCopyWith<$Res> {
  _$ListeningReportCopyWithImpl(this._self, this._then);

  final ListeningReport _self;
  final $Res Function(ListeningReport) _then;

/// Create a copy of ListeningReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? lastWeekDays = null,Object? topSongs = null,Object? weekListenedMs = null,Object? lastWeekListenedMs = null,Object? weekSongs = null,Object? lastWeekSongs = null,Object? newSongCount = null,Object? streakDays = null,Object? elapsedDays = null,Object? topSongsAreCumulative = null,Object? weekStart = freezed,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<DailyListening>,lastWeekDays: null == lastWeekDays ? _self.lastWeekDays : lastWeekDays // ignore: cast_nullable_to_non_nullable
as List<DailyListening>,topSongs: null == topSongs ? _self.topSongs : topSongs // ignore: cast_nullable_to_non_nullable
as List<ListeningReportSong>,weekListenedMs: null == weekListenedMs ? _self.weekListenedMs : weekListenedMs // ignore: cast_nullable_to_non_nullable
as int,lastWeekListenedMs: null == lastWeekListenedMs ? _self.lastWeekListenedMs : lastWeekListenedMs // ignore: cast_nullable_to_non_nullable
as int,weekSongs: null == weekSongs ? _self.weekSongs : weekSongs // ignore: cast_nullable_to_non_nullable
as int,lastWeekSongs: null == lastWeekSongs ? _self.lastWeekSongs : lastWeekSongs // ignore: cast_nullable_to_non_nullable
as int,newSongCount: null == newSongCount ? _self.newSongCount : newSongCount // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,elapsedDays: null == elapsedDays ? _self.elapsedDays : elapsedDays // ignore: cast_nullable_to_non_nullable
as int,topSongsAreCumulative: null == topSongsAreCumulative ? _self.topSongsAreCumulative : topSongsAreCumulative // ignore: cast_nullable_to_non_nullable
as bool,weekStart: freezed == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListeningReport].
extension ListeningReportPatterns on ListeningReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListeningReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListeningReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListeningReport value)  $default,){
final _that = this;
switch (_that) {
case _ListeningReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListeningReport value)?  $default,){
final _that = this;
switch (_that) {
case _ListeningReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DailyListening> days,  List<DailyListening> lastWeekDays,  List<ListeningReportSong> topSongs,  int weekListenedMs,  int lastWeekListenedMs,  int weekSongs,  int lastWeekSongs,  int newSongCount,  int streakDays,  int elapsedDays,  bool topSongsAreCumulative,  DateTime? weekStart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListeningReport() when $default != null:
return $default(_that.days,_that.lastWeekDays,_that.topSongs,_that.weekListenedMs,_that.lastWeekListenedMs,_that.weekSongs,_that.lastWeekSongs,_that.newSongCount,_that.streakDays,_that.elapsedDays,_that.topSongsAreCumulative,_that.weekStart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DailyListening> days,  List<DailyListening> lastWeekDays,  List<ListeningReportSong> topSongs,  int weekListenedMs,  int lastWeekListenedMs,  int weekSongs,  int lastWeekSongs,  int newSongCount,  int streakDays,  int elapsedDays,  bool topSongsAreCumulative,  DateTime? weekStart)  $default,) {final _that = this;
switch (_that) {
case _ListeningReport():
return $default(_that.days,_that.lastWeekDays,_that.topSongs,_that.weekListenedMs,_that.lastWeekListenedMs,_that.weekSongs,_that.lastWeekSongs,_that.newSongCount,_that.streakDays,_that.elapsedDays,_that.topSongsAreCumulative,_that.weekStart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DailyListening> days,  List<DailyListening> lastWeekDays,  List<ListeningReportSong> topSongs,  int weekListenedMs,  int lastWeekListenedMs,  int weekSongs,  int lastWeekSongs,  int newSongCount,  int streakDays,  int elapsedDays,  bool topSongsAreCumulative,  DateTime? weekStart)?  $default,) {final _that = this;
switch (_that) {
case _ListeningReport() when $default != null:
return $default(_that.days,_that.lastWeekDays,_that.topSongs,_that.weekListenedMs,_that.lastWeekListenedMs,_that.weekSongs,_that.lastWeekSongs,_that.newSongCount,_that.streakDays,_that.elapsedDays,_that.topSongsAreCumulative,_that.weekStart);case _:
  return null;

}
}

}

/// @nodoc


class _ListeningReport extends ListeningReport {
  const _ListeningReport({final  List<DailyListening> days = const <DailyListening>[], final  List<DailyListening> lastWeekDays = const <DailyListening>[], final  List<ListeningReportSong> topSongs = const <ListeningReportSong>[], this.weekListenedMs = 0, this.lastWeekListenedMs = 0, this.weekSongs = 0, this.lastWeekSongs = 0, this.newSongCount = 0, this.streakDays = 0, this.elapsedDays = 0, this.topSongsAreCumulative = false, this.weekStart}): _days = days,_lastWeekDays = lastWeekDays,_topSongs = topSongs,super._();
  

 final  List<DailyListening> _days;
@override@JsonKey() List<DailyListening> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

 final  List<DailyListening> _lastWeekDays;
@override@JsonKey() List<DailyListening> get lastWeekDays {
  if (_lastWeekDays is EqualUnmodifiableListView) return _lastWeekDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lastWeekDays);
}

 final  List<ListeningReportSong> _topSongs;
@override@JsonKey() List<ListeningReportSong> get topSongs {
  if (_topSongs is EqualUnmodifiableListView) return _topSongs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topSongs);
}

@override@JsonKey() final  int weekListenedMs;
@override@JsonKey() final  int lastWeekListenedMs;
@override@JsonKey() final  int weekSongs;
@override@JsonKey() final  int lastWeekSongs;
@override@JsonKey() final  int newSongCount;
@override@JsonKey() final  int streakDays;
@override@JsonKey() final  int elapsedDays;
@override@JsonKey() final  bool topSongsAreCumulative;
@override final  DateTime? weekStart;

/// Create a copy of ListeningReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListeningReportCopyWith<_ListeningReport> get copyWith => __$ListeningReportCopyWithImpl<_ListeningReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListeningReport&&const DeepCollectionEquality().equals(other._days, _days)&&const DeepCollectionEquality().equals(other._lastWeekDays, _lastWeekDays)&&const DeepCollectionEquality().equals(other._topSongs, _topSongs)&&(identical(other.weekListenedMs, weekListenedMs) || other.weekListenedMs == weekListenedMs)&&(identical(other.lastWeekListenedMs, lastWeekListenedMs) || other.lastWeekListenedMs == lastWeekListenedMs)&&(identical(other.weekSongs, weekSongs) || other.weekSongs == weekSongs)&&(identical(other.lastWeekSongs, lastWeekSongs) || other.lastWeekSongs == lastWeekSongs)&&(identical(other.newSongCount, newSongCount) || other.newSongCount == newSongCount)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.elapsedDays, elapsedDays) || other.elapsedDays == elapsedDays)&&(identical(other.topSongsAreCumulative, topSongsAreCumulative) || other.topSongsAreCumulative == topSongsAreCumulative)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),const DeepCollectionEquality().hash(_lastWeekDays),const DeepCollectionEquality().hash(_topSongs),weekListenedMs,lastWeekListenedMs,weekSongs,lastWeekSongs,newSongCount,streakDays,elapsedDays,topSongsAreCumulative,weekStart);

@override
String toString() {
  return 'ListeningReport(days: $days, lastWeekDays: $lastWeekDays, topSongs: $topSongs, weekListenedMs: $weekListenedMs, lastWeekListenedMs: $lastWeekListenedMs, weekSongs: $weekSongs, lastWeekSongs: $lastWeekSongs, newSongCount: $newSongCount, streakDays: $streakDays, elapsedDays: $elapsedDays, topSongsAreCumulative: $topSongsAreCumulative, weekStart: $weekStart)';
}


}

/// @nodoc
abstract mixin class _$ListeningReportCopyWith<$Res> implements $ListeningReportCopyWith<$Res> {
  factory _$ListeningReportCopyWith(_ListeningReport value, $Res Function(_ListeningReport) _then) = __$ListeningReportCopyWithImpl;
@override @useResult
$Res call({
 List<DailyListening> days, List<DailyListening> lastWeekDays, List<ListeningReportSong> topSongs, int weekListenedMs, int lastWeekListenedMs, int weekSongs, int lastWeekSongs, int newSongCount, int streakDays, int elapsedDays, bool topSongsAreCumulative, DateTime? weekStart
});




}
/// @nodoc
class __$ListeningReportCopyWithImpl<$Res>
    implements _$ListeningReportCopyWith<$Res> {
  __$ListeningReportCopyWithImpl(this._self, this._then);

  final _ListeningReport _self;
  final $Res Function(_ListeningReport) _then;

/// Create a copy of ListeningReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? lastWeekDays = null,Object? topSongs = null,Object? weekListenedMs = null,Object? lastWeekListenedMs = null,Object? weekSongs = null,Object? lastWeekSongs = null,Object? newSongCount = null,Object? streakDays = null,Object? elapsedDays = null,Object? topSongsAreCumulative = null,Object? weekStart = freezed,}) {
  return _then(_ListeningReport(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<DailyListening>,lastWeekDays: null == lastWeekDays ? _self._lastWeekDays : lastWeekDays // ignore: cast_nullable_to_non_nullable
as List<DailyListening>,topSongs: null == topSongs ? _self._topSongs : topSongs // ignore: cast_nullable_to_non_nullable
as List<ListeningReportSong>,weekListenedMs: null == weekListenedMs ? _self.weekListenedMs : weekListenedMs // ignore: cast_nullable_to_non_nullable
as int,lastWeekListenedMs: null == lastWeekListenedMs ? _self.lastWeekListenedMs : lastWeekListenedMs // ignore: cast_nullable_to_non_nullable
as int,weekSongs: null == weekSongs ? _self.weekSongs : weekSongs // ignore: cast_nullable_to_non_nullable
as int,lastWeekSongs: null == lastWeekSongs ? _self.lastWeekSongs : lastWeekSongs // ignore: cast_nullable_to_non_nullable
as int,newSongCount: null == newSongCount ? _self.newSongCount : newSongCount // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,elapsedDays: null == elapsedDays ? _self.elapsedDays : elapsedDays // ignore: cast_nullable_to_non_nullable
as int,topSongsAreCumulative: null == topSongsAreCumulative ? _self.topSongsAreCumulative : topSongsAreCumulative // ignore: cast_nullable_to_non_nullable
as bool,weekStart: freezed == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
