import 'dart:async';

import 'package:bilimusic/feature/home/data/music_chart_repository.dart';
import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_chart_controller.g.dart';

@riverpod
MusicChartRepository musicChartRepository(Ref ref) {
  return MusicChartRepository();
}

/// 首页排行榜：三个平台各加载自己的默认榜单，供卡片与完整列表共用。
///
/// 之前一次只持有一个平台的榜单，首页只能竖着放一排平台 chip；
/// 现在卡片要同时显示 3 个平台的前三名，所以按平台分开缓存。
@Riverpod(keepAlive: true)
class MusicChartController extends _$MusicChartController {
  int _requestId = 0;

  @override
  MusicChartState build() {
    unawaited(Future<void>.microtask(refresh));
    return const MusicChartState();
  }

  Future<void> refresh() async {
    final int requestId = ++_requestId;
    await Future.wait(
      MusicChartPlatform.values.map(
        (MusicChartPlatform platform) => _loadPlatform(platform, requestId),
      ),
    );
  }

  Future<void> retry(MusicChartPlatform platform) {
    return _loadPlatform(platform, ++_requestId);
  }

  Future<void> _loadPlatform(
    MusicChartPlatform platform,
    int requestId, {
    MusicChart? chart,
  }) async {
    final MusicChart target =
        chart ??
        state.entryOf(platform)?.chart ??
        MusicChartCatalog.defaultChartOf(platform);
    _put(
      platform,
      (state.entryOf(platform) ?? MusicChartEntry(chart: target)).copyWith(
        chart: target,
        isLoading: true,
        errorMessage: null,
      ),
    );
    try {
      final List<MusicChartTrack> tracks = await ref
          .read(musicChartRepositoryProvider)
          .fetchTracks(target);
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      _put(
        platform,
        MusicChartEntry(
          chart: target,
          tracks: tracks,
          updatedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } on Object catch (error) {
      if (!ref.mounted || requestId != _requestId) {
        return;
      }
      _put(
        platform,
        MusicChartEntry(chart: target, errorMessage: error.toString()),
      );
    }
  }

  void _put(MusicChartPlatform platform, MusicChartEntry entry) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(
      entries: <MusicChartPlatform, MusicChartEntry>{
        ...state.entries,
        platform: entry,
      },
    );
  }
}
