import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/logic/radar_pick_reasons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PlayableItem item = PlayableItem(
    aid: 112,
    bvid: 'BV1tn9aBqER7',
    title: '【Hi-Res无损音质】|《我不难过》- 孙燕姿',
    author: 'VV音乐局',
    coverUrl: '',
    page: 1,
  );

  test('记住推荐理由后能按视频取回来', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final RadarPickReasons reasons = container.read(
      radarPickReasonsProvider.notifier,
    );

    reasons.record(
      item,
      RadarPick(
        track: _track(title: '我不难过', artist: '孙燕姿'),
        reason: RadarReason.explorer,
      ),
    );

    expect(
      container.read(radarPickReasonsProvider.notifier).pickFor(item)?.reason,
      RadarReason.explorer,
    );
    expect(
      container.read(radarPickReasonsProvider.notifier).pickFor(null),
      isNull,
    );
  });

  test('cid 补全后 stableId 变了，推荐理由依然对得上', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final RadarPickReasons reasons = container.read(
      radarPickReasonsProvider.notifier,
    );

    reasons.record(
      item.copyWith(cid: null),
      RadarPick(
        track: _track(title: '我不难过', artist: '孙燕姿'),
        reason: RadarReason.familiarArtist,
        reasonDetail: '孙燕姿',
      ),
    );

    final RadarPick? played = container
        .read(radarPickReasonsProvider.notifier)
        .pickFor(item.copyWith(cid: 7788990));

    expect(played, isNotNull);
    expect(played!.reasonLabel, '因为你常听 孙燕姿');
  });

  test('不同视频互不串味', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final RadarPickReasons reasons = container.read(
      radarPickReasonsProvider.notifier,
    );

    reasons.record(
      item,
      RadarPick(
        track: _track(title: '我不难过', artist: '孙燕姿'),
        reason: RadarReason.coldStart,
      ),
    );

    expect(reasons.pickFor(item.copyWith(bvid: 'BV1other', aid: 999)), isNull);
  });
}

HotPlaylistTrack _track({required String title, required String artist}) {
  return HotPlaylistTrack(
    playlist: const HotPlaylist(
      platform: MusicChartPlatform.netease,
      id: 'p1',
      name: '热歌榜',
      coverUrl: '',
    ),
    rank: 4,
    title: title,
    artist: artist,
    coverUrl: '',
  );
}
