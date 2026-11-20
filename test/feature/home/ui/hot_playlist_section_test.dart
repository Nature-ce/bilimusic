import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/ui/components/hot_playlist_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoadedPlaylists extends HotPlaylistController {
  @override
  HotPlaylistState build() => const HotPlaylistState(
    platform: MusicChartPlatform.netease,
    playlists: <HotPlaylist>[
      HotPlaylist(
        platform: MusicChartPlatform.netease,
        id: '1',
        name: '测试歌单 A',
        coverUrl: '',
        playCount: 12345,
        trackCount: 20,
        creator: 'UP主',
      ),
      HotPlaylist(
        platform: MusicChartPlatform.netease,
        id: '2',
        name: '测试歌单 B',
        coverUrl: '',
        playCount: 86000000,
        trackCount: 35,
        creator: '另一个UP主',
      ),
    ],
  );
}

class _LoadingPlaylists extends HotPlaylistController {
  @override
  HotPlaylistState build() => const HotPlaylistState(isLoading: true);
}

class _FailedPlaylists extends HotPlaylistController {
  @override
  HotPlaylistState build() =>
      const HotPlaylistState(isLoading: false, errorMessage: '歌单加载失败');
}

Future<void> _pumpSection(
  WidgetTester tester, {
  required HotPlaylistController Function() controller,
  ValueChanged<HotPlaylist>? onPlaylistTap,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [hotPlaylistControllerProvider.overrideWith(controller)],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HotPlaylistSection(onPlaylistTap: onPlaylistTap),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders playlist cards with summary text', (
    WidgetTester tester,
  ) async {
    await _pumpSection(tester, controller: _LoadedPlaylists.new);

    expect(find.text('测试歌单 A'), findsOneWidget);
    expect(find.text('测试歌单 B'), findsOneWidget);
    expect(find.textContaining('1.2万'), findsOneWidget);
    expect(find.textContaining('20 首'), findsOneWidget);
    expect(find.text('网易云'), findsOneWidget);
    expect(find.text('QQ音乐'), findsOneWidget);
    expect(find.text('酷狗'), findsOneWidget);
  });

  testWidgets('tapping a card reports the playlist', (
    WidgetTester tester,
  ) async {
    HotPlaylist? tapped;
    await _pumpSection(
      tester,
      controller: _LoadedPlaylists.new,
      onPlaylistTap: (HotPlaylist playlist) => tapped = playlist,
    );

    await tester.tap(find.text('测试歌单 B'));
    await tester.pump();

    expect(tapped?.id, '2');
  });

  testWidgets('shows skeleton cards while loading', (
    WidgetTester tester,
  ) async {
    await _pumpSection(tester, controller: _LoadingPlaylists.new);

    expect(find.text('测试歌单 A'), findsNothing);
    // 手机三列，骨架铺两行。
    expect(find.byType(AspectRatio), findsNWidgets(6));
  });

  test('热门歌单手机上三列，宽屏四列', () {
    expect(hotPlaylistGridColumns(360), 3);
    expect(hotPlaylistGridColumns(390), 3);
    expect(hotPlaylistGridColumns(600), 3);
    expect(hotPlaylistGridColumns(879), 3);
    expect(hotPlaylistGridColumns(880), 4);
    expect(hotPlaylistGridColumns(1440), 4);
  });

  testWidgets('shows a retryable error state', (WidgetTester tester) async {
    await _pumpSection(tester, controller: _FailedPlaylists.new);

    expect(find.text('热门歌单加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
