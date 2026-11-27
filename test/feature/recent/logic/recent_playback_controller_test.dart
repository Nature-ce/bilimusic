import 'dart:async';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/data/recent_playback_local_repository.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  title: '晴天',
  author: '周杰伦',
  coverUrl: '',
);

void main() {
  test('provider 在 await 期间被销毁后，recordItem 不再抛异常', () async {
    final _GatedRepository repository = _GatedRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        recentPlaybackLocalRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final RecentPlaybackController controller = container.read(
      recentPlaybackControllerProvider.notifier,
    );

    final Future<void> pending = controller.recordItem(_item);
    container.dispose();
    repository.release();

    await expectLater(pending, completes);
  });

  test('provider 存活时正常写回 state', () async {
    final _GatedRepository repository = _GatedRepository()..release();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        recentPlaybackLocalRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final RecentPlaybackController controller = container.read(
      recentPlaybackControllerProvider.notifier,
    );

    await controller.recordItem(_item);

    expect(
      container.read(recentPlaybackControllerProvider).single.stableId,
      _item.stableId,
    );
  });
}

class _GatedRepository implements RecentPlaybackLocalRepository {
  final Completer<void> _gate = Completer<void>();

  void release() {
    if (!_gate.isCompleted) {
      _gate.complete();
    }
  }

  @override
  List<RecentPlaybackEntry> load() => const <RecentPlaybackEntry>[];

  @override
  Future<List<RecentPlaybackEntry>> saveEntry(RecentPlaybackEntry entry) async {
    await _gate.future;
    return <RecentPlaybackEntry>[entry];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
