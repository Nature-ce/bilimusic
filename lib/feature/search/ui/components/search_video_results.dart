import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/ui/components/search_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchVideoResults extends StatelessWidget {
  const SearchVideoResults({
    super.key,
    required this.submittedQuery,
    required this.results,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.loadMoreErrorMessage,
    required this.sort,
    required this.onRetryLoadMore,
    required this.onPlayItem,
    required this.onPlayNext,
    required this.onEnqueue,
    required this.onChangeSort,
  });

  final String? submittedQuery;
  final List<SearchResultItem> results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final SearchSort sort;
  final VoidCallback onRetryLoadMore;
  final Future<void> Function(SearchResultItem item) onPlayItem;
  final Future<void> Function(SearchResultItem item) onPlayNext;
  final Future<void> Function(SearchResultItem item) onEnqueue;
  final Future<void> Function(SearchSort sort) onChangeSort;

  @override
  Widget build(BuildContext context) {
    final bool hasQuery = submittedQuery != null && submittedQuery!.isNotEmpty;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!hasQuery) {
      return SliverStatusView(
        child: StatusView(
          icon: Icons.search_rounded,
          iconColor: colorScheme.primary,
          title: '输入关键词开始搜索',
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _SearchResultHeader(sort: sort, onChangeSort: onChangeSort),
        ),
        if (isLoading)
          _SearchLoadingSliver(title: '正在搜索 "$submittedQuery"')
        else if (errorMessage != null && errorMessage!.isNotEmpty)
          SliverStatusView(
            child: StatusView(
              icon: Icons.error_outline_rounded,
              iconColor: colorScheme.error,
              title: '搜索失败',
              onRetry: onRetryLoadMore,
            ),
          )
        else if (results.isEmpty)
          const SliverStatusView(
            child: StatusView(
              icon: Icons.search_off_rounded,
              title: '没有找到相关视频',
              description: '试试更换关键词，或者稍后重试。',
            ),
          )
        else
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final favoritesState = ref.watch(favoritesControllerProvider);

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverList.builder(
                  itemCount: results.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == results.length) {
                      return SearchResultFooter(
                        isLoadingMore: isLoadingMore,
                        hasMore: hasMore,
                        errorMessage: loadMoreErrorMessage,
                        onRetry: onRetryLoadMore,
                      );
                    }

                    final SearchResultItem item = results[index];
                    return _SearchResultRow(
                      index: index,
                      item: item,
                      isFavorite: favoritesState.isLikedVideoPage(
                        aid: item.aid,
                        bvid: item.bvid,
                        page: 1,
                      ),
                      onTap: () => onPlayItem(item),
                      onPlayNext: onPlayNext,
                      onEnqueue: onEnqueue,
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SearchResultHeader extends StatelessWidget {
  const _SearchResultHeader({required this.sort, required this.onChangeSort});

  final SearchSort sort;
  final Future<void> Function(SearchSort sort) onChangeSort;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
      child: Row(
        children: <Widget>[
          Text(
            '搜索结果',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          PopupMenuButton<SearchSort>(
            tooltip: '切换排序',
            padding: EdgeInsets.zero,
            position: PopupMenuPosition.under,
            onSelected: onChangeSort,
            itemBuilder: (BuildContext context) {
              return SearchSort.values.map((SearchSort item) {
                final bool selected = item == sort;
                return PopupMenuItem<SearchSort>(
                  value: item,
                  child: Text(
                    '按${_searchSortLabel(item)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                '按${_searchSortLabel(sort)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _searchSortLabel(SearchSort sort) {
  return sort == SearchSort.comprehensive ? '相关度' : sort.label;
}

class _SearchResultRow extends ConsumerWidget {
  const _SearchResultRow({
    required this.index,
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onPlayNext,
    required this.onEnqueue,
  });

  final int index;
  final SearchResultItem item;
  final bool isFavorite;
  final VoidCallback onTap;
  final Future<void> Function(SearchResultItem item) onPlayNext;
  final Future<void> Function(SearchResultItem item) onEnqueue;

  String get _subtitle {
    final String playCountText = item.playCountText.trim();
    if (playCountText.isEmpty) {
      return item.author;
    }
    return '${item.author} · $playCountText播放';
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(item.toPlayableItem(), preferredPage: 1);
      final bool liked = await ref
          .read(favoritesControllerProvider.notifier)
          .toggleLiked(resolvedItem);
      if (context.mounted) {
        ToastUtil.show(liked ? '已收藏 P1' : '已从“我喜欢”移除');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('收藏失败: $error');
      }
    }
  }

  Future<void> _playNext(BuildContext context) async {
    try {
      await onPlayNext(item);
      if (context.mounted) {
        ToastUtil.show('已加入下一首');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('操作失败: $error');
      }
    }
  }

  Future<void> _enqueue(BuildContext context) async {
    try {
      await onEnqueue(item);
      if (context.mounted) {
        ToastUtil.show('已加入播放队列');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('操作失败: $error');
      }
    }
  }

  Future<void> _enqueueAllParts(BuildContext context, WidgetRef ref) async {
    try {
      final int addedCount = await PlayerUtil.enqueueAllParts(
        ref,
        item.toPlayableItem(),
      );
      if (context.mounted) {
        ToastUtil.show(addedCount > 0 ? '已加入 $addedCount 个分P' : '全部分P已在播放队列中');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('操作失败: $error');
      }
    }
  }

  Future<void> _addToCollection(BuildContext context) async {
    await showPlayerCollectionSheet(
      context: context,
      item: item.toPlayableItem(),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _SearchRowAction action,
  ) async {
    switch (action) {
      case _SearchRowAction.favorite:
        await _toggleFavorite(context, ref);
      case _SearchRowAction.playNext:
        await _playNext(context);
      case _SearchRowAction.enqueue:
        await _enqueue(context);
      case _SearchRowAction.addToCollection:
        await _addToCollection(context);
      case _SearchRowAction.enqueueAllParts:
        await _enqueueAllParts(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 26,
                child: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CommonCachedImage(
                imageUrl: item.coverUrl,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(12),
                fallbackIcon: Icons.music_video_rounded,
                iconColor: colorScheme.primary,
                backgroundColor: appSkeletonColor(context),
                iconSize: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      normalizeDisplayText(item.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_SearchRowAction>(
                tooltip: '更多操作',
                padding: EdgeInsets.zero,
                position: PopupMenuPosition.under,
                onSelected: (_SearchRowAction action) {
                  unawaited(_handleAction(context, ref, action));
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<_SearchRowAction>>[
                    PopupMenuItem<_SearchRowAction>(
                      value: _SearchRowAction.favorite,
                      child: Text(isFavorite ? '取消收藏' : '收藏'),
                    ),
                    const PopupMenuItem<_SearchRowAction>(
                      value: _SearchRowAction.playNext,
                      child: Text('下一首播放'),
                    ),
                    const PopupMenuItem<_SearchRowAction>(
                      value: _SearchRowAction.enqueue,
                      child: Text('加入播放队列'),
                    ),
                    const PopupMenuItem<_SearchRowAction>(
                      value: _SearchRowAction.enqueueAllParts,
                      child: Text('添加全部分P'),
                    ),
                    const PopupMenuItem<_SearchRowAction>(
                      value: _SearchRowAction.addToCollection,
                      child: Text('添加到歌单'),
                    ),
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SearchRowAction {
  favorite,
  playNext,
  enqueue,
  enqueueAllParts,
  addToCollection,
}

class _SearchLoadingSliver extends StatelessWidget {
  const _SearchLoadingSliver({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: <Widget>[
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
