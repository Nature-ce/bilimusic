import 'dart:math';

import 'package:bilimusic/feature/daily/data/daily_recommendation_store.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/radar/data/radar_pool_loader.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/domain/radar_taste.dart';
import 'package:bilimusic/feature/radar/logic/radar_recommender.dart';
import 'package:bilimusic/feature/radar/logic/radar_taste_provider.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:bilimusic/feature/search/domain/search_page_result.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime _today = DateTime(2026, 11, 24, 9, 30);

const HotPlaylist _playlistA = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: 'daily-a',
  name: '每日歌单 A',
  coverUrl: '',
);

const HotPlaylist _playlistB = HotPlaylist(
  platform: MusicChartPlatform.tencent,
  id: 'daily-b',
  name: '每日歌单 B',
  coverUrl: '',
);

const HotPlaylist _playlistC = HotPlaylist(
  platform: MusicChartPlatform.kugou,
  id: 'daily-c',
  name: '每日歌单 C',
  coverUrl: '',
);

List<HotPlaylistTrack> _wave({int start = 0, int count = 45}) {
  const List<HotPlaylist> playlists = <HotPlaylist>[
    _playlistA,
    _playlistB,
    _playlistC,
  ];
  return <HotPlaylistTrack>[
    for (int index = 0; index < count; index += 1)
      HotPlaylistTrack(
        playlist: playlists[index % playlists.length],
        rank: index + 1,
        title: '每日歌曲 ${start + index}',
        artist: '歌手${start + index}',
        coverUrl: 'https://example.com/${start + index}.jpg',
        durationSeconds: 180 + index,
      ),
  ];
}

RadarTaste _personalizedTaste() {
  return const RadarTaste(
    artists: <String, double>{'歌手0': 3, '歌手1': 2.5, '歌手2': 2},
    sampleCount: 6,
  );
}

DailyPick _dailyPick(int index) {
  return DailyPick(
    title: '旧推荐 $index',
    artist: '旧歌手 $index',
    reason: RadarReason.explorer,
    durationSeconds: 200,
  );
}

class _FakeSearchRepository implements BiliSearchRepository {
  _FakeSearchRepository({this.items = const <SearchResultItem>[]});

  final List<SearchResultItem> items;

  @override
  Future<SearchPageResult> searchVideos(
    String keyword, {
    int page = 1,
    SearchSort sort = SearchSort.comprehensive,
  }) async {
    return SearchPageResult(items: items);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProviderContainer _container({
  required _FakeDailyStore store,
  required _FakePoolLoader loader,
  required _CountingRecommender recommender,
  DateTime Function()? now,
  RadarTaste taste = const RadarTaste(),
  BiliSearchRepository? searchRepository,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      dailyRecommendationStoreProvider.overrideWithValue(store),
      radarPoolLoaderProvider.overrideWithValue(loader),
      dailyRecommendationRecommenderProvider.overrideWithValue(recommender),
      dailyRecommendationRandomProvider.overrideWithValue(Random(7)),
      radarTasteProvider.overrideWith((Ref ref) async => taste),
      dailyNowProvider.overrideWith((Ref ref) => now ?? () => _today),
      biliSearchRepositoryProvider.overrideWith(
        (Ref ref) => searchRepository ?? _FakeSearchRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  final ProviderSubscription<DailyRecommendationState> subscription = container
      .listen(
        dailyRecommendationControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
  addTearDown(subscription.close);
  return container;
}

Future<DailyRecommendationState> _settle(ProviderContainer container) async {
  for (int attempt = 0; attempt < 400; attempt += 1) {
    final DailyRecommendationState state = container.read(
      dailyRecommendationControllerProvider,
    );
    if (!state.isLoading) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  return container.read(dailyRecommendationControllerProvider);
}

void main() {
  test('当天已有数据就直接用本地那份，不再生成', () async {
    final _FakeDailyStore store = _FakeDailyStore(
      stored: DailyRecommendation(
        dateKey: '2026-11-24',
        generatedAtEpochMs: 111,
        picks: <DailyPick>[
          for (int index = 0; index < 5; index += 1) _dailyPick(index),
        ],
      ),
    );
    final _FakePoolLoader loader = _FakePoolLoader(
      waves: <List<HotPlaylistTrack>>[_wave()],
    );
    final _CountingRecommender recommender = _CountingRecommender();
    final ProviderContainer container = _container(
      store: store,
      loader: loader,
      recommender: recommender,
      taste: _personalizedTaste(),
    );

    final DailyRecommendationState state = await _settle(container);

    expect(state.picks, hasLength(5));
    expect(state.picks.first.title, '旧推荐 0');
    expect(state.dateKey, '2026-11-24');
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
    expect(loader.loadCalls, 0);
    expect(recommender.calls, 0);
    expect(store.saveCalls, 0);
  });

  test('跨天后会重新生成并覆盖本地那份', () async {
    final _FakeDailyStore store = _FakeDailyStore(
      stored: DailyRecommendation(
        dateKey: '2026-11-23',
        picks: <DailyPick>[_dailyPick(0)],
      ),
    );
    final _FakePoolLoader loader = _FakePoolLoader(
      waves: <List<HotPlaylistTrack>>[_wave()],
    );
    final _CountingRecommender recommender = _CountingRecommender();
    final ProviderContainer container = _container(
      store: store,
      loader: loader,
      recommender: recommender,
      taste: _personalizedTaste(),
    );

    final DailyRecommendationState state = await _settle(container);

    expect(state.dateKey, '2026-11-24');
    expect(state.picks, hasLength(30));
    expect(state.isPersonalized, isTrue);
    expect(state.hasError, isFalse);
    expect(loader.loadCalls, 1);
    expect(recommender.calls, 1);
    expect(store.saveCalls, 1);
    expect(store.load()!.dateKey, '2026-11-24');
    expect(store.load()!.picks, hasLength(30));
    expect(store.load()!.generatedAtEpochMs, _today.millisecondsSinceEpoch);
    final Set<String> keys = state.picks
        .map((DailyPick pick) => pick.key)
        .toSet();
    expect(keys.length, state.picks.length);
    expect(state.picks.first.reason, isNot(RadarReason.coldStart));
  });

  test('候选池不足 30 首时会再取一波补足', () async {
    final _FakeDailyStore store = _FakeDailyStore();
    final _FakePoolLoader loader = _FakePoolLoader(
      waves: <List<HotPlaylistTrack>>[
        _wave(count: 8),
        _wave(start: 100, count: 45),
      ],
    );
    final ProviderContainer container = _container(
      store: store,
      loader: loader,
      recommender: _CountingRecommender(),
      taste: _personalizedTaste(),
    );

    final DailyRecommendationState state = await _settle(container);

    expect(state.picks, hasLength(30));
    expect(loader.loadCalls, 2);
  });

  test('生成失败时落到 errorMessage，retry 后能恢复', () async {
    final _FakeDailyStore store = _FakeDailyStore();
    final _FakePoolLoader loader = _FakePoolLoader(
      waves: <List<HotPlaylistTrack>>[_wave()],
      failures: 1,
    );
    final ProviderContainer container = _container(
      store: store,
      loader: loader,
      recommender: _CountingRecommender(),
      taste: _personalizedTaste(),
    );

    final DailyRecommendationState failed = await _settle(container);

    expect(failed.hasError, isTrue);
    expect(failed.errorMessage, '每日推荐生成失败，请稍后重试');
    expect(failed.picks, isEmpty);
    expect(failed.isLoading, isFalse);
    expect(store.saveCalls, 0);

    await container
        .read(dailyRecommendationControllerProvider.notifier)
        .retry();
    final DailyRecommendationState recovered = await _settle(container);

    expect(recovered.hasError, isFalse);
    expect(recovered.picks, hasLength(30));
    expect(recovered.dateKey, '2026-11-24');
    expect(store.saveCalls, 1);
  });

  test('同一会话里跨过 0 点后 ensureUpToDate 会重新生成', () async {
    DateTime now = DateTime(2026, 11, 24, 23, 40);
    final _FakeDailyStore store = _FakeDailyStore();
    final _FakePoolLoader loader = _FakePoolLoader(
      waves: <List<HotPlaylistTrack>>[_wave()],
    );
    final ProviderContainer container = _container(
      store: store,
      loader: loader,
      recommender: _CountingRecommender(),
      now: () => now,
      taste: _personalizedTaste(),
    );

    final DailyRecommendationState first = await _settle(container);
    expect(first.dateKey, '2026-11-24');
    expect(loader.loadCalls, 1);

    await container
        .read(dailyRecommendationControllerProvider.notifier)
        .ensureUpToDate();
    expect(loader.loadCalls, 1);
    expect(store.saveCalls, 1);

    now = DateTime(2026, 11, 25, 0, 5);
    await container
        .read(dailyRecommendationControllerProvider.notifier)
        .ensureUpToDate();
    final DailyRecommendationState next = await _settle(container);

    expect(next.dateKey, '2026-11-25');
    expect(next.picks, hasLength(30));
    expect(loader.loadCalls, 2);
    expect(store.saveCalls, 2);
    expect(store.load()!.dateKey, '2026-11-25');
  });

  test('通用曲名（催眠曲/摇篮曲）不会进入每日推荐', () async {
    final _FakeDailyStore store = _FakeDailyStore();
    final List<HotPlaylistTrack> wave = <HotPlaylistTrack>[
      for (int index = 0; index < 6; index += 1)
        HotPlaylistTrack(
          playlist: _playlistA,
          rank: index + 1,
          title: index == 0
              ? '催眠曲'
              : index == 1
              ? '摇篮曲'
              : '正常歌曲 $index',
          artist: '歌手 $index',
          coverUrl: 'https://example.com/$index.jpg',
          durationSeconds: 200,
        ),
    ];
    final ProviderContainer container = _container(
      store: store,
      loader: _FakePoolLoader(waves: <List<HotPlaylistTrack>>[wave, _wave()]),
      recommender: _CountingRecommender(),
      taste: _personalizedTaste(),
    );

    final DailyRecommendationState state = await _settle(container);

    expect(state.picks, hasLength(30));
    expect(
      state.picks.where(
        (DailyPick pick) => pick.title == '催眠曲' || pick.title == '摇篮曲',
      ),
      isEmpty,
    );
  });
  test('缺少封面的曲目会用 B 站匹配结果回填并落盘', () async {
    final _FakeDailyStore store = _FakeDailyStore(
      stored: DailyRecommendation(
        dateKey: '2026-11-24',
        generatedAtEpochMs: 5,
        picks: const <DailyPick>[
          DailyPick(
            title: '最初的记忆',
            artist: '火鸡',
            reason: RadarReason.explorer,
            durationSeconds: 29,
          ),
        ],
      ),
    );
    final ProviderContainer container = _container(
      store: store,
      loader: _FakePoolLoader(waves: const <List<HotPlaylistTrack>>[]),
      recommender: _CountingRecommender(),
      searchRepository: _FakeSearchRepository(
        items: const <SearchResultItem>[
          SearchResultItem(
            aid: 1,
            bvid: 'BV1',
            typeId: 3,
            title: '火鸡 - 最初的记忆 (完整版)',
            author: '某UP主',
            coverUrl: 'https://example.com/bili.jpg',
            duration: '04:00',
            playCountText: '1万',
            danmakuCountText: '',
            publishTimeText: '',
            tagText: '',
          ),
        ],
      ),
    );

    await _settle(container);
    await container
        .read(dailyRecommendationControllerProvider.notifier)
        .backfillCovers();

    final DailyRecommendationState state = container.read(
      dailyRecommendationControllerProvider,
    );
    expect(state.picks.single.coverUrl, 'https://example.com/bili.jpg');
    // 源接口给的 00:29 不可信，回填时用匹配到的 04:00 纠正。
    expect(state.picks.single.durationSeconds, 240);
    expect(store.load()!.picks.single.coverUrl, 'https://example.com/bili.jpg');
    expect(store.load()!.picks.single.durationSeconds, 240);
  });
}

class _FakeDailyStore implements DailyRecommendationStore {
  _FakeDailyStore({this.stored});

  DailyRecommendation? stored;
  int saveCalls = 0;

  @override
  DailyRecommendation? load() => stored;

  @override
  Future<void> save(DailyRecommendation recommendation) async {
    saveCalls += 1;
    stored = recommendation;
  }

  @override
  Future<void> clear() async {
    stored = null;
  }
}

class _FakePoolLoader implements RadarPoolLoader {
  _FakePoolLoader({required this.waves, this.failures = 0});

  final List<List<HotPlaylistTrack>> waves;
  int failures;
  int loadCalls = 0;
  int _servedWaves = 0;

  @override
  Future<RadarPoolResult> load({
    required Random random,
    int playlistsPerPlatform = RadarPoolLoader.defaultPlaylistsPerPlatform,
  }) async {
    loadCalls += 1;
    if (failures > 0) {
      failures -= 1;
      throw const HotPlaylistException('候选池炸了');
    }
    final int index = _servedWaves < waves.length
        ? _servedWaves
        : waves.length - 1;
    _servedWaves += 1;
    final List<HotPlaylistTrack> tracks = waves.isEmpty
        ? const <HotPlaylistTrack>[]
        : waves[index];
    return RadarPoolResult(
      tracks: tracks,
      lastError: tracks.isEmpty ? const HotPlaylistException('没有候选') : null,
    );
  }
}

class _CountingRecommender extends RadarRecommender {
  int calls = 0;

  @override
  List<RadarPick> pick({
    required List<HotPlaylistTrack> pool,
    required RadarTaste taste,
    required int limit,
    required Random random,
    Set<String> excludeKeys = const <String>{},
  }) {
    calls += 1;
    return super.pick(
      pool: pool,
      taste: taste,
      limit: limit,
      random: random,
      excludeKeys: excludeKeys,
    );
  }
}
