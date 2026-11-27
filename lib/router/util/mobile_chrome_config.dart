class MobileChromeConfig {
  const MobileChromeConfig({
    required this.showBottomTabs,
    required this.showMiniPlayer,
  });

  final bool showBottomTabs;
  final bool showMiniPlayer;

  /// 主页面配置
  static const MobileChromeConfig mainTab = MobileChromeConfig(
    showBottomTabs: true,
    showMiniPlayer: true,
  );

  // 不显示底部导航
  static const MobileChromeConfig detail = MobileChromeConfig(
    showBottomTabs: false,
    showMiniPlayer: true,
  );

  // 什么也不显示
  static const MobileChromeConfig fullScreen = MobileChromeConfig(
    showBottomTabs: false,
    showMiniPlayer: false,
  );

  /// 只有三个 tab 根页显示底部导航；其余页面（含首页里 push 出来的歌单、
  /// 榜单等详情页）一律只保留播放行。
  static const Set<String> _tabRoots = <String>{'/home', '/profile'};

  static MobileChromeConfig resolve(String path) {
    if (path == '/radar' ||
        path == '/player' ||
        path == '/search' ||
        path == '/auth' ||
        path == '/profile/report' ||
        path == '/settings' ||
        path.startsWith('/settings/') ||
        path == '/statistics' ||
        path.startsWith('/statistics/')) {
      return fullScreen;
    }

    if (_tabRoots.contains(path)) {
      return mainTab;
    }

    return detail;
  }
}
