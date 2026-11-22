import 'dart:io';

import 'package:bilimusic/feature/home/data/favorite_music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/logic/favorite_music_chart_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<String> box;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('favorite_chart_test');
    Hive.init(directory.path);
    box = await Hive.openBox<String>('favorite_chart_prefs');
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('toggles chart favorites and persists them', () async {
    final FavoriteMusicChartRepository repository =
        FavoriteMusicChartRepository.withBox(box);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        favoriteMusicChartRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final MusicChart chart = MusicChartCatalog.neteaseCharts.first;

    expect(container.read(favoriteMusicChartsProvider), isEmpty);
    expect(
      container.read(favoriteMusicChartsProvider.notifier).contains(chart),
      isFalse,
    );

    final bool favorited = await container
        .read(favoriteMusicChartsProvider.notifier)
        .toggle(chart);
    expect(favorited, isTrue);
    expect(container.read(favoriteMusicChartsProvider), hasLength(1));
    expect(
      container.read(favoriteMusicChartsProvider.notifier).contains(chart),
      isTrue,
    );

    final List<MusicChart> reloaded = FavoriteMusicChartRepository.withBox(
      box,
    ).load();
    expect(reloaded, hasLength(1));
    expect(reloaded.single.key, chart.key);

    final bool removed = await container
        .read(favoriteMusicChartsProvider.notifier)
        .toggle(chart);
    expect(removed, isFalse);
    expect(container.read(favoriteMusicChartsProvider), isEmpty);
  });

  test('shows the most recently favorited chart first', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        favoriteMusicChartRepositoryProvider.overrideWithValue(
          FavoriteMusicChartRepository.withBox(box),
        ),
      ],
    );
    addTearDown(container.dispose);

    final MusicChart first = MusicChartCatalog.neteaseCharts.first;
    final MusicChart second = MusicChartCatalog.neteaseCharts[1];

    await container.read(favoriteMusicChartsProvider.notifier).toggle(first);
    await container.read(favoriteMusicChartsProvider.notifier).toggle(second);

    final List<MusicChart> charts = container.read(favoriteMusicChartsProvider);
    expect(charts.map((MusicChart chart) => chart.key).toList(), <String>[
      second.key,
      first.key,
    ]);
  });
}
