import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/search/data/bili_search_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingClient implements BiliHttpClient {
  @override
  BiliSession? get currentSession => null;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) {
    throw StateError('直连条目不应该发起网络请求');
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
  }) {
    throw StateError('直连条目不应该发起网络请求');
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw StateError('直连条目不应该发起网络请求');
  }
}

MusicChartResolver _resolver() {
  final _ThrowingClient client = _ThrowingClient();
  return MusicChartResolver(
    searchRepository: BiliSearchRepository(client),
    playerRepository: BiliPlayerRepository(client),
  );
}

void main() {
  test('returns the direct item without searching', () async {
    const PlayableItem directItem = PlayableItem(
      aid: 117556492898443,
      bvid: 'BV19gxX6iEE9',
      cid: 43314186691,
      page: 1,
      title: '晴天',
      author: '周杰伦',
      coverUrl: 'https://i2.hdslb.com/bfs/archive/a.jpg',
    );
    final MusicChartTrack track = MusicChartTrack(
      chart: MusicChartCatalog.chartsFor(MusicChartPlatform.bilibili).first,
      rank: 1,
      title: '晴天',
      artist: '周杰伦',
      coverUrl: 'https://i2.hdslb.com/bfs/archive/a.jpg',
      durationSeconds: 60,
      directItem: directItem,
    );

    final PlayableItem? resolved = await _resolver().resolve(track);

    expect(resolved, directItem);
    expect(resolved!.bvid, 'BV19gxX6iEE9');
  });

  test('falls back to search when there is no direct item', () async {
    final MusicChartTrack track = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 1,
      title: '晴天',
      artist: '周杰伦',
      coverUrl: '',
    );

    await expectLater(_resolver().resolve(track), throwsA(isA<StateError>()));
  });
}
