import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/ui/components/download_list_row.dart';
import 'package:flutter/material.dart';

class DownloadedTrackTile extends StatelessWidget {
  const DownloadedTrackTile({
    super.key,
    required this.track,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onToggleSelection,
    this.onLongPress,
  });

  final DownloadedTrack track;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelection;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final Widget? trailing = selectionMode
        ? Checkbox(
            value: selected,
            visualDensity: VisualDensity.compact,
            onChanged: (bool? _) => onToggleSelection(),
          )
        : null;

    return DownloadListRow(
      coverUrl: track.coverUrl,
      title: resolveDownloadTitle(track.title),
      qualityLabel: track.qualityLabel,
      subtitle: '${formatBytes(track.byteLength)} · 已完成',
      trailing: trailing,
      highlighted: selectionMode && selected,
      onTap: onTap,
      onLongPress: selectionMode ? null : onLongPress,
    );
  }
}
