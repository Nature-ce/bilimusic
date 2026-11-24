import 'dart:async';

import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/domain/remote_collection_sync_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_search.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/remote_collection_sync_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_action_menu.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_play_button.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_search_field.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:bilimusic/feature/favorites/ui/components/remote_collection_sync_status_bar.dart';
import 'package:bilimusic/feature/home/ui/components/collection_detail_header.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteCollectionPage extends ConsumerStatefulWidget {
  const FavoriteCollectionPage({super.key, required this.collectionId});

  static final AppLogger _logger = AppLogger('FavoriteCollectionPage');

  final String collectionId;

  @override
  ConsumerState<FavoriteCollectionPage> createState() =>
      _FavoriteCollectionPageState();
}

class _FavoriteCollectionPageState extends ConsumerState<FavoriteCollectionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  String _searchQuery = '';
  bool _searchActive = false;
  bool _selectionMode = false;
  Set<String> _selectedItemIds = <String>{};
  _FavoriteSortMode _sortMode = _FavoriteSortMode.all;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_handleTabChanged);
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant FavoriteCollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionId != widget.collectionId) {
      _resetSearchState();
      _selectionMode = false;
      _selectedItemIds = <String>{};
      _sortMode = _FavoriteSortMode.all;
      _tabIndex = 0;
      _tabController.index = 0;
      _scheduleSync();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _resetSearchState();
    });
    super.deactivate();
  }

  RemoteCollectionSyncState get _syncState =>
      ref.watch(remoteCollectionSyncControllerProvider(widget.collectionId));

  Future<void> _triggerSync({bool force = false}) {
    return ref
        .read(
          remoteCollectionSyncControllerProvider(widget.collectionId).notifier,
        )
        .sync(force: force);
  }

  Future<void> _forceSync() => _triggerSync(force: true);

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_triggerSync());
    });
  }

  Future<void> _loadMoreRemoteItems() {
    return ref
        .read(
          remoteCollectionSyncControllerProvider(widget.collectionId).notifier,
        )
        .loadMore();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.extentAfter <= 200) {
      unawaited(_loadMoreRemoteItems());
    }
    return false;
  }

  Future<void> _openCollectionActionMenu({
    required FavoriteCollection collection,
    required BuildContext buttonContext,
    VoidCallback? onMultiSelect,
  }) async {
    final RenderBox? box = buttonContext.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    await showFavoriteCollectionActionMenu(
      context: context,
      ref: ref,
      collection: collection,
      globalPosition: box.localToGlobal(box.size.center(Offset.zero)),
      onMultiSelect: onMultiSelect,
    );
    if (!mounted) {
      return;
    }
    final bool exists = ref
        .read(favoritesControllerProvider)
        .collections
        .any((FavoriteCollection item) => item.id == collection.id);
    if (!exists && context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _refresh(FavoriteCollection collection) async {
    if (collection.isRemote) {
      await _forceSync();
      return;
    }
    await ref.read(favoritesControllerProvider.notifier).reload();
  }

  void _handleTabChanged() {
    final int index = _tabController.index;
    if (index == _tabIndex) {
      return;
    }
    setState(() {
      _tabIndex = index;
      if (index == 0) {
        return;
      }
      _searchController.clear();
      _searchQuery = '';
      _searchActive = false;
      _selectionMode = false;
      _selectedItemIds = <String>{};
    });
  }

  void _openSearch() {
    if (_searchActive) {
      return;
    }
    setState(() => _searchActive = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  void _openSelectionMode() {
    if (_selectionMode) {
      return;
    }
    setState(() {
      _selectionMode = true;
      _selectedItemIds = <String>{};
    });
  }

  void _exitSelectionMode() {
    if (!_selectionMode) {
      return;
    }
    setState(() {
      _selectionMode = false;
      _selectedItemIds = <String>{};
    });
  }

  void _updateSearchQuery(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearSearchQuery() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _resetSearchState() {
    if (!_searchActive &&
        _searchQuery.isEmpty &&
        _searchController.text.isEmpty) {
      return;
    }

    _searchController.clear();
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  void _toggleSelectedItem(String itemId) {
    setState(() {
      final Set<String> next = Set<String>.of(_selectedItemIds);
      if (!next.remove(itemId)) {
        next.add(itemId);
      }
      _selectedItemIds = next;
    });
  }

  List<FavoriteEntry> _selectedItems(List<FavoriteEntry> items) {
    return items
        .where((FavoriteEntry item) => _selectedItemIds.contains(item.itemId))
        .toList(growable: false);
  }

  void _changeSortMode(_FavoriteSortMode mode) {
    if (_sortMode == mode) {
      return;
    }
    setState(() => _sortMode = mode);
  }

  List<FavoriteEntry> _applySortMode(List<FavoriteEntry> items) {
    if (_sortMode == _FavoriteSortMode.all || items.length < 2) {
      return items;
    }
    final List<int> order = List<int>.generate(
      items.length,
      (int index) => index,
    );
    order.sort((int left, int right) {
      final int compared = switch (_sortMode) {
        _FavoriteSortMode.recent => items[right].createdAt.compareTo(
          items[left].createdAt,
        ),
        _FavoriteSortMode.author => items[left].author.toLowerCase().compareTo(
          items[right].author.toLowerCase(),
        ),
        _FavoriteSortMode.all => 0,
      };
      return compared != 0 ? compared : left.compareTo(right);
    });
    return <FavoriteEntry>[for (final int index in order) items[index]];
  }

  @override
  Widget build(BuildContext context) {
    final FavoritesState state = ref.watch(favoritesControllerProvider);
    final FavoriteCollection? collection = _findCollection(state);
    if (collection == null) {
      return _buildMissingCollectionPage();
    }

    final FavoriteCollection resolvedCollection = collection;
    final List<FavoriteEntry> items = state.itemsForCollection(
      resolvedCollection.id,
    );
    final List<FavoriteEntry> visibleItems = _applySortMode(
      filterFavoriteEntries(items, _searchQuery),
    );
    final List<PlayableItem> queueItems = visibleItems
        .map(
          (FavoriteEntry item) =>
              item.toPlayableItem(collection: resolvedCollection),
        )
        .toList(growable: false);
    final bool showLikedTabs = resolvedCollection.isLikedCollection;
    final Widget songsBody = _buildSongsBody(
      collection: resolvedCollection,
      items: items,
      visibleItems: visibleItems,
      queueItems: queueItems,
    );

    return PopScope(
      canPop: !_searchActive && !_selectionMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (_selectionMode) {
          _exitSelectionMode();
          return;
        }
        _closeSearch();
      },
      child: Scaffold(
        appBar: _buildAppBar(
          collection: resolvedCollection,
          items: items,
          visibleItems: visibleItems,
          queueItems: queueItems,
          showLikedTabs: showLikedTabs,
        ),
        body: showLikedTabs
            ? TabBarView(
                controller: _tabController,
                children: <Widget>[songsBody, const FavoriteUpList()],
              )
            : songsBody,
      ),
    );
  }

  FavoriteCollection? _findCollection(FavoritesState state) {
    for (final FavoriteCollection collection in state.collections) {
      if (collection.id == widget.collectionId) {
        return collection;
      }
    }
    return null;
  }

  PreferredSizeWidget _buildAppBar({
    required FavoriteCollection collection,
    required List<FavoriteEntry> items,
    required List<FavoriteEntry> visibleItems,
    required List<PlayableItem> queueItems,
    required bool showLikedTabs,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (_searchActive) {
      return PageAppBar(
        titleSpacing: 0,
        title: FavoriteCollectionSearchField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          query: _searchQuery,
          onChanged: _updateSearchQuery,
          onClear: _clearSearchQuery,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: '取消搜索',
            onPressed: _closeSearch,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      );
    }

    if (_selectionMode) {
      final bool hasSelection = _selectedItemIds.isNotEmpty;
      return PageAppBar(
        leading: IconButton(
          tooltip: '退出多选',
          onPressed: _exitSelectionMode,
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text('已选 ${_selectedItemIds.length} 项'),
        actions: <Widget>[
          IconButton(
            tooltip: '添加到歌单',
            onPressed: hasSelection
                ? () => unawaited(_addSelectedItems(collection, visibleItems))
                : null,
            icon: const Icon(Icons.playlist_add_rounded),
          ),
          IconButton(
            tooltip: '批量下载',
            onPressed: hasSelection
                ? () => unawaited(
                    _downloadSelectedItems(collection, visibleItems),
                  )
                : null,
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: '删除',
            onPressed: hasSelection
                ? () => unawaited(
                    _deleteSelectedItems(
                      collection: collection,
                      items: visibleItems,
                    ),
                  )
                : null,
            color: colorScheme.error,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      );
    }

    return PageAppBar(
      title: Text(
        collection.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        if (_tabIndex == 0) ...<Widget>[
          IconButton(
            tooltip: '搜索',
            onPressed: _openSearch,
            icon: const Icon(Icons.search_rounded),
          ),
          if (!collection.isSystem || collection.isRemote)
            Builder(
              builder: (BuildContext buttonContext) {
                return IconButton(
                  tooltip: '歌单设置',
                  onPressed: () => unawaited(
                    _openCollectionActionMenu(
                      collection: collection,
                      buttonContext: buttonContext,
                      onMultiSelect: items.isEmpty ? null : _openSelectionMode,
                    ),
                  ),
                  icon: const Icon(Icons.more_horiz_rounded),
                );
              },
            ),
        ],
      ],
      bottom: showLikedTabs
          ? TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(text: '歌曲'),
                Tab(text: 'UP主'),
              ],
            )
          : null,
    );
  }

  Widget _buildSongsBody({
    required FavoriteCollection collection,
    required List<FavoriteEntry> items,
    required List<FavoriteEntry> visibleItems,
    required List<PlayableItem> queueItems,
  }) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        RemoteCollectionSyncStatusBar(status: _syncState.status),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: RefreshIndicator(
              onRefresh: () => _refresh(collection),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: <Widget>[
                  CollectionDetailHeader(
                    coverUrl: _resolveCoverUrl(collection, items),
                    chipLabel: collection.isRemote ? 'B站 · 收藏夹' : '本地 · 歌单',
                    title: collection.name,
                    meta: _buildMetaLabel(collection, items.length),
                    subMeta: collection.isRemote ? '已与 B 站同步' : '仅保存在本机',
                    coverFallbackIcon: collection.isLikedCollection
                        ? Icons.favorite_rounded
                        : Icons.queue_music_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CollectionActionRow(
                    playAllKey: const Key('favoriteCollectionPlayAll'),
                    canPlayAll: queueItems.isNotEmpty,
                    onPlayAll: () =>
                        unawaited(_playCollection(collection, queueItems)),
                    refreshKey: const Key('favoriteCollectionRefresh'),
                    onRefresh: () => unawaited(_refresh(collection)),
                    playAllLabel: '播放全部',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (!_selectionMode && items.isNotEmpty) ...<Widget>[
                    _FavoriteSortCapsuleRow(
                      mode: _sortMode,
                      totalCount: items.length,
                      onChanged: _changeSortMode,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Row(
                    children: <Widget>[
                      Text(
                        '歌曲',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (visibleItems.isNotEmpty)
                        Text(
                          '共 ${visibleItems.length} 首',
                          style: AppTextStyles.meta(theme, fontSize: 11.5),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ..._buildTrackSection(
                    collection: collection,
                    items: items,
                    visibleItems: visibleItems,
                    queueItems: queueItems,
                  ),
                  _buildRemoteLoadMoreFooter(collection.isRemote),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTrackSection({
    required FavoriteCollection collection,
    required List<FavoriteEntry> items,
    required List<FavoriteEntry> visibleItems,
    required List<PlayableItem> queueItems,
  }) {
    if (items.isEmpty) {
      if (_syncState.isSyncing) {
        return const <Widget>[_FavoriteTracksLoading()];
      }
      if (_syncState.hasFailed) {
        return <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: StatusView(
              icon: Icons.wifi_off_rounded,
              iconColor: Theme.of(context).colorScheme.error,
              title: '网络歌单同步失败',
              description: '请检查网络后重试。',
              isRetrying: _syncState.isSyncing,
              onRetry: _forceSync,
            ),
          ),
        ];
      }
      return <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: StatusView(
            icon: collection.isLikedCollection
                ? Icons.favorite_border_rounded
                : Icons.folder_open_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            title: '这个歌单还是空的',
            description: '先去搜索页或者播放器点亮爱心，喜欢的内容会出现在这里。',
          ),
        ),
      ];
    }

    if (visibleItems.isEmpty) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: StatusView(
            icon: Icons.search_off_rounded,
            title: '没有结果？前往在线搜索试试',
            actions: <Widget>[
              TextButton.icon(
                onPressed: () => context.push('/search'),
                label: const Text('搜索'),
              ),
            ],
          ),
        ),
      ];
    }

    return <Widget>[
      for (int index = 0; index < visibleItems.length; index += 1)
        _buildTrackRow(
          collection: collection,
          queueItems: queueItems,
          item: visibleItems[index],
          index: index,
        ),
    ];
  }

  Widget _buildTrackRow({
    required FavoriteCollection collection,
    required List<PlayableItem> queueItems,
    required FavoriteEntry item,
    required int index,
  }) {
    final bool selected = _selectedItemIds.contains(item.itemId);
    final Widget tile = TrackRowTile(
      rank: index + 1,
      title: normalizeDisplayText(item.title),
      artist: buildFavoriteTileSubtitle(item),
      coverUrl: item.coverUrl,
      durationText: item.durationText ?? '',
      onTap: () {
        if (_selectionMode) {
          _toggleSelectedItem(item.itemId);
          return;
        }
        unawaited(
          _playCollectionItem(
            collection: collection,
            queueItems: queueItems,
            item: item,
            index: index,
          ),
        );
      },
    );

    if (!_selectionMode) {
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onLongPress: () =>
            unawaited(_showItemActionSheet(collection: collection, item: item)),
        child: tile,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: selected,
            visualDensity: VisualDensity.compact,
            onChanged: (bool? value) => _toggleSelectedItem(item.itemId),
          ),
          Expanded(child: tile),
        ],
      ),
    );
  }

  String _resolveCoverUrl(
    FavoriteCollection collection,
    List<FavoriteEntry> items,
  ) {
    final String cover = collection.coverUrl?.trim() ?? '';
    if (cover.isNotEmpty) {
      return cover;
    }
    for (final FavoriteEntry item in items) {
      if (item.coverUrl.trim().isNotEmpty) {
        return item.coverUrl;
      }
    }
    return '';
  }

  String _buildMetaLabel(FavoriteCollection collection, int count) {
    final String countLabel = '共 $count 首';
    final String? updatedLabel = _relativeUpdatedLabel(collection.updatedAt);
    if (updatedLabel == null) {
      return countLabel;
    }
    return '$countLabel · $updatedLabel';
  }

  Widget _buildMissingCollectionPage() {
    return Scaffold(
      appBar: PageAppBar(title: const Text('歌单')),
      body: const StatusView(icon: Icons.folder_off_outlined, title: '歌单不存在'),
    );
  }

  Widget _buildRemoteLoadMoreFooter(bool isRemote) {
    if (!isRemote || !_syncState.hasMoreRemotePages) {
      return const BottomPageSpacer();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: _syncState.isLoadingMore
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => unawaited(_loadMoreRemoteItems()),
                child: const Text('加载更多'),
              ),
      ),
    );
  }

  Future<void> _playCollection(
    FavoriteCollection collection,
    List<PlayableItem> queueItems,
  ) async {
    if (queueItems.isEmpty) {
      return;
    }
    final FavoriteCollectionPlayMode? mode =
        await showFavoriteCollectionPlayModeSheet(context);
    if (mode == null || !mounted) {
      return;
    }
    final bool shuffle = mode == FavoriteCollectionPlayMode.shuffle;
    final List<PlayableItem> items = shuffle
        ? (List<PlayableItem>.of(queueItems)..shuffle())
        : queueItems;
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: items,
      sourceLabel: shuffle ? '${collection.name} · 随机' : collection.name,
    );
    if (!mounted) {
      return;
    }
    ref.read(playerControllerProvider.notifier).setQueueMode(switch (mode) {
      FavoriteCollectionPlayMode.shuffle => PlayerQueueMode.shuffle,
      FavoriteCollectionPlayMode.loop => PlayerQueueMode.sequence,
    });
  }

  Future<void> _playCollectionItem({
    required FavoriteCollection collection,
    required List<PlayableItem> queueItems,
    required FavoriteEntry item,
    required int index,
  }) async {
    final PlayableItem playableItem = item.toPlayableItem(
      collection: collection,
    );
    final int stableIndex = queueItems.indexWhere(
      (PlayableItem candidate) =>
          candidate.stableId == playableItem.stableId ||
          candidate.stableId == item.itemId,
    );
    final int targetIndex = stableIndex >= 0 ? stableIndex : index;
    if (queueItems.isEmpty ||
        targetIndex < 0 ||
        targetIndex >= queueItems.length) {
      return;
    }
    FavoriteCollectionPage._logger.d(
      '[FavoriteDebug] tapPlay | collection=${collection.name}, '
      'index=$targetIndex, queueLength=${queueItems.length}, '
      'itemStableId=${queueItems[targetIndex].stableId}, '
      'itemTitle=${queueItems[targetIndex].title}',
    );
    if (!mounted) {
      return;
    }
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queueItems,
      startIndex: targetIndex,
      sourceLabel: collection.name,
    );
  }

  Future<void> _downloadSelectedItems(
    FavoriteCollection collection,
    List<FavoriteEntry> items,
  ) async {
    final List<PlayableItem> selectedItems = _selectedItems(items)
        .map(
          (FavoriteEntry item) => item.toPlayableItem(collection: collection),
        )
        .toList(growable: false);
    if (selectedItems.isEmpty) {
      return;
    }

    final DownloadController controller = ref.read(
      downloadControllerProvider.notifier,
    );
    int queuedCount = 0;
    for (final PlayableItem item in selectedItems) {
      if (await controller.download(item)) {
        queuedCount += 1;
      }
    }
    if (!mounted) {
      return;
    }
    _exitSelectionMode();
    ToastUtil.show(queuedCount == 0 ? '已下载或正在下载' : '已加入下载队列 $queuedCount 首');
  }

  Future<void> _addSelectedItems(
    FavoriteCollection collection,
    List<FavoriteEntry> items,
  ) async {
    final List<PlayableItem> selectedItems = _selectedItems(items)
        .map(
          (FavoriteEntry item) => item.toPlayableItem(collection: collection),
        )
        .toList(growable: false);
    if (selectedItems.isEmpty) {
      return;
    }

    final bool? added = await showPlayerCollectionItemsSheet(
      context: context,
      items: selectedItems,
    );
    if (added == true && mounted) {
      _exitSelectionMode();
    }
  }

  Future<void> _deleteSelectedItems({
    required FavoriteCollection collection,
    required List<FavoriteEntry> items,
  }) async {
    final List<FavoriteEntry> selectedItems = _selectedItems(items);
    if (selectedItems.isEmpty) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('删除收藏'),
          content: Text(
            '确定从“${collection.name}”移除 ${selectedItems.length} 项吗？',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    int removedCount = 0;
    for (final FavoriteEntry item in selectedItems) {
      final bool removed = await ref
          .read(favoritesControllerProvider.notifier)
          .removeFromCollection(
            collectionId: collection.id,
            itemId: item.itemId,
          );
      if (removed) {
        removedCount++;
      }
    }

    if (!mounted) {
      return;
    }
    _exitSelectionMode();
    ToastUtil.show(
      removedCount == selectedItems.length
          ? '已移除 $removedCount 项'
          : '已移除 $removedCount / ${selectedItems.length} 项',
    );
  }

  Future<void> _showItemActionSheet({
    required FavoriteCollection collection,
    required FavoriteEntry item,
  }) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayableItem playableItem = item.toPlayableItem(
      collection: collection,
    );

    final bool useGlass = ref.read(appearanceSettingLogicProvider);
    Widget buildSheet(BuildContext sheetContext) {
      final double bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  leading: CommonCachedImage(
                    imageUrl: item.coverUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(14),
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.14,
                    ),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    buildFavoriteEntrySubtitle(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                _FavoriteActionTile(
                  icon: Icons.heart_broken_rounded,
                  title: '取消收藏',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final bool removed = await ref
                        .read(favoritesControllerProvider.notifier)
                        .removeFromCollection(
                          collectionId: collection.id,
                          itemId: item.itemId,
                        );
                    if (!mounted) {
                      return;
                    }
                    ToastUtil.show(
                      removed ? '已从“${collection.name}”移除' : '取消收藏失败',
                    );
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.playlist_add_rounded,
                  title: '加到歌单',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await showPlayerCollectionSheet(
                      context: context,
                      item: playableItem,
                    );
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.download_rounded,
                  title: '下载',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final bool queued = await ref
                        .read(downloadControllerProvider.notifier)
                        .download(playableItem);
                    if (!mounted) {
                      return;
                    }
                    ToastUtil.show(queued ? '已加入下载队列' : '已下载或正在下载');
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.person_rounded,
                  title: '查看UP主',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openOwnerPage(item);
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.bar_chart_rounded,
                  title: '统计',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (mounted) {
                      context.push('/statistics/song', extra: playableItem);
                    }
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.skip_next_rounded,
                  title: '下一首播放',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await ref
                        .read(playerControllerProvider.notifier)
                        .playNext(playableItem);
                    if (!mounted) {
                      return;
                    }
                    ToastUtil.show('已加入下一首');
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.library_add_rounded,
                  title: '添加全部分P',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _enqueueAllParts(playableItem: playableItem);
                  },
                ),
                _FavoriteActionTile(
                  icon: Icons.share_rounded,
                  title: '分享',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ToastUtil.show('分享功能暂未开放');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (useGlass) {
      await showAppHalfSheet<void>(context: context, builder: buildSheet);
      return;
    }
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      builder: buildSheet,
    );
  }

  Future<void> _enqueueAllParts({required PlayableItem playableItem}) async {
    try {
      final int addedCount = await PlayerUtil.enqueueAllParts(
        ref,
        playableItem,
      );
      if (!mounted) {
        return;
      }
      ToastUtil.show(addedCount > 0 ? '已加入 $addedCount 个分P' : '全部分P已在播放队列中');
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ToastUtil.show('操作失败: $error');
    }
  }

  void _openOwnerPage(FavoriteEntry item) {
    final int? ownerMid = item.ownerMid;
    if (ownerMid == null || ownerMid <= 0) {
      ToastUtil.show('暂无UP主信息');
      return;
    }
    context.push('/up/$ownerMid');
  }
}

class _FavoriteTracksLoading extends StatelessWidget {
  const _FavoriteTracksLoading();

  @override
  Widget build(BuildContext context) {
    final Color placeholderColor = appSkeletonColor(context);
    return Column(
      children: List<Widget>.generate(6, (int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm - 2,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: AppSizes.listCover,
                  height: AppSizes.listCover,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: placeholderColor,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: placeholderColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

enum _FavoriteSortMode { all, recent, author }

class _FavoriteSortCapsuleRow extends StatelessWidget {
  const _FavoriteSortCapsuleRow({
    required this.mode,
    required this.totalCount,
    required this.onChanged,
  });

  final _FavoriteSortMode mode;
  final int totalCount;
  final ValueChanged<_FavoriteSortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _FavoriteSortCapsule(
            capsuleKey: const Key('favoriteCollectionSortAll'),
            label: '全部 · $totalCount',
            selected: mode == _FavoriteSortMode.all,
            onTap: () => onChanged(_FavoriteSortMode.all),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FavoriteSortCapsule(
            capsuleKey: const Key('favoriteCollectionSortRecent'),
            label: '最近添加',
            selected: mode == _FavoriteSortMode.recent,
            onTap: () => onChanged(_FavoriteSortMode.recent),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FavoriteSortCapsule(
            capsuleKey: const Key('favoriteCollectionSortAuthor'),
            label: '按歌手',
            selected: mode == _FavoriteSortMode.author,
            onTap: () => onChanged(_FavoriteSortMode.author),
          ),
        ],
      ),
    );
  }
}

class _FavoriteSortCapsule extends StatelessWidget {
  const _FavoriteSortCapsule({
    required this.capsuleKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key capsuleKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: selected
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: capsuleKey,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.sm - 2,
          ),
          child: Text(
            label,
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteActionTile extends StatelessWidget {
  const _FavoriteActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }
}

String? _relativeUpdatedLabel(DateTime? updatedAt) {
  if (updatedAt == null) {
    return null;
  }
  final DateTime now = DateTime.now();
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
    return '$days 天前更新';
  }
  if (days < 30) {
    return '${days ~/ 7} 周前更新';
  }
  if (days < 365) {
    return '${days ~/ 30} 个月前更新';
  }
  return '${days ~/ 365} 年前更新';
}
