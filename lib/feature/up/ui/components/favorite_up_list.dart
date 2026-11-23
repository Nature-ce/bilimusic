import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteUpList extends ConsumerWidget {
  const FavoriteUpList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FavoriteUp> ups = ref.watch(favoriteUpControllerProvider);

    if (ups.isEmpty) {
      return const StatusView(
        icon: Icons.person_off_outlined,
        title: '还没有收藏UP主',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
      itemCount: ups.length,
      itemBuilder: (BuildContext context, int index) {
        return _FavoriteUpRow(up: ups[index]);
      },
    );
  }
}

class _FavoriteUpRow extends ConsumerWidget {
  const _FavoriteUpRow({required this.up});

  final FavoriteUp up;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.push('/up/${up.mid}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: <Widget>[
            UserAvatar(
              avatarUrl: up.avatarUrl,
              officialType: up.officialType,
              useCache: true,
              radius: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    up.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'UID ${up.mid}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '取消收藏',
              icon: const Icon(Icons.favorite_rounded, size: 20),
              color: colorScheme.primary,
              onPressed: () {
                ref.read(favoriteUpControllerProvider.notifier).remove(up.mid);
              },
            ),
          ],
        ),
      ),
    );
  }
}
