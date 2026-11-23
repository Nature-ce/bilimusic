import 'package:bilimusic/feature/favorites/ui/components/favorite_like_button.dart';
import 'package:flutter/material.dart';

class PlayerTrackHeader extends StatelessWidget {
  const PlayerTrackHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isFavoriteEnabled,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.onSubtitleTap,
  });

  final String title;
  final String subtitle;
  final bool isFavoriteEnabled;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onSubtitleTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onSubtitleTap,
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FavoriteLikeIconButton(
          isLiked: isFavorite,
          isEnabled: isFavoriteEnabled,
          onPressed: onFavoriteToggle,
        ),
      ],
    );
  }
}

class PlayerBadge extends StatelessWidget {
  const PlayerBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
