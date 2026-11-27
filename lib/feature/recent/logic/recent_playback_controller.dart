import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/data/recent_playback_local_repository.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_playback_controller.g.dart';

@riverpod
class RecentPlaybackController extends _$RecentPlaybackController {
  late final RecentPlaybackLocalRepository _repository = ref.read(
    recentPlaybackLocalRepositoryProvider,
  );

  @override
  List<RecentPlaybackEntry> build() {
    return _repository.load();
  }

  Future<void> recordItem(PlayableItem item) async {
    final RecentPlaybackEntry entry = RecentPlaybackEntry.fromPlayableItem(
      item,
      playedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    final List<RecentPlaybackEntry> nextEntries = await _repository.saveEntry(
      entry,
    );
    _applyEntries(nextEntries);
  }

  Future<void> removeEntry(String stableId) async {
    final List<RecentPlaybackEntry> nextEntries = await _repository.removeEntry(
      stableId,
    );
    _applyEntries(nextEntries);
  }

  Future<void> clear() async {
    await _repository.clearAll();
    _applyEntries(const <RecentPlaybackEntry>[]);
  }

  /// 写 state 前确认 provider 还活着。
  ///
  /// 这是个 autoDispose provider：快速切页时它会在「await 仓储」期间被回收，
  /// 此时直接写 state 会抛 `Cannot use the Ref ... after it has been disposed`。
  void _applyEntries(List<RecentPlaybackEntry> entries) {
    if (!ref.mounted) {
      return;
    }
    state = entries;
  }
}
