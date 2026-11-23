import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_grouping.dart';
import 'package:flutter/material.dart';

class RecentPlaybackEntryTile extends StatelessWidget {
  const RecentPlaybackEntryTile({
    super.key,
    required this.entry,
    required this.progressMs,
    required this.onTap,
    this.onLongPress,
  });

  static const double _coverSize = 52;
  static const double _coverRadius = 12;

  final RecentPlaybackEntry entry;
  final int? progressMs;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String title = normalizeDisplayTextOrEmpty(entry.title);
    final String author = normalizeDisplayTextOrEmpty(entry.author);
    final int? listenedMs = progressMs != null && progressMs! > 0
        ? progressMs
        : null;
    final List<String> subtitleSegments = <String>[
      if (author.isNotEmpty) author,
      recentPlaybackTimeLabel(entry.playedAtEpochMs),
    ];

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            CommonCachedImage(
              imageUrl: entry.coverUrl,
              width: _coverSize,
              height: _coverSize,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(_coverRadius),
              fallbackIcon: Icons.music_note_rounded,
              iconColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title.isEmpty ? '未命名内容' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs - 1),
                  Text(
                    subtitleSegments.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (listenedMs != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Text(
                '已听 ${_formatListened(listenedMs)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatListened(int positionMs) {
    final Duration position = Duration(milliseconds: positionMs);
    final int minutes = position.inMinutes;
    final int seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
