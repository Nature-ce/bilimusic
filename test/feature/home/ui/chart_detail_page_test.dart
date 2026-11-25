import 'package:bilimusic/feature/home/data/favorite_music_chart_repository.dart';
import 'package:bilimusic/feature/home/data/music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/favorite_music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/chart_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChartRepository extends MusicChartRepository {
  _FakeChartRepository(this.tracks);

  final List<MusicChartTrack> tracks;
  int fetchCalls = 0;

  @override
  Future<List<MusicChartTrack>> fetchTracks(MusicChart chart) async {
    fetchCalls += 1;
    return tracks;
  }
}

class _MemoryFavoriteChartRepository extends FavoriteMusicChartRepository {
  _MemoryFavoriteChartRepository();

  List<MusicChart> stored = <MusicChart>[];

  @override
  List<MusicChart> load() => stored;

  @override
  Future<void> save(List<MusicChart> charts) async {
    stored = charts;
  }
}

void main() {
  final MusicChart chart = MusicChartCatalog.neteaseCharts.first;

  Future<_FakeChartRepository> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakeChartRepository repository =
        _FakeChartRepository(<MusicChartTrack>[
          for (int index = 0; index < 3; index += 1)
            MusicChartTrack(
              chart: chart,
              rank: index + 1,
              title: '榜单歌曲 $index',
              artist: '歌手 $index',
              coverUrl: '',
              durationSeconds: 200 + index,
            ),
        ]);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        musicChartRepositoryProvider.overrideWithValue(repository),
        favoriteMusicChartRepositoryProvider.overrideWithValue(
          _MemoryFavoriteChartRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: FlutterSmartDialog.init(),
          home: ChartDetailPage(chart: chart),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('renders the chart header, actions and tracks', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('网易云 · 榜单'), findsOneWidget);
    expect(find.text(chart.name), findsWidgets);
    expect(find.textContaining('共 3 首'), findsOneWidget);
    expect(find.text('歌曲'), findsOneWidget);
    expect(find.text('榜单歌曲 0'), findsOneWidget);
    expect(find.text('歌手 1'), findsOneWidget);
    expect(find.text('03:21'), findsOneWidget);
    expect(find.byKey(const Key('chartDetailPlayAll')), findsOneWidget);
    expect(find.byKey(const Key('chartDetailDownload')), findsOneWidget);
    expect(find.byKey(const Key('chartDetailFavorite')), findsNothing);
    expect(find.byKey(const Key('chartDetailRefresh')), findsNothing);
    expect(find.text('播放全部'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('action row keeps play-all and download only', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('chartDetailPlayAll')), findsOneWidget);
    expect(find.byKey(const Key('chartDetailDownload')), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('pull to refresh reloads the chart without skeleton', (
    WidgetTester tester,
  ) async {
    final _FakeChartRepository repository = await pumpPage(tester);
    expect(repository.fetchCalls, 1);

    await tester.drag(find.byType(ListView), const Offset(0, 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.pumpAndSettle();
    expect(repository.fetchCalls, 2);
    expect(find.byKey(const Key('chartDetailPlayAll')), findsOneWidget);
    // 等「已是最新」提示自然消失，避免留下未完成的定时器。
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
