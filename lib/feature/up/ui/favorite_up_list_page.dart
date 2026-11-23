import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteUpListPage extends ConsumerWidget {
  const FavoriteUpListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FavoriteUp> ups = ref.watch(favoriteUpControllerProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PlatformUtil.isMobile
          ? PageAppBar(
              title: const Text('关注的 UP 主'),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${ups.length} 位',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: const FavoriteUpList(),
    );
  }
}
