import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:bilimusic/feature/radar/ui/components/music_radar_visual.dart';
import 'package:bilimusic/feature/radar/ui/music_radar_page.dart';
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
      title: '雷达歌曲一',
      artist: '歌手甲',
      coverUrl: '',
      durationSeconds: 245,
    ),
    const HotPlaylistTrack(
      playlist: _playlist,
      rank: 2,
      title: '雷达歌曲二',
      artist: '歌手乙',
      coverUrl: '',
    ),
  ];
}

class _LoadedRadar extends MusicRadarController {
  int scanCalls = 0;

  @override
  MusicRadarState build() =>
      MusicRadarState(tracks: _tracks(), scanCount: 1, isScanning: false);

  @override
  Future<void> scan() async {
    scanCalls += 1;
  }
}

class _ScanningRadar extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState(isScanning: true);
}

class _EmptyRadar extends MusicRadarController {
  @override
  MusicRadarState build() => const MusicRadarState();
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester, {
  required MusicRadarController Function() controller,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final ProviderContainer container = ProviderContainer(
    overrides: [musicRadarControllerProvider.overrideWith(controller)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme(defaultThemeVariantId),
        home: const MusicRadarPage(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return container;
}

void main() {
  testWidgets('renders the radar card and discovered tracks', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _LoadedRadar.new);

    expect(find.text('音乐雷达'), findsOneWidget);
    expect(find.text('跨平台漫游'), findsOneWidget);
    expect(find.text('本次发现'), findsOneWidget);
    expect(find.text('雷达歌曲一'), findsOneWidget);
    expect(find.text('雷达歌曲二'), findsOneWidget);
    expect(find.byType(MusicRadarVisual), findsOneWidget);
    expect(find.text('重新扫描'), findsOneWidget);
    expect(find.textContaining('第 1 轮'), findsWidgets);
  });

  testWidgets('tapping rescan asks the controller to scan again', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpPage(
      tester,
      controller: _LoadedRadar.new,
    );

    await tester.tap(find.text('重新扫描'));
    await tester.pump();

    final _LoadedRadar radar =
        container.read(musicRadarControllerProvider.notifier) as _LoadedRadar;
    expect(radar.scanCalls, 1);
  });

  testWidgets('shows the skeleton while scanning without results', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _ScanningRadar.new, settle: false);

    expect(find.text('正在扫描各平台热门歌单…'), findsOneWidget);
    expect(find.text('本次发现'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows an idle state before the first scan', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, controller: _EmptyRadar.new);

    expect(find.text('雷达待命中'), findsOneWidget);
    expect(find.text('开始扫描'), findsOneWidget);
  });
}
