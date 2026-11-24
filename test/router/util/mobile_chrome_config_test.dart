import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('刷歌页自带播放器，不显示底部导航与迷你播放器', () {
    final MobileChromeConfig chrome = MobileChromeConfig.resolve('/radar');

    expect(chrome.showBottomTabs, isFalse);
    expect(chrome.showMiniPlayer, isFalse);
  });

  test('首页仍然显示底部导航与迷你播放器', () {
    final MobileChromeConfig chrome = MobileChromeConfig.resolve('/home');

    expect(chrome.showBottomTabs, isTrue);
    expect(chrome.showMiniPlayer, isTrue);
  });

  test('播放页与设置页保持全屏', () {
    for (final String path in <String>[
      '/player',
      '/settings',
      '/settings/theme',
    ]) {
      final MobileChromeConfig chrome = MobileChromeConfig.resolve(path);

      expect(chrome.showBottomTabs, isFalse, reason: path);
      expect(chrome.showMiniPlayer, isFalse, reason: path);
    }
  });

  test('搜索页全屏，详情页保留迷你播放器但隐藏底部导航', () {
    final MobileChromeConfig search = MobileChromeConfig.resolve('/search');

    expect(search.showBottomTabs, isFalse);
    expect(search.showMiniPlayer, isFalse);

    final MobileChromeConfig detail = MobileChromeConfig.resolve('/comments');

    expect(detail.showBottomTabs, isFalse);
    expect(detail.showMiniPlayer, isTrue);

    final MobileChromeConfig daily = MobileChromeConfig.resolve('/daily');

    expect(daily.showBottomTabs, isFalse);
    expect(daily.showMiniPlayer, isTrue);
  });

  test('收藏 UP 主与听歌报告页全屏', () {
    for (final String path in <String>[
      '/profile/favorite-ups',
      '/profile/report',
    ]) {
      final MobileChromeConfig chrome = MobileChromeConfig.resolve(path);

      expect(chrome.showBottomTabs, isFalse, reason: path);
      expect(chrome.showMiniPlayer, isFalse, reason: path);
    }
  });
}
