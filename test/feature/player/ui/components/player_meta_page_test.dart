import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/logic/radar_pick_reasons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 112,
  bvid: 'BV1tn9aBqER7',
  title: '【Hi-Res无损音质】|《我不难过》- 孙燕姿',
  author: 'VV音乐局',
  coverUrl: '',
  page: 1,
);

void main() {
  testWidgets('刷歌推过来的歌在播放信息页显示推荐理由', (WidgetTester tester) async {
    await _pump(tester, _pick(reason: RadarReason.explorer));

    expect(find.text('私人雷达'), findsOneWidget);
    expect(find.text('换个口味，多听点新的'), findsOneWidget);
  });

  testWidgets('常听歌手的推荐理由会带上歌手名', (WidgetTester tester) async {
    await _pump(
      tester,
      _pick(reason: RadarReason.familiarArtist, detail: '孙燕姿'),
    );

    expect(find.text('因为你常听 孙燕姿'), findsOneWidget);
  });

  testWidgets('不是雷达推的歌不显示推荐理由', (WidgetTester tester) async {
    await _pump(tester, null);

    expect(find.text('私人雷达'), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, RadarPick? pick) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerCoverColorControllerProvider.overrideWith(_FakeCoverColor.new),
        radarPickReasonsProvider.overrideWith(
          () => _FakeReasons(
            pick == null
                ? const <String, RadarPick>{}
                : <String, RadarPick>{radarReasonKey(_item): pick},
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: PlayerMetaPage(
            state: PlayerState(currentItem: _item, isPlaying: true),
            item: _item,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

RadarPick _pick({required RadarReason reason, String? detail}) {
  return RadarPick(
    track: const HotPlaylistTrack(
      playlist: HotPlaylist(
        platform: MusicChartPlatform.netease,
        id: 'p1',
        name: '热歌榜',
        coverUrl: '',
      ),
      rank: 4,
      title: '我不难过',
      artist: '孙燕姿',
      coverUrl: '',
    ),
    reason: reason,
    reasonDetail: detail,
  );
}

class _FakeCoverColor extends PlayerCoverColorController {
  @override
  Color? build() => null;
}

class _FakeReasons extends RadarPickReasons {
  _FakeReasons(this._initial);

  final Map<String, RadarPick> _initial;

  @override
  Map<String, RadarPick> build() => _initial;
}
