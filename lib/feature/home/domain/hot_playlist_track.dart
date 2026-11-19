import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hot_playlist_track.freezed.dart';

@freezed
abstract class HotPlaylistTrack
    with _$HotPlaylistTrack
    implements MatchableTrack {
  const factory HotPlaylistTrack({
    required HotPlaylist playlist,
    required int rank,
    required String title,
    required String artist,
    required String coverUrl,
    @Default(0) int durationSeconds,
  }) = _HotPlaylistTrack;

  const HotPlaylistTrack._();

  @override
  PlayableItem? get directItem => null;

  String get key => '${playlist.key}:$rank:$title:$artist';

  @override
  String get searchKeyword => '$title $artist'.trim();

  String get durationText {
    if (durationSeconds <= 0) {
      return '--:--';
    }
    final int minutes = durationSeconds ~/ 60;
    final int seconds = durationSeconds % 60;
    if (minutes >= 60) {
      final int hours = minutes ~/ 60;
      return '${hours.toString().padLeft(2, '0')}:'
          '${(minutes % 60).toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
