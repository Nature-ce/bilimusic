import 'package:bilimusic/core/net/bili_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_music_chart_source.g.dart';

@riverpod
BiliMusicChartSource biliMusicChartSource(Ref ref) {
  return BiliMusicChartSource(ref.read(biliClientProvider.notifier));
}

/// 拉取 B 站首页推荐与音乐分区热门，供首页热榜里的 B 站来源使用。
class BiliMusicChartSource {
  const BiliMusicChartSource(this._client);

  final BiliHttpClient _client;

  Future<Object?> fetchRecommend(int count) {
    return _client.getJson(
      '/x/web-interface/wbi/index/top/feed/rcmd',
      requiresWbi: true,
      queryParameters: <String, dynamic>{
        'fresh_type': 3,
        'ps': count,
        'fresh_idx': 1,
        'fresh_idx_1h': 1,
        'homepage_ver': 1,
        'brush': 0,
      },
    );
  }

  Future<Object?> fetchMusicRanking(int count) {
    return _client.getJson(
      '/x/web-interface/ranking/v2',
      queryParameters: <String, dynamic>{'rid': 3, 'type': 'all'},
    );
  }
}
