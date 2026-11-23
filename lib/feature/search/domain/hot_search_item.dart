import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_search_item.freezed.dart';

@freezed
abstract class HotSearchItem with _$HotSearchItem {
  const HotSearchItem._();

  const factory HotSearchItem({
    required String keyword,
    @Default('') String showName,
  }) = _HotSearchItem;

  bool get hasDistinctShowName => showName.isNotEmpty && showName != keyword;
}
