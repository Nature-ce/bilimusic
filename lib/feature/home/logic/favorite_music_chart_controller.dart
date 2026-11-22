import 'package:bilimusic/feature/home/data/favorite_music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_music_chart_controller.g.dart';

@Riverpod(keepAlive: true)
FavoriteMusicChartRepository favoriteMusicChartRepository(Ref ref) {
  return FavoriteMusicChartRepository();
}

@Riverpod(keepAlive: true)
class FavoriteMusicCharts extends _$FavoriteMusicCharts {
  late final FavoriteMusicChartRepository _repository = ref.read(
    favoriteMusicChartRepositoryProvider,
  );

  @override
  List<MusicChart> build() => _repository.load();

  bool contains(MusicChart chart) {
    return state.any((MusicChart item) => item.key == chart.key);
  }

  Future<bool> toggle(MusicChart chart) async {
    final bool willFavorite = !contains(chart);
    final List<MusicChart> next = willFavorite
        ? <MusicChart>[
            chart,
            ...state.where((MusicChart item) => item.key != chart.key),
          ]
        : state
              .where((MusicChart item) => item.key != chart.key)
              .toList(growable: false);
    state = next;
    await _repository.save(next);
    return willFavorite;
  }
}
