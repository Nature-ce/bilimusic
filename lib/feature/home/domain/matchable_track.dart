import 'package:bilimusic/feature/player/domain/playable_item.dart';

/// 可被「搜索 B 站并播放」链路消费的曲目：热榜与歌单共用。
abstract interface class MatchableTrack {
  String get title;

  String get artist;

  int get durationSeconds;

  /// B 站条目本身（如 B 站榜单里的视频）可直接播放，无需再搜索。
  PlayableItem? get directItem;

  String get searchKeyword;
}
