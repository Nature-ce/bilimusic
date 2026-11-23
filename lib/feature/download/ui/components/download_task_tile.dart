import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/ui/components/download_list_row.dart';
import 'package:flutter/material.dart';

class DownloadTaskTile extends StatelessWidget {
  const DownloadTaskTile({
    super.key,
    required this.task,
    required this.queuePosition,
    required this.activeCount,
    required this.onRetry,
    required this.onDismiss,
  });

  final DownloadTask task;
  final int queuePosition;
  final int activeCount;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool failed = task.isFailed;

    return DownloadListRow(
      coverUrl: task.coverUrl,
      title: resolveDownloadTitle(task.displayTitle),
      subtitle: _statusText(),
      subtitleColor: failed ? colorScheme.error : null,
      fallbackIcon: failed
          ? Icons.error_outline_rounded
          : Icons.downloading_rounded,
      fallbackIconColor: failed ? colorScheme.error : colorScheme.primary,
      trailing: IconButton(
        tooltip: failed ? '移除' : '取消下载',
        onPressed: onDismiss,
        visualDensity: VisualDensity.compact,
        color: colorScheme.onSurfaceVariant,
        icon: const Icon(Icons.close_rounded, size: 20),
      ),
      onTap: failed ? onRetry : null,
    );
  }

  String _statusText() {
    return switch (task.status) {
      DownloadTaskStatus.queued => _queueText(),
      DownloadTaskStatus.running => _runningText(),
      DownloadTaskStatus.failed => '下载失败 · 点击重试',
    };
  }

  String _queueText() {
    if (activeCount <= 0 || queuePosition <= 0) {
      return '排队中';
    }
    return '排队中 · $queuePosition/$activeCount';
  }

  String _runningText() {
    final double? progress = task.progress;
    if (progress == null || task.totalBytes <= 0) {
      return '下载中';
    }
    final int percent = (progress * 100).round();
    final String byteRange = _formatByteRange(
      task.receivedBytes,
      task.totalBytes,
    );
    return '下载中 · $percent% · $byteRange';
  }
}

String _formatByteRange(int receivedBytes, int totalBytes) {
  if (totalBytes <= 0) {
    return formatBytes(receivedBytes);
  }
  final String receivedLabel = formatBytes(receivedBytes);
  final String totalLabel = formatBytes(totalBytes);
  final int receivedSpace = receivedLabel.lastIndexOf(' ');
  final int totalSpace = totalLabel.lastIndexOf(' ');
  if (receivedSpace > 0 && totalSpace > 0) {
    final String receivedUnit = receivedLabel.substring(receivedSpace + 1);
    final String totalUnit = totalLabel.substring(totalSpace + 1);
    if (receivedUnit == totalUnit) {
      return '${receivedLabel.substring(0, receivedSpace)}/'
          '${totalLabel.substring(0, totalSpace)} $totalUnit';
    }
  }
  return '$receivedLabel/$totalLabel';
}
