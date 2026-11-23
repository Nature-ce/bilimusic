import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/download/ui/components/download_filter_bar.dart';
import 'package:bilimusic/feature/download/ui/components/download_list_row.dart';
import 'package:bilimusic/feature/download/ui/components/download_summary_card.dart';
import 'package:bilimusic/feature/download/ui/components/download_task_tile.dart';
import 'package:bilimusic/feature/download/ui/components/downloaded_track_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  static const String _sourceLabel = '离线下载';

  DownloadFilter _filter = DownloadFilter.all;
  bool _manageMode = false;
  final Set<String> _selectedContentIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final DownloadState state = ref.watch(downloadControllerProvider);
    final List<DownloadedTrack> tracks = state.tracks;
    final bool hasContent = tracks.isNotEmpty || state.tasks.isNotEmpty;
    final List<DownloadedTrack> selectedTracks = _selectedTracks(tracks);

    return PopScope(
      canPop: !_manageMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !_manageMode) {
          return;
        }
        _exitManageMode();
      },
      child: Scaffold(
        appBar: PageAppBar(
          title: const Text('下载'),
          actions: <Widget>[
            if (_manageMode)
              TextButton(onPressed: _exitManageMode, child: const Text('完成'))
            else if (tracks.isNotEmpty)
              TextButton(onPressed: _enterManageMode, child: const Text('管理')),
            const SizedBox(width: 8),
          ],
        ),
        body: hasContent
            ? _buildBody(state)
            : const StatusView(
                icon: Icons.download_done_rounded,
                title: '还没有下载内容',
                description: '去播放器里点下载，离线也能随时听',
              ),
        bottomNavigationBar: _manageMode
            ? _buildManageBar(tracks, selectedTracks)
            : null,
      ),
    );
  }

  Widget _buildBody(DownloadState state) {
    final List<DownloadedTrack> tracks = state.tracks;
    final List<DownloadTask> activeTasks = state.activeTasks;
    final List<DownloadTask> visibleTasks = _manageMode
        ? const <DownloadTask>[]
        : _visibleTasks(state);
    final List<DownloadedTrack> visibleTracks = _manageMode
        ? tracks
        : _visibleTracks(tracks);
    final Map<String, int> queuePositions = <String, int>{
      for (int index = 0; index < activeTasks.length; index += 1)
        activeTasks[index].contentId: index + 1,
    };
    final bool filterEmpty = visibleTasks.isEmpty && visibleTracks.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      children: <Widget>[
        DownloadSummaryCard(
          trackCount: tracks.length,
          totalBytes: state.totalBytes,
          qualityLabel: _topQualityLabel(tracks),
          onPlayAll: tracks.isEmpty || _manageMode
              ? null
              : () => _playAll(state),
        ),
        if (!_manageMode) ...<Widget>[
          const SizedBox(height: 14),
          DownloadFilterBar(selected: _filter, onSelected: _selectFilter),
        ],
        const SizedBox(height: 8),
        if (filterEmpty)
          _buildFilterEmpty()
        else ...<Widget>[
          for (final DownloadTask task in visibleTasks)
            DownloadTaskTile(
              task: task,
              queuePosition: queuePositions[task.contentId] ?? 0,
              activeCount: activeTasks.length,
              onRetry: () => _retryTask(task),
              onDismiss: () => _dismissTask(task),
            ),
          for (final DownloadedTrack track in visibleTracks)
            DownloadedTrackTile(
              track: track,
              selectionMode: _manageMode,
              selected: _selectedContentIds.contains(track.contentId),
              onTap: () => _handleTrackTap(track, state),
              onToggleSelection: () => _toggleSelection(track.contentId),
              onLongPress: _manageMode
                  ? null
                  : () => _confirmDeleteTrack(track),
            ),
        ],
        const BottomPageSpacer(),
      ],
    );
  }

  Widget _buildFilterEmpty() {
    final String label = switch (_filter) {
      DownloadFilter.all => '暂无下载内容',
      DownloadFilter.downloading => '没有正在下载的歌曲',
      DownloadFilter.completed => '还没有已完成的下载',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          _manageMode ? '还没有已下载的歌曲' : label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildManageBar(
    List<DownloadedTrack> tracks,
    List<DownloadedTrack> selectedTracks,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 16, 10),
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: tracks.isEmpty ? null : () => _toggleSelectAll(tracks),
              child: Text(_allSelected(tracks) ? '取消全选' : '全选'),
            ),
            const Spacer(),
            Text(
              '已选 ${selectedTracks.length} 项',
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: selectedTracks.isEmpty
                  ? null
                  : () => _deleteSelected(tracks),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('删除所选'),
            ),
          ],
        ),
      ),
    );
  }

  List<DownloadTask> _visibleTasks(DownloadState state) {
    return switch (_filter) {
      DownloadFilter.completed => const <DownloadTask>[],
      DownloadFilter.all => <DownloadTask>[
        ...state.activeTasks,
        ...state.failedTasks,
      ],
      DownloadFilter.downloading => state.activeTasks,
    };
  }

  List<DownloadedTrack> _visibleTracks(List<DownloadedTrack> tracks) {
    return switch (_filter) {
      DownloadFilter.downloading => const <DownloadedTrack>[],
      DownloadFilter.all || DownloadFilter.completed => tracks,
    };
  }

  String? _topQualityLabel(List<DownloadedTrack> tracks) {
    String? bestLabel;
    int bestBandwidth = -1;
    for (final DownloadedTrack track in tracks) {
      final String label = track.qualityLabel?.trim() ?? '';
      if (label.isEmpty) {
        continue;
      }
      final int bandwidth = track.bandwidth ?? 0;
      if (bestLabel == null || bandwidth > bestBandwidth) {
        bestLabel = label;
        bestBandwidth = bandwidth;
      }
    }
    return bestLabel;
  }

  List<DownloadedTrack> _selectedTracks(List<DownloadedTrack> tracks) {
    return tracks
        .where(
          (DownloadedTrack track) =>
              _selectedContentIds.contains(track.contentId),
        )
        .toList(growable: false);
  }

  bool _allSelected(List<DownloadedTrack> tracks) {
    return tracks.isNotEmpty &&
        tracks.every(
          (DownloadedTrack track) =>
              _selectedContentIds.contains(track.contentId),
        );
  }

  void _selectFilter(DownloadFilter filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _enterManageMode() {
    setState(() {
      _manageMode = true;
      _selectedContentIds.clear();
    });
  }

  void _exitManageMode() {
    setState(() {
      _manageMode = false;
      _selectedContentIds.clear();
    });
  }

  void _toggleSelection(String contentId) {
    setState(() {
      if (!_selectedContentIds.remove(contentId)) {
        _selectedContentIds.add(contentId);
      }
    });
  }

  void _toggleSelectAll(List<DownloadedTrack> tracks) {
    setState(() {
      if (_allSelected(tracks)) {
        _selectedContentIds.clear();
      } else {
        _selectedContentIds
          ..clear()
          ..addAll(tracks.map((DownloadedTrack track) => track.contentId));
      }
    });
  }

  Future<void> _handleTrackTap(
    DownloadedTrack track,
    DownloadState state,
  ) async {
    if (_manageMode) {
      _toggleSelection(track.contentId);
      return;
    }
    final int index = state.tracks.indexWhere(
      (DownloadedTrack item) => item.contentId == track.contentId,
    );
    if (index < 0) {
      return;
    }
    await _playQueue(state.tracks, index);
  }

  Future<void> _playAll(DownloadState state) {
    if (state.tracks.isEmpty) {
      return Future<void>.value();
    }
    return _playQueue(state.tracks, 0);
  }

  Future<void> _playQueue(List<DownloadedTrack> tracks, int startIndex) {
    final List<PlayableItem> items = tracks
        .map((DownloadedTrack track) => track.toPlayableItem())
        .toList(growable: false);
    return PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: items,
      startIndex: startIndex,
      sourceLabel: _sourceLabel,
    );
  }

  Future<void> _retryTask(DownloadTask task) async {
    final bool retried = await ref
        .read(downloadControllerProvider.notifier)
        .retry(task.contentId);
    if (!mounted) {
      return;
    }
    ToastUtil.show(retried ? '已重新加入下载队列' : '无法重试，请重新下载');
  }

  void _dismissTask(DownloadTask task) {
    ref.read(downloadControllerProvider.notifier).dismissTask(task.contentId);
    ToastUtil.show('已移除下载任务');
  }

  Future<void> _confirmDeleteTrack(DownloadedTrack track) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('删除下载'),
          content: Text('将删除本地文件《${resolveDownloadTitle(track.title)}》，确认继续？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await _deleteTrack(track);
  }

  Future<void> _deleteTrack(DownloadedTrack track) async {
    await ref.read(downloadControllerProvider.notifier).removeTrack(track);
    if (!mounted) {
      return;
    }
    ToastUtil.show('已删除下载');
  }

  Future<void> _deleteSelected(List<DownloadedTrack> tracks) async {
    final List<DownloadedTrack> selectedTracks = _selectedTracks(tracks);
    if (selectedTracks.isEmpty) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('删除所选'),
          content: Text('将删除选中的 ${selectedTracks.length} 首本地文件，确认继续？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final DownloadController controller = ref.read(
      downloadControllerProvider.notifier,
    );
    for (final DownloadedTrack track in selectedTracks) {
      await controller.removeTrack(track);
    }
    if (!mounted) {
      return;
    }
    _exitManageMode();
    ToastUtil.show('已删除 ${selectedTracks.length} 首下载');
  }
}
