import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';

String resolveDownloadTitle(String rawTitle) {
  final String title = normalizeDisplayTextOrEmpty(rawTitle);
  return title.isEmpty ? '未命名歌曲' : title;
}

class DownloadListRow extends StatelessWidget {
  const DownloadListRow({
    super.key,
    required this.coverUrl,
    required this.title,
    required this.subtitle,
    this.qualityLabel,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.highlighted = false,
    this.fallbackIcon = Icons.music_note_rounded,
    this.fallbackIconColor,
    this.subtitleColor,
  });

  final String coverUrl;
  final String title;
  final String subtitle;
  final String? qualityLabel;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool highlighted;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String label = qualityLabel?.trim() ?? '';
    final BorderRadius radius = BorderRadius.circular(AppRadius.md);

    return Material(
      color: highlighted
          ? colorScheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              CommonCachedImage(
                imageUrl: coverUrl,
                width: 52,
                height: 52,
                borderRadius: BorderRadius.circular(12),
                fallbackIcon: fallbackIcon,
                iconColor: fallbackIconColor ?? colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (label.isNotEmpty) ...<Widget>[
                          const SizedBox(width: 6),
                          _QualityLabelBadge(label: label),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor ?? colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityLabelBadge extends StatelessWidget {
  const _QualityLabelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
