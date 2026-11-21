import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/home/data/favorite_hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/favorite_hot_playlist_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const HotPlaylist _playlist = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: '123',
  name: '测试歌单',
  coverUrl: 'https://example.com/cover.jpg',
  playCount: 12000,
  trackCount: 68,
  favoriteCount: 2858,
  creator: '索尼音乐国际',
);

void main() {
  late Directory dir;
  late Box<String> box;
  late FavoriteHotPlaylistRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hot_playlist_favorites');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('test_prefs');
    repository = FavoriteHotPlaylistRepository.withBox(box);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('收藏列表可以存下来再读回来', () async {
    expect(repository.load(), isEmpty);

    await repository.save(<HotPlaylist>[_playlist]);
    final HotPlaylist restored = repository.load().single;

    expect(restored.key, _playlist.key);
    expect(restored.name, '测试歌单');
    expect(restored.platform, MusicChartPlatform.netease);
    expect(restored.trackCount, 68);
    expect(restored.favoriteCount, 2858);
    expect(restored.coverUrl, 'https://example.com/cover.jpg');
  });

  test('坏数据不会崩，按空列表处理', () async {
    await box.put(HiveKeys.favoriteHotPlaylists, '不是 JSON');
    expect(repository.load(), isEmpty);
  });

  test('切换收藏：新收藏排在最前，再点一次取消', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        favoriteHotPlaylistRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final FavoriteHotPlaylists notifier = container.read(
      favoriteHotPlaylistsProvider.notifier,
    );

    expect(notifier.contains(_playlist), isFalse);
    expect(await notifier.toggle(_playlist), isTrue);
    expect(container.read(favoriteHotPlaylistsProvider), hasLength(1));

    const HotPlaylist other = HotPlaylist(
      platform: MusicChartPlatform.tencent,
      id: '456',
      name: '另一个歌单',
      coverUrl: '',
      trackCount: 12,
    );
    await notifier.toggle(other);
    expect(
      container
          .read(favoriteHotPlaylistsProvider)
          .map((HotPlaylist item) => item.id),
      <String>['456', '123'],
    );

    expect(await notifier.toggle(_playlist), isFalse);
    expect(
      container
          .read(favoriteHotPlaylistsProvider)
          .map((HotPlaylist item) => item.id),
      <String>['456'],
    );
    expect(repository.load().single.id, '456');
  });
}
