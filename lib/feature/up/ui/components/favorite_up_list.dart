import 'dart:async';

import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/favorite_up_update.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_update_controller.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteUpList extends ConsumerStatefulWidget {
  const FavoriteUpList({super.key});

  @override
  ConsumerState<FavoriteUpList> createState() => _FavoriteUpListState();
}

class _FavoriteUpListState extends ConsumerState<FavoriteUpList> {
  static const double _horizontalPadding = 16;
  static const double _chipGap = 8;
  static const double _maxContentWidth = 640;

  FavoriteUpFilter _filter = FavoriteUpFilter.all;

  @override
  void initState() {
    super.initState();
    _ensureFresh();
  }

  @override
  void didUpdateWidget(covariant FavoriteUpList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFresh();
  }

  void _ensureFresh() {
    final List<FavoriteUp> ups = ref.read(favoriteUpControllerProvider);
    if (ups.isEmpty) {
      return;
    }
    unawaited(
      ref.read(favoriteUpUpdateControllerProvider.notifier).ensureFresh(ups),
    );
  }

  void _openUp(FavoriteUp up) {
    context.push('/up/${up.mid}');
  }

  @override
  Widget build(BuildContext context) {
    final List<FavoriteUp> ups = ref.watch(favoriteUpControllerProvider);

    if (ups.isEmpty) {
      return const StatusView(
        icon: Icons.person_off_outlined,
        title: '还没有收藏UP主',
      );
    }

    final Map<int, FavoriteUpUpdate> updates = ref.watch(
      favoriteUpUpdateControllerProvider,
    );
    final Map<String, int> playedMsByAuthor = ref
        .watch(statisticsLocalRepositoryProvider)
        .totalPlayedMsByAuthor();
    final List<FavoriteUp> visible = filterFavoriteUps(
      ups: ups,
      filter: _filter,
      updates: updates,
      playedMsByAuthor: playedMsByAuthor,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                12,
                _horizontalPadding,
                0,
              ),
              child: Row(
                children: <Widget>[
                  for (final FavoriteUpFilter filter
                      in FavoriteUpFilter.values) ...<Widget>[
                    if (filter != FavoriteUpFilter.values.first)
                      const SizedBox(width: _chipGap),
                    FavoriteUpFilterChip(
                      label: filter.label,
                      selected: filter == _filter,
                      onTap: () => setState(() => _filter = filter),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const StatusView(
                      icon: Icons.schedule_rounded,
                      title: '今天还没有关注的 UP 主更新',
                    )
                  : FavoriteUpGrid(
                      ups: visible,
                      updates: updates,
                      onTap: _openUp,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
