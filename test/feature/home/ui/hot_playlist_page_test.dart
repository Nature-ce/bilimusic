import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/home/ui/hot_playlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const HotPlaylist _playlist = HotPlaylist(
  platform: MusicChartPlatform.netease,
  id: '1',
  name: '测试歌单',
  coverUrl: '',
  playCount: 10000,
  trackCount: 2,
  creator: 'UP主',
);

HotPlaylistRepository _repository({int total = 2}) {
  return HotPlaylistRepository(
    httpGet: (String url, Map<String, dynamic> query, _) async {
      if (url.contains('/api/v6/playlist/detail')) {
        return <String, dynamic>{
          'playlist': <String, dynamic>{
            'trackIds': <Map<String, dynamic>>[
              for (int index = 0; index < total; index += 1)
                <String, dynamic>{'id': index + 1},
            ],
          },
        };
      }
      final String ids = (query['ids'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '');
      final List<String> parts = ids.split(',');
      return <String, dynamic>{
        'songs': <Map<String, dynamic>>[
          for (final String id in parts)
            <String, dynamic>{
              'name': id == '1' ? '晴天' : '歌曲 $id',
              'duration': 269000,
              'artists': <Map<String, dynamic>>[
                <String, dynamic>{'name': '周杰伦'},
              ],
            },
        ],
      };
    },
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  HotPlaylist? initialPlaylist = _playlist,
  int total = 2,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hotPlaylistRepositoryProvider.overrideWithValue(
          _repository(total: total),
        ),
      ],
      child: MaterialApp(
        home: HotPlaylistPage(
          platform: MusicChartPlatform.netease,
          playlistId: '1',
          initialPlaylist: initialPlaylist,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the playlist header and its tracks', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('测试歌单'), findsWidgets);
    expect(find.textContaining('1.0万次播放'), findsOneWidget);
    expect(find.text('晴天'), findsOneWidget);
    expect(find.text('04:29'), findsWidgets);
    expect(find.text('周杰伦'), findsWidgets);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });

  testWidgets('uses a placeholder title when opened without metadata', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, initialPlaylist: null);

    expect(find.text('热门歌单'), findsWidgets);
    expect(find.text('晴天'), findsOneWidget);
  });

  testWidgets('loads every page automatically without a load-more button', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, total: 120);

    expect(find.textContaining('加载更多'), findsNothing);
    expect(find.textContaining('已加载全部'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('歌曲 120'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('歌曲 120'), findsOneWidget);
    expect(find.byType(TrackRowTile), findsWidgets);
  });
}
