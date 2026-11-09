import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  bool _selectionMode = false;
  final Set<String> _selectedContentIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final DownloadState state = ref.watch(downloadControllerProvider);
    final ThemeData theme = Theme.of(context);
    final List<DownloadTask> activeTasks = state.activeTasks;
    final List<DownloadTask> failedTasks = state.failedTasks;
    final List<DownloadedTrack> tracks = state.tracks;
    final bool hasContent = tracks.isNotEmpty || state.tasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('离线下载'),
        actions: <Widget>[
          if (!_selectionMode && tracks.isNotEmpty)
            IconButton(
              tooltip: '批量管理',
              onPressed: () {
                setState(() {
                  _selectionMode = true;
                  _selectedContentIds.clear();
                });
              },
              icon: const Icon(Icons.checklist_rounded),
            ),
          if (_selectionMode)
            IconButton(
              tooltip: _allSelected(tracks) ? '取消全选' : '全选',
              onPressed: () => _toggleSelectAll(tracks),
              icon: Icon(
                _allSelected(tracks)
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded,
              ),
            ),
          if (!_selectionMode && tracks.isNotEmpty)
            IconButton(
              tooltip: '清空下载',
              onPressed: () => _confirmClearAll(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: !hasContent
          ? const StatusView(
              icon: Icons.download_done_rounded,
              title: '还没有下载的歌曲',
              description: '在播放器菜单、收藏列表或分P/时间轴面板中可以下载歌曲',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                _DownloadSummary(
                  trackCount: tracks.length,
                  totalBytes: state.totalBytes,
                  activeCount: activeTasks.length,
                  failedCount: failedTasks.length,
                ),
                for (final DownloadTask task in activeTasks)
                  _DownloadingTile(task: task),
                for (final DownloadTask task in failedTasks)
                  _FailedTaskTile(
                    task: task,
                    onRetry: () => _retryTask(context, ref, task),
                    onDismiss: () => ref
                        .read(downloadControllerProvider.notifier)
                        .dismissTask(task.contentId),
                  ),
                for (int index = 0; index < tracks.length; index += 1)
                  _DownloadedTrackTile(
                    track: tracks[index],
                    selectionMode: _selectionMode,
                    selected: _selectedContentIds.contains(
                      tracks[index].contentId,
                    ),
                    onTap: () => _handleTrackTap(context, ref, state, index),
                    onToggleSelection: () =>
                        _toggleSelection(tracks[index].contentId),
                    onDelete: () => _deleteTrack(context, ref, tracks[index]),
                  ),
              ],
            ),
      bottomNavigationBar: _selectionMode
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: <Widget>[
                    Text(
                      '已选 ${_selectedContentIds.length} 项',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectionMode = false;
                          _selectedContentIds.clear();
                        });
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: _selectedContentIds.isEmpty
                          ? null
                          : () => _deleteSelected(context, ref, state),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('删除'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  bool _allSelected(List<DownloadedTrack> tracks) {
    return tracks.isNotEmpty &&
        tracks.every(
          (DownloadedTrack track) =>
              _selectedContentIds.contains(track.contentId),
        );
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

  void _toggleSelection(String contentId) {
    setState(() {
      if (!_selectedContentIds.remove(contentId)) {
        _selectedContentIds.add(contentId);
      }
    });
  }

  Future<void> _handleTrackTap(
    BuildContext context,
    WidgetRef ref,
    DownloadState state,
    int index,
  ) async {
    final DownloadedTrack track = state.tracks[index];
    if (_selectionMode) {
      _toggleSelection(track.contentId);
      return;
    }
    await _playFrom(context, ref, state, index);
  }

  Future<void> _retryTask(
    BuildContext context,
    WidgetRef ref,
    DownloadTask task,
  ) async {
    final bool retried = await ref
        .read(downloadControllerProvider.notifier)
        .retry(task.contentId);
    if (!context.mounted) {
      return;
    }
    ToastUtil.show(retried ? '已重新加入下载队列' : '无法重试，请重新下载');
  }

  Future<void> _deleteSelected(
    BuildContext context,
    WidgetRef ref,
    DownloadState state,
  ) async {
    final List<DownloadedTrack> selectedTracks = state.tracks
        .where(
          (DownloadedTrack track) =>
              _selectedContentIds.contains(track.contentId),
        )
        .toList(growable: false);
    if (selectedTracks.isEmpty) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除下载'),
          content: Text('将删除选中的 ${selectedTracks.length} 首本地文件，确认继续？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final DownloadController controller = ref.read(
      downloadControllerProvider.notifier,
    );
    for (final DownloadedTrack track in selectedTracks) {
      await controller.removeTrack(track);
    }
    if (!context.mounted) {
      return;
    }
    setState(() {
      _selectionMode = false;
      _selectedContentIds.clear();
    });
    ToastUtil.show('已删除 ${selectedTracks.length} 首下载');
  }

  Future<void> _playFrom(
    BuildContext context,
    WidgetRef ref,
    DownloadState state,
    int index,
  ) async {
    final List<PlayableItem> items = state.tracks
        .map((DownloadedTrack track) => track.toPlayableItem())
        .toList(growable: false);
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: items,
      startIndex: index,
      sourceLabel: '离线下载',
    );
  }

  Future<void> _deleteTrack(
    BuildContext context,
    WidgetRef ref,
    DownloadedTrack track,
  ) async {
    await ref.read(downloadControllerProvider.notifier).removeTrack(track);
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已删除下载');
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清空下载'),
          content: const Text('将删除全部已下载的歌曲文件，确认继续？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('清空'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(downloadControllerProvider.notifier).clearAll();
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已清空下载');
  }
}

class _DownloadSummary extends StatelessWidget {
  const _DownloadSummary({
    required this.trackCount,
    required this.totalBytes,
    required this.activeCount,
    required this.failedCount,
  });

  final int trackCount;
  final int totalBytes;
  final int activeCount;
  final int failedCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> segments = <String>[
      '共 $trackCount 首',
      formatBytes(totalBytes),
      if (activeCount > 0) '$activeCount 项进行中',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.sd_storage_outlined,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              segments.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (failedCount > 0)
            Text(
              '$failedCount 项失败',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _DownloadingTile extends StatelessWidget {
  const _DownloadingTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double? progress = task.progress;
    final String statusLabel = switch (task.status) {
      DownloadTaskStatus.queued => '等待下载',
      DownloadTaskStatus.running =>
        progress == null
            ? '下载中'
            : '下载中 ${(progress * 100).toStringAsFixed(0)}%',
      DownloadTaskStatus.failed => '下载失败',
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CommonCachedImage(
        imageUrl: task.coverUrl,
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(10),
        fallbackIcon: Icons.downloading_rounded,
        iconColor: colorScheme.primary,
      ),
      title: Text(
        task.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 2),
          Text(
            task.author.trim().isEmpty
                ? statusLabel
                : '${task.author} · $statusLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

class _FailedTaskTile extends StatelessWidget {
  const _FailedTaskTile({
    required this.task,
    required this.onRetry,
    required this.onDismiss,
  });

  final DownloadTask task;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String errorMessage = task.errorMessage?.trim() ?? '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CommonCachedImage(
        imageUrl: task.coverUrl,
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(10),
        fallbackIcon: Icons.error_outline_rounded,
        iconColor: colorScheme.error,
      ),
      title: Text(
        task.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        errorMessage.isEmpty ? '下载失败' : '下载失败 · $errorMessage',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextButton(onPressed: onRetry, child: const Text('重试')),
          IconButton(
            tooltip: '移除',
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _DownloadedTrackTile extends StatelessWidget {
  const _DownloadedTrackTile({
    required this.track,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onToggleSelection,
    required this.onDelete,
  });

  final DownloadedTrack track;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelection;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> subtitleParts = <String>[
      if (track.author.trim().isNotEmpty) track.author,
      if (track.qualityLabel?.trim().isNotEmpty ?? false) track.qualityLabel!,
      formatBytes(track.byteLength),
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: selectionMode
          ? Checkbox(
              value: selected,
              onChanged: (bool? _) => onToggleSelection(),
            )
          : CommonCachedImage(
              imageUrl: track.coverUrl,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(10),
              fallbackIcon: Icons.music_note_rounded,
              iconColor: colorScheme.primary,
            ),
      title: Text(
        track.title.isEmpty ? '未命名歌曲' : track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitleParts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: selectionMode
          ? null
          : IconButton(
              tooltip: '删除下载',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            ),
      onTap: onTap,
    );
  }
}
