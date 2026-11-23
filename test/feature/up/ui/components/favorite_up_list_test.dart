import 'dart:io';

import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_update_controller.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_grid.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

class _FakeFavoriteUpUpdateController extends FavoriteUpUpdateController {
  _FakeFavoriteUpUpdateController(this._updates);

  final Map<int, FavoriteUpUpdate> _updates;

  @override
  Map<int, FavoriteUpUpdate> build() {
    return _updates;
  }

  @override
  Future<void> ensureFresh(List<FavoriteUp> ups) async {}
}

void main() {
  late Directory directory;
  late Box<Map> statisticsBox;
  late StatisticsLocalRepository statisticsRepository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('favorite_up_list_test');
    Hive.init(directory.path);
    statisticsBox = await Hive.openBox<Map>(songStatisticsBoxName);
    statisticsRepository = StatisticsLocalRepository(statisticsBox);
    await statisticsRepository.write(
      const SongStatistics(
        stableId: 'bvid:BV1',
        author: 'UP甲',
        totalPlayedMs: 1000,
      ),
    );
    await statisticsRepository.write(
      const SongStatistics(
        stableId: 'bvid:BV2',
        author: 'UP乙',
        totalPlayedMs: 5000,
      ),
    );
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  FavoriteUp up(int mid, String name) {
    return FavoriteUp(
      mid: mid,
      name: name,
      avatarUrl: '',
      favoritedAtEpochMs: 1000 - mid,
      updatedAtEpochMs: 1000 - mid,
    );
  }

  Future<void> pumpList(
    WidgetTester tester, {
    required List<FavoriteUp> ups,
    required Map<int, FavoriteUpUpdate> updates,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteUpControllerProvider.overrideWithValue(ups),
          favoriteUpUpdateControllerProvider.overrideWith(
            () => _FakeFavoriteUpUpdateController(updates),
          ),
          statisticsLocalRepositoryProvider.overrideWithValue(
            statisticsRepository,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: FavoriteUpList())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('falls back to the empty state without favorites', (
    WidgetTester tester,
  ) async {
    await pumpList(
      tester,
      ups: const <FavoriteUp>[],
      updates: const <int, FavoriteUpUpdate>{},
    );

    expect(find.text('还没有收藏UP主'), findsOneWidget);
    expect(find.byType(FavoriteUpGrid), findsNothing);
  });

  testWidgets('renders chips, grid and filters today updates', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.now();
    final List<FavoriteUp> ups = <FavoriteUp>[up(1, 'UP甲'), up(2, 'UP乙')];
    final Map<int, FavoriteUpUpdate> updates = <int, FavoriteUpUpdate>{
      1: FavoriteUpUpdate(
        mid: 1,
        fetchedAtEpochMs: now.millisecondsSinceEpoch,
        todayVideoCount: 2,
      ),
    };

    await pumpList(tester, ups: ups, updates: updates);

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('今日更新'), findsOneWidget);
    expect(find.text('常听'), findsOneWidget);
    expect(find.byType(FavoriteUpGridTile), findsNWidgets(2));
    expect(find.text('今日 2 首更新'), findsOneWidget);

    await tester.tap(find.text('今日更新'));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteUpGridTile), findsOneWidget);
    expect(find.text('UP甲'), findsOneWidget);
    expect(find.text('UP乙'), findsNothing);

    await tester.tap(find.text('全部'));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteUpGridTile), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the today empty copy when nothing was updated', (
    WidgetTester tester,
  ) async {
    await pumpList(
      tester,
      ups: <FavoriteUp>[up(1, 'UP甲')],
      updates: const <int, FavoriteUpUpdate>{},
    );

    await tester.tap(find.text('今日更新'));
    await tester.pumpAndSettle();

    expect(find.text('今天还没有关注的 UP 主更新'), findsOneWidget);
    expect(find.byType(FavoriteUpGrid), findsNothing);
  });

  testWidgets('orders the most listened ups by local played time', (
    WidgetTester tester,
  ) async {
    await pumpList(
      tester,
      ups: <FavoriteUp>[up(1, 'UP甲'), up(2, 'UP乙')],
      updates: const <int, FavoriteUpUpdate>{},
    );

    await tester.tap(find.text('常听'));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteUpGridTile), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('UP乙')).dx,
      lessThan(tester.getTopLeft(find.text('UP甲')).dx),
    );
  });
}
