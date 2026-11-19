import 'package:bilimusic/feature/meting/domain/meting_server.dart';

enum MusicChartPlatform {
  netease(server: MetingServer.netease, label: '网易云'),
  tencent(server: MetingServer.tencent, label: 'QQ音乐'),
  kugou(server: MetingServer.kugou, label: '酷狗'),
  bilibili(label: 'B站');

  const MusicChartPlatform({this.server, required this.label});

  final MetingServer? server;
  final String label;

  /// 支持「热门歌单」的平台；B 站没有公开的歌单接口。
  static const List<MusicChartPlatform> playlistPlatforms =
      <MusicChartPlatform>[
        MusicChartPlatform.netease,
        MusicChartPlatform.tencent,
        MusicChartPlatform.kugou,
      ];

  bool get isBilibili => this == MusicChartPlatform.bilibili;

  bool get supportsPlaylists => !isBilibili;

  static MusicChartPlatform? tryFromName(String value) {
    for (final MusicChartPlatform platform in values) {
      if (platform.name == value) {
        return platform;
      }
    }
    return null;
  }

  /// B 站条目本身就是视频，点击直接播放，不需要再搜 B 站。
  bool get playsDirectly => isBilibili;
}
