import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/profile/ui/components/profile_card_surface.dart';
import 'package:flutter/material.dart';

class ProfilePlaylistCard extends StatelessWidget {
  const ProfilePlaylistCard({
    super.key,
    required this.title,
    required this.trackCount,
    required this.coverUrl,
    required this.onTap,
    required this.onLongPressStart,
    required this.onMenuPressed,
    this.isRemote = false,
    this.badgeLabel,
    this.updatedAt,
  });

  final String title;
  final int trackCount;
  final String? coverUrl;
  final VoidCallback onTap;
  final ValueChanged<LongPressStartDetails> onLongPressStart;
  final ValueChanged<Offset> onMenuPressed;
  final bool isRemote;
  final String? badgeLabel;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String? updatedLabel = _relativeUpdatedLabel(
      updatedAt,
      DateTime.now(),
    );
    final bool showSourceBadge = isRemote || badgeLabel != null;

    return Material(
      color: appCardSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onLongPressStart: onLongPressStart,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProfilePlaylistCover(
                  coverUrl: coverUrl,
                  trackCount: trackCount,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              '$trackCount 首',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.meta(theme, fontSize: 11),
                            ),
                          ),
                          if (showSourceBadge) ...<Widget>[
                            const SizedBox(width: 4),
                            _PlaylistSourceBadge(
                              label: badgeLabel ?? 'B站',
                              colorScheme: colorScheme,
                            ),
                          ],
                        ],
                      ),
                      if (updatedLabel != null) ...<Widget>[
                        const SizedBox(height: 3),
                        Text(
                          updatedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.meta(theme, fontSize: 10.5),
                        ),
                      ],
                    ],
                  ),
                ),
                Builder(
                  builder: (BuildContext buttonContext) {
                    return Tooltip(
                      message: '歌单设置',
                      child: InkResponse(
                        radius: 16,
                        onTap: () {
                          final RenderBox? box =
                              buttonContext.findRenderObject() as RenderBox?;
                          if (box == null) {
                            return;
                          }
                          onMenuPressed(
                            box.localToGlobal(box.size.center(Offset.zero)),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileCollectionGridCard extends StatelessWidget {
  const ProfileCollectionGridCard({
    super.key,
    required this.title,
    required this.trackCount,
    required this.coverUrl,
    required this.onTap,
    required this.onLongPressStart,
    required this.onMenuPressed,
    this.updatedAt,
  });

  final String title;
  final int trackCount;
  final String? coverUrl;
  final VoidCallback onTap;
  final ValueChanged<LongPressStartDetails> onLongPressStart;
  final ValueChanged<Offset> onMenuPressed;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String? updatedLabel = _relativeUpdatedLabel(
      updatedAt,
      DateTime.now(),
    );

    return ProfileCardSurface(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Row(
        children: <Widget>[
          _PlaylistGridCover(coverUrl: coverUrl, trackCount: trackCount),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (updatedLabel != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    updatedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta(theme, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Builder(
            builder: (BuildContext buttonContext) {
              return Tooltip(
                message: '歌单设置',
                child: InkResponse(
                  radius: 14,
                  onTap: () {
                    final RenderBox? box =
                        buttonContext.findRenderObject() as RenderBox?;
                    if (box == null) {
                      return;
                    }
                    onMenuPressed(
                      box.localToGlobal(box.size.center(Offset.zero)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlaylistGridCover extends StatelessWidget {
  const _PlaylistGridCover({required this.coverUrl, required this.trackCount});

  static const double _size = 64;
  static const double _radius = 14;

  final String? coverUrl;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CommonCachedImage(
              imageUrl: coverUrl,
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(_radius),
              placeholder: _PlaylistGridCoverFallback(primary: primary),
              errorWidget: _PlaylistGridCoverFallback(primary: primary),
            ),
          ),
          Positioned(
            right: 3,
            bottom: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$trackCount',
                style: const TextStyle(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistGridCoverFallback extends StatelessWidget {
  const _PlaylistGridCoverFallback({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_PlaylistGridCover._radius),
      ),
      child: Icon(Icons.queue_music_rounded, color: primary, size: 24),
    );
  }
}

String? _relativeUpdatedLabel(DateTime? updatedAt, DateTime now) {
  if (updatedAt == null) {
    return null;
  }
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime updatedDay = DateTime(
    updatedAt.year,
    updatedAt.month,
    updatedAt.day,
  );
  final int days = today.difference(updatedDay).inDays;
  if (days <= 0) {
    return '今天更新';
  }
  if (days == 1) {
    return '昨天更新';
  }
  if (days < 7) {
    return '$days 天前';
  }
  return '${days ~/ 7} 周前';
}

class _ProfilePlaylistCover extends StatelessWidget {
  const _ProfilePlaylistCover({
    required this.coverUrl,
    required this.trackCount,
  });

  final String? coverUrl;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CommonCachedImage(
              imageUrl: coverUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(10),
              placeholder: _PlaylistCoverFallback(primary: primary),
              errorWidget: _PlaylistCoverFallback(primary: primary),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$trackCount',
                style: const TextStyle(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCoverFallback extends StatelessWidget {
  const _PlaylistCoverFallback({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.queue_music_rounded, color: primary, size: 20),
    );
  }
}

class _PlaylistSourceBadge extends StatelessWidget {
  const _PlaylistSourceBadge({required this.label, required this.colorScheme});

  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.sync_rounded, size: 9, color: colorScheme.primary),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              height: 1.3,
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
