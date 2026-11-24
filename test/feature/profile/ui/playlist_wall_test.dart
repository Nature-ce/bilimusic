import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/ui/components/music_platform_badge.dart';
import 'package:bilimusic/feature/profile/ui/components/playlist_wall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('歌单墙卡片显示名字、曲目数与更新时间', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        PlaylistWallCard(
          title: '深夜循环',
          trackCount: 13,
          coverUrl: null,
          updatedAt: DateTime.now(),
          onTap: () {},
        ),
      ),
    );

    expect(find.text('深夜循环'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(find.text('今天更新'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('收藏歌单卡片显示平台标识与「曲目数 · 平台」', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        PlaylistWallCard(
          title: '中国风X嘻哈:盛世华夏,侠客江湖行',
          trackCount: 23,
          coverUrl: null,
          platform: MusicChartPlatform.kugou,
          coverSize: favoritePlaylistWallCoverSize,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('23 首 · 酷狗'), findsOneWidget);
    expect(find.byType(MusicPlatformBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点击歌单卡与「新建歌单」卡都会触发回调', (WidgetTester tester) async {
    int opened = 0;
    int creates = 0;
    await tester.pumpWidget(
      _wrap(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PlaylistWallCard(
              title: '音乐',
              trackCount: 1,
              coverUrl: null,
              onTap: () => opened += 1,
            ),
            const SizedBox(width: playlistWallGap),
            CreatePlaylistWallCard(onTap: () => creates += 1),
          ],
        ),
      ),
    );

    await tester.tap(find.text('音乐'));
    await tester.tap(find.text('新建歌单'));
    await tester.pump();

    expect(opened, 1);
    expect(creates, 1);
    expect(tester.takeException(), isNull);
  });
}
