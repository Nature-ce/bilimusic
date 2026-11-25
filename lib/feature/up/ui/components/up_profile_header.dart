import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_like_button.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:bilimusic/feature/up/data/favorite_up_local_repository.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpProfileHeader extends ConsumerWidget {
  const UpProfileHeader({super.key, required this.profile, this.error});

  final UpProfile? profile;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpProfile? value = profile;

    if (value == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          children: <Widget>[
            const CircleAvatar(radius: 34, child: Icon(Icons.person_rounded)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error ?? 'UP信息加载中',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: <Widget>[
          UserAvatar(
            avatarUrl: value.avatarUrl,
            radius: 36,
            tipSize: 16,
            officialType: value.officialType,
            useCache: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatCompactCount(value.followerCount)} 粉丝',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _FavoriteUpButton(profile: value),
        ],
      ),
    );
  }
}

class _FavoriteUpButton extends ConsumerWidget {
  const _FavoriteUpButton({required this.profile});

  final UpProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFavorited = ref.watch(
      favoriteUpControllerProvider.select(
        (List<FavoriteUp> ups) => ups.any(
          (FavoriteUp up) =>
              up.mid == profile.mid ||
              favoriteUpIdentityKey(name: up.name, avatarUrl: up.avatarUrl) ==
                  favoriteUpIdentityKey(
                    name: profile.name,
                    avatarUrl: profile.avatarUrl,
                  ),
        ),
      ),
    );

    return FavoriteLikeIconButton(
      isLiked: isFavorited,
      iconSize: 26,
      tooltip: isFavorited ? '取消关注' : '关注 UP 主',
      onPressed: () {
        ref.read(favoriteUpControllerProvider.notifier).toggle(profile);
      },
    );
  }
}
