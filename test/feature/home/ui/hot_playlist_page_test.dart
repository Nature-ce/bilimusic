import 'package:bilimusic/feature/home/data/hot_playlist_repository.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
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
          for (int index = 0; index < parts.length; index += 1)
            <String, dynamic>{
              'name': index == 0 && total <= 2 ? '晴天' : '歌曲 ${parts[index]}',
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
    expect(find.textContaining('加载更多'), findsNothing);
  });

  testWidgets('uses a placeholder title when opened without metadata', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, initialPlaylist: null);

    expect(find.text('热门歌单'), findsWidgets);
    expect(find.text('晴天'), findsOneWidget);
  });

  testWidgets('loads more tracks until the playlist is complete', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, total: 35);

    await tester.scrollUntilVisible(
      find.text('加载更多（30 / 35）'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('加载更多（30 / 35）'), findsOneWidget);
    expect(find.textContaining('已加载全部'), findsNothing);

    await tester.tap(find.text('加载更多（30 / 35）'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('已加载全部 35 首'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('加载更多（30 / 35）'), findsNothing);
    expect(find.text('已加载全部 35 首'), findsOneWidget);
  });
}
