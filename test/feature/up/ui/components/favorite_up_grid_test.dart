import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 11, 23, 10, 30);
  final int fetchedAt = now.millisecondsSinceEpoch;

  FavoriteUp up(
    int mid, {
    required String name,
    required int favoritedAtEpochMs,
  }) {
    return FavoriteUp(
      mid: mid,
      name: name,
      avatarUrl: '',
      favoritedAtEpochMs: favoritedAtEpochMs,
      updatedAtEpochMs: favoritedAtEpochMs,
    );
  }

  FavoriteUpUpdate update({
    int mid = 1,
    int? latestPublishAt,
    int todayVideoCount = 0,
    bool failed = false,
    int? fetchedAtEpochMs,
  }) {
    return FavoriteUpUpdate(
      mid: mid,
      fetchedAtEpochMs: fetchedAtEpochMs ?? fetchedAt,
      latestPublishAtEpochMs: latestPublishAt,
      todayVideoCount: todayVideoCount,
      failed: failed,
    );
  }

  group('favoriteUpUpdateLabel', () {
    test('shows the today count when videos were published today', () {
      expect(
        favoriteUpUpdateLabel(
          update(latestPublishAt: fetchedAt, todayVideoCount: 3),
          now: now,
        ),
        '今日 3 首更新',
      );
    });

    test('labels a video published yesterday', () {
      final DateTime yesterday = now.subtract(const Duration(days: 1));

      expect(
        favoriteUpUpdateLabel(
          update(latestPublishAt: yesterday.millisecondsSinceEpoch),
          now: now,
        ),
        '昨天更新',
      );
    });

    test('labels 2 to 6 days ago in days', () {
      for (final int days in <int>[2, 3, 6]) {
        final DateTime publishedAt = now.subtract(Duration(days: days));
        expect(
          favoriteUpUpdateLabel(
            update(latestPublishAt: publishedAt.millisecondsSinceEpoch),
            now: now,
          ),
          '$days 天前',
        );
      }
    });

    test('labels 7 to 29 days ago in weeks', () {
      expect(
        favoriteUpUpdateLabel(
          update(
            latestPublishAt: now
                .subtract(const Duration(days: 7))
                .millisecondsSinceEpoch,
          ),
          now: now,
        ),
        '1 周前',
      );
      expect(
        favoriteUpUpdateLabel(
          update(
            latestPublishAt: now
                .subtract(const Duration(days: 29))
                .millisecondsSinceEpoch,
          ),
          now: now,
        ),
        '4 周前',
      );
    });

    test('labels 30 days or more in months', () {
      expect(
        favoriteUpUpdateLabel(
          update(
            latestPublishAt: now
                .subtract(const Duration(days: 30))
                .millisecondsSinceEpoch,
          ),
          now: now,
        ),
        '1 个月前',
      );
      expect(
        favoriteUpUpdateLabel(
          update(
            latestPublishAt: now
                .subtract(const Duration(days: 75))
                .millisecondsSinceEpoch,
          ),
          now: now,
        ),
        '2 个月前',
      );
    });

    test('falls back to a dash without usable data', () {
      expect(favoriteUpUpdateLabel(null, now: now), '—');
      expect(favoriteUpUpdateLabel(update(), now: now), '—');
      expect(
        favoriteUpUpdateLabel(
          update(latestPublishAt: fetchedAt, failed: true),
          now: now,
        ),
        '—',
      );
    });
  });

  group('filterFavoriteUps', () {
    test('all keeps the favorited order', () {
      final List<FavoriteUp> ups = <FavoriteUp>[
        up(1, name: 'A', favoritedAtEpochMs: 300),
        up(2, name: 'B', favoritedAtEpochMs: 200),
        up(3, name: 'C', favoritedAtEpochMs: 100),
      ];

      final List<FavoriteUp> result = filterFavoriteUps(
        ups: ups,
        filter: FavoriteUpFilter.all,
        updates: <int, FavoriteUpUpdate>{2: update(mid: 2, todayVideoCount: 1)},
        playedMsByAuthor: <String, int>{'C': 999},
        now: now,
      );

      expect(result.map((FavoriteUp item) => item.mid), <int>[1, 2, 3]);
    });

    test('today keeps only ups updated today', () {
      final List<FavoriteUp> ups = <FavoriteUp>[
        up(1, name: 'A', favoritedAtEpochMs: 300),
        up(2, name: 'B', favoritedAtEpochMs: 200),
        up(3, name: 'C', favoritedAtEpochMs: 100),
      ];

      final List<FavoriteUp> result = filterFavoriteUps(
        ups: ups,
        filter: FavoriteUpFilter.today,
        updates: <int, FavoriteUpUpdate>{
          1: update(mid: 1, todayVideoCount: 2),
          2: update(
            mid: 2,
            todayVideoCount: 1,
            fetchedAtEpochMs: now
                .subtract(const Duration(days: 2))
                .millisecondsSinceEpoch,
          ),
        },
        playedMsByAuthor: <String, int>{},
        now: now,
      );

      expect(result.map((FavoriteUp item) => item.mid), <int>[1]);
    });

    test('mostListened sorts by played time and keeps unmatched ups last', () {
      final List<FavoriteUp> ups = <FavoriteUp>[
        up(1, name: ' A ', favoritedAtEpochMs: 300),
        up(2, name: 'B', favoritedAtEpochMs: 200),
        up(3, name: 'C', favoritedAtEpochMs: 100),
        up(4, name: 'D', favoritedAtEpochMs: 400),
      ];

      final List<FavoriteUp> result = filterFavoriteUps(
        ups: ups,
        filter: FavoriteUpFilter.mostListened,
        updates: <int, FavoriteUpUpdate>{},
        playedMsByAuthor: <String, int>{'A': 5000, 'B': 20000},
        now: now,
      );

      expect(result.map((FavoriteUp item) => item.mid), <int>[2, 1, 4, 3]);
    });
  });

  group('FavoriteUpGrid', () {
    testWidgets('renders one tile per up with its update label', (
      WidgetTester tester,
    ) async {
      FavoriteUp? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteUpGrid(
              ups: <FavoriteUp>[
                up(1, name: 'UP甲', favoritedAtEpochMs: 200),
                up(2, name: 'UP乙', favoritedAtEpochMs: 100),
              ],
              updates: <int, FavoriteUpUpdate>{
                1: update(
                  mid: 1,
                  latestPublishAt: now
                      .subtract(const Duration(days: 1))
                      .millisecondsSinceEpoch,
                ),
              },
              onTap: (FavoriteUp value) => tapped = value,
              onLongPress: (FavoriteUp value) {},
              now: now,
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteUpGridTile), findsNWidgets(2));
      expect(find.text('UP甲'), findsOneWidget);
      expect(find.text('UP乙'), findsOneWidget);
      expect(find.text('昨天更新'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('UP甲'));

      expect(tapped?.mid, 1);
    });

    testWidgets('tile shows the avatar fallback, name and update label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 148,
                child: FavoriteUpGridTile(
                  up: up(7, name: '收藏的 UP 主', favoritedAtEpochMs: 100),
                  update: update(
                    mid: 7,
                    latestPublishAt: now
                        .subtract(const Duration(days: 1))
                        .millisecondsSinceEpoch,
                  ),
                  now: now,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.text('收藏的 UP 主'), findsOneWidget);
      expect(find.text('昨天更新'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('filter chip labels match the design copy', () {
    expect(FavoriteUpFilter.all.label, '全部');
    expect(FavoriteUpFilter.today.label, '今日更新');
    expect(FavoriteUpFilter.mostListened.label, '常听');
  });
}
