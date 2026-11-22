import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'radar_refresh_requests.g.dart';

/// 「换一批推荐」的请求计数：播放页菜单点一下就 +1，刷歌页收到后重算一批。
@Riverpod(keepAlive: true)
class RadarRefreshRequests extends _$RadarRefreshRequests {
  @override
  int build() => 0;

  void request() => state = state + 1;
}
