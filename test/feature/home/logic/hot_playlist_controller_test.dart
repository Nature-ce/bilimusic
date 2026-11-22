import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

HotPlaylist _playlist(MusicChartPlatform platform, String id) {
  return HotPlaylist(
    platform: platform,
    id: id,
    name: '歌单 $id',
    coverUrl: '',
    trackCount: 10,
  );
}

class _FakeHotPlaylistRepository extends HotPlaylistRepository {
  _FakeHotPlaylistRepository({this.failing = const <MusicChartPlatform>{}});

  final Set<MusicChartPlatform> failing;

  @override
  Future<List<HotPlaylist>> fetchPlaylists(
    MusicChartPlatform platform, {
    bool forceRefresh = false,
  }) async {
    if (failing.contains(platform)) {
      throw const FormatException('boom');
    }
    return switch (platform) {
      MusicChartPlatform.netease => <HotPlaylist>[
        _playlist(platform, 'n1'),
        _playlist(platform, 'n2'),
      ],
      MusicChartPlatform.tencent => <HotPlaylist>[_playlist(platform, 'q1')],
      MusicChartPlatform.kugou => <HotPlaylist>[
        _playlist(platform, 'k1'),
        _playlist(platform, 'k2'),
      ],
      MusicChartPlatform.bilibili => const <HotPlaylist>[],
    };
  }
}

Future<HotPlaylistState> _loadState(ProviderContainer container) async {
  for (int attempt = 0; attempt < 40; attempt += 1) {
    final HotPlaylistState state = container.read(
      hotPlaylistControllerProvider,
    );
    if (!state.isLoading) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return container.read(hotPlaylistControllerProvider);
}

void main() {
  test('merges every platform into one round-robin feed', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        hotPlaylistRepositoryProvider.overrideWithValue(
          _FakeHotPlaylistRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<HotPlaylistState> subscription = container
        .listen(hotPlaylistControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    final HotPlaylistState state = await _loadState(container);

    expect(
      state.playlists.map((HotPlaylist playlist) => playlist.id).toList(),
      <String>['n1', 'q1', 'k1', 'n2', 'k2'],
    );
    expect(state.hasError, isFalse);
  });

  test('keeps the feed usable when one platform fails', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        hotPlaylistRepositoryProvider.overrideWithValue(
          _FakeHotPlaylistRepository(
            failing: <MusicChartPlatform>{MusicChartPlatform.tencent},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<HotPlaylistState> subscription = container
        .listen(hotPlaylistControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    final HotPlaylistState state = await _loadState(container);

    expect(
      state.playlists.map((HotPlaylist playlist) => playlist.platform).toSet(),
      <MusicChartPlatform>{
        MusicChartPlatform.netease,
        MusicChartPlatform.kugou,
      },
    );
    expect(state.hasError, isFalse);
  });
}
