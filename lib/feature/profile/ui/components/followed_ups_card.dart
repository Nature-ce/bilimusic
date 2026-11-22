import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:flutter/material.dart';

class FollowedUpsCard extends StatelessWidget {
  const FollowedUpsCard({super.key, required this.ups, required this.onTap});

  static const int _previewCount = 3;
  static const double _avatarSize = 24;
  static const double _avatarOverlap = 13;

  final List<FavoriteUp> ups;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<FavoriteUp> preview = ups
        .take(_previewCount)
        .toList(growable: false);
    final double stackWidth = preview.isEmpty
        ? _avatarSize
        : _avatarSize + (preview.length - 1) * _avatarOverlap;

    return Material(
      color: appCardSurfaceColor(context),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: stackWidth,
                height: _avatarSize,
                child: preview.isEmpty
                    ? _FollowedUpPlaceholder(colorScheme: colorScheme)
                    : Stack(
                        children: <Widget>[
                          for (
                            int index = 0;
                            index < preview.length;
                            index += 1
                          )
                            Positioned(
                              left: index * _avatarOverlap,
                              child: _FollowedUpAvatar(
                                avatarUrl: preview[index].avatarUrl,
                                colorScheme: colorScheme,
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '关注的 UP 主',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${ups.length} 位 · 查看 / 管理',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.meta(theme, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowedUpAvatar extends StatelessWidget {
  const _FollowedUpAvatar({required this.avatarUrl, required this.colorScheme});

  final String avatarUrl;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appCardSurfaceColor(context),
      ),
      child: CommonCachedAvatar(
        imageUrl: avatarUrl,
        size: FollowedUpsCard._avatarSize - 3,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
        fallbackIcon: Icons.person_rounded,
        iconColor: colorScheme.primary,
        iconSize: 12,
      ),
    );
  }
}

class _FollowedUpPlaceholder extends StatelessWidget {
  const _FollowedUpPlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.12),
      ),
      child: Icon(Icons.person_rounded, size: 14, color: colorScheme.primary),
    );
  }
}
