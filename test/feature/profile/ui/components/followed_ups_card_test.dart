import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/feature/profile/ui/components/followed_ups_card.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FavoriteUp _up(int mid) {
  return FavoriteUp(
    mid: mid,
    name: 'UP $mid',
    avatarUrl: '',
    favoritedAtEpochMs: 0,
    updatedAtEpochMs: 0,
  );
}

void main() {
  testWidgets('renders title, meta and responds to tap', (
    WidgetTester tester,
  ) async {
    int tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FollowedUpsCard(
            ups: <FavoriteUp>[_up(1), _up(2), _up(3), _up(4)],
            onTap: () {
              tapCount += 1;
            },
          ),
        ),
      ),
    );

    expect(find.text('关注的 UP 主'), findsOneWidget);
    expect(find.text('4 位 · 查看 / 管理'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.byType(CommonCachedAvatar), findsNWidgets(3));
    expect(tester.widget<Text>(find.text('关注的 UP 主')).maxLines, 1);
    expect(tester.widget<Text>(find.text('4 位 · 查看 / 管理')).maxLines, 1);
    expect(
      tester.getCenter(find.text('关注的 UP 主')).dy,
      moreOrLessEquals(
        tester.getCenter(find.text('4 位 · 查看 / 管理')).dy,
        epsilon: 0.5,
      ),
    );

    await tester.tap(find.byType(FollowedUpsCard));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('empty list shows zero count and placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FollowedUpsCard(ups: const <FavoriteUp>[], onTap: () {}),
        ),
      ),
    );

    expect(find.text('关注的 UP 主'), findsOneWidget);
    expect(find.text('0 位 · 查看 / 管理'), findsOneWidget);
    expect(find.byType(CommonCachedAvatar), findsNothing);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });

  testWidgets('keeps title and meta on one line on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FollowedUpsCard(
            ups: <FavoriteUp>[_up(1), _up(2)],
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('关注的 UP 主'), findsOneWidget);
    expect(find.text('2 位 · 查看 / 管理'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
