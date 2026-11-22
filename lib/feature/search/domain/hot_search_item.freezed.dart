// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_search_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HotSearchItem {

 String get keyword; String get showName; int get heatScore; bool get isNew;
/// Create a copy of HotSearchItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotSearchItemCopyWith<HotSearchItem> get copyWith => _$HotSearchItemCopyWithImpl<HotSearchItem>(this as HotSearchItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotSearchItem&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.showName, showName) || other.showName == showName)&&(identical(other.heatScore, heatScore) || other.heatScore == heatScore)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,showName,heatScore,isNew);

@override
String toString() {
  return 'HotSearchItem(keyword: $keyword, showName: $showName, heatScore: $heatScore, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class $HotSearchItemCopyWith<$Res>  {
  factory $HotSearchItemCopyWith(HotSearchItem value, $Res Function(HotSearchItem) _then) = _$HotSearchItemCopyWithImpl;
@useResult
$Res call({
 String keyword, String showName, int heatScore, bool isNew
});




}
/// @nodoc
class _$HotSearchItemCopyWithImpl<$Res>
    implements $HotSearchItemCopyWith<$Res> {
  _$HotSearchItemCopyWithImpl(this._self, this._then);

  final HotSearchItem _self;
  final $Res Function(HotSearchItem) _then;

/// Create a copy of HotSearchItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyword = null,Object? showName = null,Object? heatScore = null,Object? isNew = null,}) {
  return _then(_self.copyWith(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,showName: null == showName ? _self.showName : showName // ignore: cast_nullable_to_non_nullable
as String,heatScore: null == heatScore ? _self.heatScore : heatScore // ignore: cast_nullable_to_non_nullable
as int,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HotSearchItem].
extension HotSearchItemPatterns on HotSearchItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotSearchItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotSearchItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotSearchItem value)  $default,){
final _that = this;
switch (_that) {
case _HotSearchItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotSearchItem value)?  $default,){
final _that = this;
switch (_that) {
case _HotSearchItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String keyword,  String showName,  int heatScore,  bool isNew)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotSearchItem() when $default != null:
return $default(_that.keyword,_that.showName,_that.heatScore,_that.isNew);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String keyword,  String showName,  int heatScore,  bool isNew)  $default,) {final _that = this;
switch (_that) {
case _HotSearchItem():
return $default(_that.keyword,_that.showName,_that.heatScore,_that.isNew);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String keyword,  String showName,  int heatScore,  bool isNew)?  $default,) {final _that = this;
switch (_that) {
case _HotSearchItem() when $default != null:
return $default(_that.keyword,_that.showName,_that.heatScore,_that.isNew);case _:
  return null;

}
}

}

/// @nodoc


class _HotSearchItem extends HotSearchItem {
  const _HotSearchItem({required this.keyword, this.showName = '', this.heatScore = 0, this.isNew = false}): super._();
  

@override final  String keyword;
@override@JsonKey() final  String showName;
@override@JsonKey() final  int heatScore;
@override@JsonKey() final  bool isNew;

/// Create a copy of HotSearchItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotSearchItemCopyWith<_HotSearchItem> get copyWith => __$HotSearchItemCopyWithImpl<_HotSearchItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotSearchItem&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.showName, showName) || other.showName == showName)&&(identical(other.heatScore, heatScore) || other.heatScore == heatScore)&&(identical(other.isNew, isNew) || other.isNew == isNew));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,showName,heatScore,isNew);

@override
String toString() {
  return 'HotSearchItem(keyword: $keyword, showName: $showName, heatScore: $heatScore, isNew: $isNew)';
}


}

/// @nodoc
abstract mixin class _$HotSearchItemCopyWith<$Res> implements $HotSearchItemCopyWith<$Res> {
  factory _$HotSearchItemCopyWith(_HotSearchItem value, $Res Function(_HotSearchItem) _then) = __$HotSearchItemCopyWithImpl;
@override @useResult
$Res call({
 String keyword, String showName, int heatScore, bool isNew
});




}
/// @nodoc
class __$HotSearchItemCopyWithImpl<$Res>
    implements _$HotSearchItemCopyWith<$Res> {
  __$HotSearchItemCopyWithImpl(this._self, this._then);

  final _HotSearchItem _self;
  final $Res Function(_HotSearchItem) _then;

/// Create a copy of HotSearchItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyword = null,Object? showName = null,Object? heatScore = null,Object? isNew = null,}) {
  return _then(_HotSearchItem(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,showName: null == showName ? _self.showName : showName // ignore: cast_nullable_to_non_nullable
as String,heatScore: null == heatScore ? _self.heatScore : heatScore // ignore: cast_nullable_to_non_nullable
as int,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
