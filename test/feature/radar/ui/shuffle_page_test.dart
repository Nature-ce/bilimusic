import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/matchable_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:bilimusic/feature/radar/ui/shuffle_page.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const HotPlaylist _playlist = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: '1',
  name: '网易歌单',
  coverUrl: '',
);

List<HotPlaylistTrack> _tracks() {
  return <HotPlaylistTrack>[
    const HotPlaylistTrack(
      playlist: _playlist,
      rank: 1,
      title: '刷歌歌曲一',
      artist: '歌手甲',
      coverUrl: '',
      durationSeconds: 245,
    ),
    const HotPlaylistTrack(
      playlist: _playlist,
      rank: 2,
      title: '刷歌歌曲二',
      artist: '歌手乙',
      coverUrl: '',
    ),
  ];
}

class _LoadedFeed extends MusicRadarController {
  int scanCalls = 0;

  @override
  MusicRadarState build() =>
      MusicRadarState(tracks: _tracks(), scanCount: 1, isScanning: false);

  @override
  Future<void> scan() async {
    scanCalls += 1;
  }
}

class _EmptyFeed extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState();
}

class _FakeSearchRepository implements BiliSearchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakePlayerRepository implements BiliPlayerRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _ResolvedResolver extends MusicChartResolver {
  _ResolvedResolver({this.fail = false})
    : super(
        searchRepository: _FakeSearchRepository(),
        playerRepository: _FakePlayerRepository(),
      );

  final bool fail;

  @override
  Future<PlayableItem?> resolve(MatchableTrack track) async {
    if (fail) {
      return null;
    }
    return PlayableItem(
      aid: track.title.hashCode.abs(),
      bvid: 'BV${track.title.hashCode.abs()}',
      cid: 1,
      title: track.title,
      author: track.artist,
      coverUrl: '',
    );
  }
}

class _FakePlayer extends PlayerController {
  final List<String?> queuedLabels = <String?>[];
  final List<List<PlayableItem>> queued = <List<PlayableItem>>[];
  int skipNextCalls = 0;
  int skipPreviousCalls = 0;
  List<PlayableItem> enqueued = <PlayableItem>[];

  @override
  PlayerState build() => const PlayerState();

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
    Duration initialPosition = Duration.zero,
  }) async {
    queued.add(items);
    queuedLabels.add(sourceLabel);
  }

  @override
  Future<void> skipToNext() async {
    skipNextCalls += 1;
  }

  @override
  Future<void> skipToPrevious() async {
    skipPreviousCalls += 1;
  }

  @override
  Future<void> enqueue(List<PlayableItem> items) async {
    enqueued = items;
  }
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester, {
  required MusicRadarController Function() controller,
  MusicChartResolver? resolver,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final ProviderContainer container = ProviderContainer(
    overrides: [
      musicRadarControllerProvider.overrideWith(controller),
      musicChartResolverProvider.overrideWith(
        (Ref ref) => resolver ?? _ResolvedResolver(),
      ),
      playerControllerProvider.overrideWith(_FakePlayer.new),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ShufflePage()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('进入刷歌会把推荐曲目装进播放队列', (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
    );

    final _FakePlayer player =
        container.read(playerControllerProvider.notifier) as _FakePlayer;
    expect(player.queued, hasLength(1));
    expect(player.queuedLabels.single, '刷歌');
    expect(player.queued.single, hasLength(2));
    expect(
      player.queued.single.map((PlayableItem item) => item.title),
      <String>['刷歌歌曲一', '刷歌歌曲二'],
    );
  });

  testWidgets('队列建好后展示完整播放页', (WidgetTester tester) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
    );
    // 队列装好但当前没有播放项时，仍然是刷歌的待命态。
    expect(find.text('正在为你挑歌'), findsNothing);
    expect(container.read(playerControllerProvider).currentItem, isNull);
    expect(find.text('暂无歌曲'), findsOneWidget);
  });

  testWidgets('每首都匹配不到时给出可重试的错误态', (WidgetTester tester) async {
    await _pumpPage(
      tester,
      controller: _LoadedFeed.new,
      resolver: _ResolvedResolver(fail: true),
    );

    expect(find.text('刷歌暂时没有发现'), findsOneWidget);
    expect(find.text('推荐歌曲都还没匹配到 B 站视频，换个批次再试'), findsOneWidget);
    expect(find.text('重新取样'), findsOneWidget);
  });

  testWidgets('推荐为空时也能给出提示与重试', (WidgetTester tester) async {
    await _pumpPage(tester, controller: _EmptyFeed.new);

    expect(find.text('刷歌暂时没有发现'), findsOneWidget);
    expect(find.text('重新取样'), findsOneWidget);
    expect(find.byType(MusicRadarVisual), findsNothing);
  });
}
