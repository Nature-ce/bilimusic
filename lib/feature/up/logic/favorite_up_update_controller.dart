import 'dart:async';

import 'package:bilimusic/feature/up/data/bili_up_repository.dart';
import 'package:bilimusic/feature/up/data/favorite_up_update_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:bilimusic/feature/up/logic/up_page_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_update_controller.g.dart';

const Duration favoriteUpUpdateFreshTtl = Duration(minutes: 30);
const Duration favoriteUpUpdateFailureTtl = Duration(minutes: 10);

@Riverpod(keepAlive: true)
class FavoriteUpUpdateController extends _$FavoriteUpUpdateController {
  static const int maxConcurrentFetches = 4;

  late final FavoriteUpUpdateRepository _repository = ref.read(
    favoriteUpUpdateRepositoryProvider,
  );
  late final BiliUpRepository _biliUpRepository = ref.read(
    biliUpRepositoryProvider,
  );

  int _generation = 0;
  final Set<int> _inFlightMids = <int>{};

  @override
  Map<int, FavoriteUpUpdate> build() {
    ref.onDispose(() => _generation += 1);
    return _loadCache();
  }

  Future<void> ensureFresh(List<FavoriteUp> ups) async {
    final int generation = _generation;
    final DateTime now = DateTime.now();
    final List<FavoriteUp> pending = ups
        .where((FavoriteUp up) => _needsFetch(up.mid, now))
        .toList(growable: false);
    for (int start = 0; start < pending.length; start += maxConcurrentFetches) {
      if (!_isActive(generation)) {
        return;
      }
      final int end = start + maxConcurrentFetches;
      final List<FavoriteUp> batch = pending.sublist(
        start,
        end > pending.length ? pending.length : end,
      );
      await Future.wait(
        batch.map((FavoriteUp up) => _fetchOne(up.mid, generation)),
      );
    }
  }

  Map<int, FavoriteUpUpdate> _loadCache() {
    try {
      return _repository.load();
    } on Object {
      return <int, FavoriteUpUpdate>{};
    }
  }

  bool _needsFetch(int mid, DateTime now) {
    if (_inFlightMids.contains(mid)) {
      return false;
    }
    final FavoriteUpUpdate? update = state[mid];
    if (update == null) {
      return true;
    }
    final int ageMs = now.millisecondsSinceEpoch - update.fetchedAtEpochMs;
    final Duration ttl = update.failed
        ? favoriteUpUpdateFailureTtl
        : favoriteUpUpdateFreshTtl;
    return ageMs >= ttl.inMilliseconds;
  }

  Future<void> _fetchOne(int mid, int generation) async {
    if (!_inFlightMids.add(mid)) {
      return;
    }
    final int fetchedAtEpochMs = DateTime.now().millisecondsSinceEpoch;
    try {
      final List<DateTime> publishTimes = await _biliUpRepository
          .fetchLatestPublishTimes(mid: mid);
      if (!_isActive(generation)) {
        return;
      }
      _apply(
        FavoriteUpUpdate(
          mid: mid,
          fetchedAtEpochMs: fetchedAtEpochMs,
          latestPublishAtEpochMs: publishTimes.isEmpty
              ? null
              : publishTimes.first.millisecondsSinceEpoch,
          todayVideoCount: _countToday(publishTimes),
        ),
      );
    } on Object {
      if (!_isActive(generation)) {
        return;
      }
      final FavoriteUpUpdate? previous = state[mid];
      _apply(
        FavoriteUpUpdate(
          mid: mid,
          fetchedAtEpochMs: fetchedAtEpochMs,
          latestPublishAtEpochMs: previous?.latestPublishAtEpochMs,
          todayVideoCount: previous?.todayVideoCount ?? 0,
          failed: true,
        ),
      );
    } finally {
      _inFlightMids.remove(mid);
    }
  }

  void _apply(FavoriteUpUpdate update) {
    if (!ref.mounted) {
      return;
    }
    state = <int, FavoriteUpUpdate>{...state, update.mid: update};
    unawaited(_persist(update));
  }

  Future<void> _persist(FavoriteUpUpdate update) async {
    try {
      await _repository.save(update);
    } on Object {
      return;
    }
  }

  int _countToday(List<DateTime> publishTimes) {
    final DateTime now = DateTime.now();
    int count = 0;
    for (final DateTime publishedAt in publishTimes) {
      if (publishedAt.year == now.year &&
          publishedAt.month == now.month &&
          publishedAt.day == now.day) {
        count += 1;
      }
    }
    return count;
  }

  bool _isActive(int generation) {
    return ref.mounted && generation == _generation;
  }
}
