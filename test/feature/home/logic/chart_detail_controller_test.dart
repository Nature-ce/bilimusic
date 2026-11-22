import 'package:bilimusic/feature/home/data/music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/chart_detail_data.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/chart_detail_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads a chart once and refreshes on demand', () async {
    final MusicChart chart = MusicChartCatalog.neteaseCharts.first;
    final _FakeChartRepository repository = _FakeChartRepository(
      <MusicChartTrack>[
        _track(chart, rank: 1, title: '晴天'),
        _track(chart, rank: 2, title: '稻香'),
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [musicChartRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final ChartDetailData data = await container.read(
      chartDetailControllerProvider(chart).future,
    );

    expect(data.tracks, hasLength(2));
    expect(data.tracks.first.title, '晴天');
    expect(data.updatedAtMs, greaterThan(0));
    expect(repository.fetchCalls, 1);

    await container
        .read(chartDetailControllerProvider(chart).notifier)
        .refresh();

    final ChartDetailData refreshed = container
        .read(chartDetailControllerProvider(chart))
        .requireValue;
    expect(refreshed.tracks, hasLength(2));
    expect(repository.fetchCalls, 2);
  });

  test('surfaces repository failures as error state', () async {
    final MusicChart chart = MusicChartCatalog.tencentCharts.first;
    final ProviderContainer container = ProviderContainer(
      overrides: [
        musicChartRepositoryProvider.overrideWithValue(
          _FakeChartRepository(
            const <MusicChartTrack>[],
            error: const MusicChartException('接口炸了'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<AsyncValue<ChartDetailData>> subscription =
        container.listen(
          chartDetailControllerProvider(chart),
          (_, _) {},
          fireImmediately: true,
        );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    for (int attempt = 0; attempt < 20; attempt += 1) {
      if (container.read(chartDetailControllerProvider(chart)).hasError) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    final AsyncValue<ChartDetailData> failed = container.read(
      chartDetailControllerProvider(chart),
    );
    expect(failed.hasError, isTrue);
    expect(failed.error, isA<MusicChartException>());
  });
}

MusicChartTrack _track(
  MusicChart chart, {
  required int rank,
  required String title,
}) {
  return MusicChartTrack(
    chart: chart,
    rank: rank,
    title: title,
    artist: '周杰伦',
    coverUrl: '',
    durationSeconds: 269,
  );
}

class _FakeChartRepository extends MusicChartRepository {
  _FakeChartRepository(this.tracks, {this.error});

  final List<MusicChartTrack> tracks;
  final Object? error;
  int fetchCalls = 0;

  @override
  Future<List<MusicChartTrack>> fetchTracks(MusicChart chart) async {
    fetchCalls += 1;
    final Object? failure = error;
    if (failure != null) {
      throw failure;
    }
    return tracks;
  }
}
