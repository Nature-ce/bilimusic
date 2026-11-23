import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/radar/domain/radar_keys.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'radar_pick.freezed.dart';

enum RadarReason {
  /// 常听歌手的歌。
  familiarArtist,

  /// 和你常听的歌手出现在同一个歌单里。
  relatedPlaylist,

  /// 换个口味：刻意挑一些没听过的。
  explorer,

  /// 冷启动：还没有收听数据时，从各平台热门里按排名分档混着挑。
  coldStart,
}

@freezed
abstract class RadarPick with _$RadarPick {
  const RadarPick._();

  const factory RadarPick({
    required HotPlaylistTrack track,
    required RadarReason reason,
    @Default(0) double score,
    String? reasonDetail,
  }) = _RadarPick;

  String get key => track.key;

  String get artistKey => normalizeRadarKey(track.artist);

  String get reasonLabel {
    switch (reason) {
      case RadarReason.familiarArtist:
        final String detail = (reasonDetail ?? '').trim();
        return detail.isEmpty ? '因为你常听这个歌手' : '因为你常听 $detail';
      case RadarReason.relatedPlaylist:
        final String detail = (reasonDetail ?? '').trim();
        return detail.isEmpty ? '和你的口味在同一个歌单' : '和「$detail」同一个歌单';
      case RadarReason.explorer:
        return '换个口味，多听点新的';
      case RadarReason.coldStart:
        return '还没听够，先从各平台热门里挑';
    }
  }
}
