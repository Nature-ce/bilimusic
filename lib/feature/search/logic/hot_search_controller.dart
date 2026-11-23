import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/search/domain/hot_search_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hot_search_controller.g.dart';

const List<MusicChartPlatform> _hotSearchPlatforms = <MusicChartPlatform>[
  MusicChartPlatform.netease,
  MusicChartPlatform.tencent,
  MusicChartPlatform.kugou,
];

const int _perPlatformLimit = 4;
const int _maxHotSearchItems = 10;

@Riverpod(keepAlive: true)
List<HotSearchItem> hotSearch(Ref ref) {
  final MusicChartState chartState = ref.watch(musicChartControllerProvider);
  final List<List<MusicChartTrack>> platformTracks = <List<MusicChartTrack>>[
    for (final MusicChartPlatform platform in _hotSearchPlatforms)
      (chartState.entryOf(platform)?.tracks ?? const <MusicChartTrack>[])
          .take(_perPlatformLimit)
          .toList(),
  ];

  final Set<String> seen = <String>{};
  final List<HotSearchItem> items = <HotSearchItem>[];
  for (int trackIndex = 0; trackIndex < _perPlatformLimit; trackIndex++) {
    for (final List<MusicChartTrack> tracks in platformTracks) {
      if (trackIndex >= tracks.length) {
        continue;
      }
      final MusicChartTrack track = tracks[trackIndex];
      final String title = track.title.trim();
      if (title.isEmpty || !seen.add(_hotSearchKey(track))) {
        continue;
      }
      items.add(HotSearchItem(keyword: title, showName: track.artist.trim()));
      if (items.length >= _maxHotSearchItems) {
        return items;
      }
    }
  }
  return items;
}

String _hotSearchKey(MusicChartTrack track) {
  return '${track.title.trim()}|${track.artist.trim()}'.toLowerCase();
}
