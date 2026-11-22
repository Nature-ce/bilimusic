import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/logic/favorite_hot_playlist_controller.dart';
import 'package:bilimusic/feature/profile/ui/components/followed_ups_card.dart';
import 'package:bilimusic/feature/profile/ui/components/profile_local_entry.dart';
import 'package:bilimusic/feature/profile/ui/components/profile_playlist_card.dart';
import 'package:bilimusic/feature/profile/ui/components/profile_stats_card.dart';
import 'package:bilimusic/feature/profile/ui/components/profile_version_footer.dart';
import 'package:bilimusic/feature/profile/ui/components/remote_collection_import_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:bilimusic/feature/profile/ui/components/weekly_listening_card.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/logic/weekly_listening.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showAllCollections = false;
  bool _didRefreshRemoteCollections = false;
  bool _isRefreshingRemoteCollections = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refreshRemoteCollectionsOnEnter);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BiliSession?>(biliSessionControllerProvider, (
      BiliSession? previous,
      BiliSession? next,
    ) {
      if ((previous?.isLoggedIn ?? false) || !(next?.isLoggedIn ?? false)) {
        return;
      }
      _didRefreshRemoteCollections = false;
      _refreshRemoteCollectionsOnEnter();
    });
    final bool isLoggedIn =
        (ref.watch(biliSessionControllerProvider)?.isLoggedIn ?? false);
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final int likedCount = favoritesState.itemCountForCollection(
      FavoriteCollection.likedCollectionId,
    );
    final int recentCount = ref.watch(recentPlaybackControllerProvider).length;
    final int downloadCount = ref
        .watch(downloadControllerProvider)
        .tracks
        .length;
    final List<FavoriteCollection> collections =
        <FavoriteCollection>[
          ...favoritesState.collections.where(
            (FavoriteCollection collection) =>
                collection.isLocal && !collection.isSystem,
          ),
          if (isLoggedIn)
            ...favoritesState.collections.where(
              (FavoriteCollection collection) => collection.isRemote,
            ),
        ]..sort(
          (FavoriteCollection left, FavoriteCollection right) =>
              right.updatedAt.compareTo(left.updatedAt),
        );
    final bool shouldCollapse = collections.length > 5;
    final List<FavoriteCollection> visibleCollections =
        shouldCollapse && !_showAllCollections
        ? collections.take(5).toList(growable: false)
        : collections;
    final List<HotPlaylist> favoritePlaylists = ref.watch(
      favoriteHotPlaylistsProvider,
    );
    final WeeklyListeningSummary weeklyListening = _weeklyListeningSummary();
    final List<FavoriteUp> followedUps = _followedUps();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          children: <Widget>[
            UserCard(onSettingsPressed: () => context.push('/settings')),
            const SizedBox(height: 14),
            ProfileStatsCard(
              likedCount: likedCount,
              playlistCount: collections.length,
              recentCount: recentCount,
              downloadCount: downloadCount,
              onLikedTap: () => context.push(
                '/profile/favorites/${FavoriteCollection.likedCollectionId}',
              ),
              onLikedLongPressStart: (LongPressStartDetails details) =>
                  _showCollectionActionMenu(
                    globalPosition: details.globalPosition,
                    collection: favoritesState.likedCollection,
                  ),
              onRecentTap: () => context.push('/profile/recent'),
              onDownloadTap: () => context.push('/profile/downloads'),
            ),
            const SizedBox(height: 14),
            WeeklyListeningCard(
              summary: weeklyListening,
              onReportTap: () => context.push('/profile/recent'),
            ),
            const SizedBox(height: 14),
            ProfileLocalEntry(
              trackCount: downloadCount,
              onTap: () => context.push('/profile/downloads'),
            ),
            const SizedBox(height: 14),
            _ProfileSectionHeader(onAddPressed: _handleAddPressed),
            if (visibleCollections.isNotEmpty) const SizedBox(height: 12),
            if (visibleCollections.isNotEmpty)
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const double gap = 12;
                  final double itemWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: <Widget>[
                      for (final FavoriteCollection collection
                          in visibleCollections)
                        SizedBox(
                          width: itemWidth,
                          child: ProfilePlaylistCard(
                            title: collection.name,
                            trackCount: favoritesState.itemCountForCollection(
                              collection.id,
                            ),
                            coverUrl: favoritesState
                                .itemsForCollection(collection.id)
                                .firstOrNull
                                ?.coverUrl,
                            isRemote: collection.isRemote,
                            updatedAt: collection.updatedAt,
                            onTap: () => context.push(
                              '/profile/favorites/${collection.id}',
                            ),
                            onLongPressStart: (LongPressStartDetails details) {
                              _showCollectionActionMenu(
                                globalPosition: details.globalPosition,
                                collection: collection,
                              );
                            },
                            onMenuPressed: (Offset globalPosition) {
                              _showCollectionActionMenu(
                                globalPosition: globalPosition,
                                collection: collection,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            if (shouldCollapse)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllCollections = !_showAllCollections;
                    });
                  },
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    _showAllCollections
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                  ),
                  label: Text(_showAllCollections ? '收起歌单' : '展开全部歌单'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            if (favoritePlaylists.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '收藏的歌单',
                  style: AppTextStyles.sectionTitle(Theme.of(context)),
                ),
              ),
              const SizedBox(height: 10),
              ...favoritePlaylists.map((HotPlaylist playlist) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProfilePlaylistCard(
                    title: playlist.name,
                    trackCount: playlist.trackCount,
                    coverUrl: playlist.coverUrl,
                    badgeLabel: playlist.platform.label,
                    onTap: () => context.push(
                      '/home/playlist/${playlist.platform.name}/${playlist.id}',
                      extra: playlist,
                    ),
                    onLongPressStart: (LongPressStartDetails details) =>
                        _removeFavoritePlaylist(playlist),
                    onMenuPressed: (Offset _) =>
                        _removeFavoritePlaylist(playlist),
                  ),
                );
              }),
            ],
            const SizedBox(height: 14),
            FollowedUpsCard(
              ups: followedUps,
              onTap: () => context.push('/profile/favorite-ups'),
            ),
            const SizedBox(height: 18),
            ProfileVersionFooter(onTap: () => context.push('/settings/about')),
            const BottomPageSpacer(),
          ],
        ),
      ),
    );
  }

  WeeklyListeningSummary _weeklyListeningSummary() {
    try {
      return ref.watch(weeklyListeningProvider);
    } on Object {
      return const WeeklyListeningSummary();
    }
  }

  List<FavoriteUp> _followedUps() {
    try {
      return ref.watch(favoriteUpControllerProvider);
    } on Object {
      return const <FavoriteUp>[];
    }
  }

  Future<void> _removeFavoritePlaylist(HotPlaylist playlist) async {
    await ref.read(favoriteHotPlaylistsProvider.notifier).toggle(playlist);
    if (!mounted) {
      return;
    }
    _showMessage('已取消收藏“${playlist.name}”');
  }

  Future<void> _showCreateCollectionDialog(BuildContext context) async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return const _CollectionNameDialog(
          title: '新建歌单',
          hintText: '例如：深夜循环',
          confirmText: '创建',
        );
      },
    );

    if (result == null || result.trim().isEmpty) {
      if (result != null) {
        _showMessage('歌单名称不能为空');
      }
      return;
    }

    if (!context.mounted) return;

    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    final FavoriteCollection? collection = await controller.createCollection(
      result,
    );
    if (!mounted) {
      return;
    }

    if (collection == null) {
      _showMessage('歌单名称已存在');
    }
  }

  Future<void> _showRemoteImportDialog() async {
    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    final FavoriteCollection? collection = await showDialog<FavoriteCollection>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return RemoteCollectionImportDialog(
          collectionsFuture: controller.fetchImportableRemoteCollections(),
        );
      },
    );

    if (!mounted || collection == null) {
      return;
    }

    final _RemoteImportMode? mode = await showDialog<_RemoteImportMode>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('导入“${collection.name}”'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_RemoteImportMode.localCopy),
              child: const ListTile(
                leading: Icon(Icons.playlist_add_check_rounded),
                title: Text('导入为本地歌单'),
                subtitle: Text('拷贝一份到本地，之后 B 站改动不影响这里'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_RemoteImportMode.bindAndSync),
              child: const ListTile(
                leading: Icon(Icons.sync_rounded),
                title: Text('绑定并保持同步'),
                subtitle: Text('与 B 站收藏夹双向同步，增删会同步到 B 站'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
    if (!mounted || mode == null) return;

    if (mode == _RemoteImportMode.localCopy) {
      final FavoriteCollection? created = await controller
          .importRemoteCollectionAsLocal(collection);
      if (!mounted) {
        return;
      }
      _showMessage(
        created == null ? '导入失败，请稍后重试' : '已导入为本地歌单“${created.name}”',
      );
      return;
    }

    await controller.bindRemoteCollection(collection);
    await controller.refreshRemoteCollectionItems(collectionId: collection.id);
    if (!mounted) {
      return;
    }
    _showMessage('已绑定“${collection.name}”，将保持同步');
  }

  Future<void> _refreshRemoteCollectionsOnEnter() async {
    if (_didRefreshRemoteCollections || _isRefreshingRemoteCollections) {
      return;
    }

    final BiliSession? session = ref.read(biliSessionControllerProvider);
    if (!(session?.isLoggedIn ?? false)) {
      return;
    }

    _didRefreshRemoteCollections = true;
    _isRefreshingRemoteCollections = true;
    try {
      await ref
          .read(favoritesControllerProvider.notifier)
          .refreshRemoteCollections();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      if (LoginPrompt.handle(context, error, reason: '网络歌单需要重新登录')) {
        return;
      }
      _showMessage('网络歌单同步失败，请稍后重试');
    } finally {
      _isRefreshingRemoteCollections = false;
    }
  }

  Future<void> _handleAddPressed() async {
    final bool isLoggedIn =
        (ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false);
    final _AddAction? action = await showModalBottomSheet<_AddAction>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('新建歌单'),
                subtitle: const Text('只在本地保存，不同步 B 站'),
                onTap: () => Navigator.of(context).pop(_AddAction.localCreate),
              ),
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: const Text('从 B站收藏夹导入'),
                  subtitle: const Text('默认拷贝一份到本地，也可选择绑定同步'),
                  onTap: () =>
                      Navigator.of(context).pop(_AddAction.remoteImport),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _AddAction.localCreate:
        await _showCreateCollectionDialog(context);
      case _AddAction.remoteImport:
        if (!isLoggedIn) {
          LoginPrompt.show(context, reason: '导入 B站收藏夹需要登录 B 站账号');
          return;
        }
        await _showRemoteImportDialog();
    }
  }

  Future<void> _showCollectionActionMenu({
    required Offset globalPosition,
    required FavoriteCollection collection,
  }) async {
    // 没有可操作项（例如「我喜欢」这种系统歌单）时不弹空菜单。
    if (collection.isSystem && !collection.isRemote) {
      return;
    }
    final OverlayState overlay = Overlay.of(context);
    final RenderBox overlayBox =
        overlay.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition.translate(1, 1)),
      Offset.zero & overlayBox.size,
    );

    HapticFeedback.lightImpact();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final _CollectionAction? action = await showMenu<_CollectionAction>(
      context: context,
      position: position,
      // 菜单用纯白底，不跟随主题的浅色容器色（绿色调）。
      color: isDark ? null : Colors.white,
      items: <PopupMenuEntry<_CollectionAction>>[
        if (!collection.isSystem)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.rename,
            child: ListTile(
              leading: Icon(Icons.drive_file_rename_outline_rounded),
              title: const Text('重命名'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (collection.isRemote)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.sync,
            child: ListTile(
              leading: Icon(Icons.sync_rounded),
              title: Text('同步'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (collection.isRemote)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.remove,
            child: ListTile(
              leading: Icon(Icons.remove_circle_outline_rounded),
              title: Text('解除绑定'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (!collection.isSystem && !collection.isRemote)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.uploadToRemote,
            child: ListTile(
              leading: Icon(Icons.cloud_upload_outlined),
              title: Text('上传到 B 站并同步'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (!collection.isSystem)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline_rounded),
              title: Text('删除'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (!collection.isSystem || collection.isRemote)
          const PopupMenuDivider(),
      ],
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _CollectionAction.rename:
        await _showRenameCollectionDialog(collection);
      case _CollectionAction.sync:
        await _syncRemoteCollection(collection);
      case _CollectionAction.uploadToRemote:
        await _uploadCollectionToRemote(collection);
      case _CollectionAction.delete:
        await _showDeleteCollectionDialog(collection);
      case _CollectionAction.remove:
        await _showRemoveRemoteCollectionDialog(collection);
    }
  }

  Future<void> _syncRemoteCollection(FavoriteCollection collection) async {
    _showMessage('正在同步“${collection.name}”…');
    try {
      await ref
          .read(favoritesControllerProvider.notifier)
          .syncRemoteCollectionIfStale(collection.id, force: true);
      if (!mounted) {
        return;
      }
      _showMessage('同步完成');
    } on Object {
      if (!mounted) {
        return;
      }
      _showMessage('同步失败，请稍后重试');
    }
  }

  Future<void> _uploadCollectionToRemote(FavoriteCollection collection) async {
    final bool isLoggedIn =
        ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false;
    if (!isLoggedIn) {
      LoginPrompt.show(context, reason: '上传到 B 站需要登录 B 站账号');
      return;
    }
    _showMessage('正在上传“${collection.name}”到 B 站…');
    try {
      final FavoriteCollection? uploaded = await ref
          .read(favoritesControllerProvider.notifier)
          .uploadLocalCollectionToRemote(collection.id);
      if (!mounted) {
        return;
      }
      _showMessage(uploaded == null ? '上传失败，请稍后重试' : '已上传到 B 站，之后增删会双向同步');
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('上传失败：$error');
    }
  }

  Future<void> _showRenameCollectionDialog(
    FavoriteCollection collection,
  ) async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return _CollectionNameDialog(
          title: '重命名歌单',
          hintText: '请输入歌单名称',
          confirmText: '保存',
          initialValue: collection.name,
        );
      },
    );

    if (result == null) {
      return;
    }

    final String trimmedName = result.trim();
    if (trimmedName.isEmpty) {
      _showMessage('歌单名称不能为空');
      return;
    }

    if (trimmedName == collection.name.trim()) {
      return;
    }

    final bool renamed = await ref
        .read(favoritesControllerProvider.notifier)
        .renameCollection(collectionId: collection.id, name: trimmedName);
    if (!mounted) {
      return;
    }

    _showMessage(renamed ? '已重命名歌单' : '歌单名称已存在');
  }

  Future<void> _showDeleteCollectionDialog(
    FavoriteCollection collection,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除歌单'),
          content: Text(
            collection.isRemote
                ? '确认删除“${collection.name}”？这会同时删除 B 站收藏夹，无法恢复。'
                : '确认删除“${collection.name}”？删除后无法恢复。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool deleted = await ref
        .read(favoritesControllerProvider.notifier)
        .deleteCollection(collection.id);
    if (!mounted) {
      return;
    }
    ToastUtil.show(deleted ? '已删除歌单' : '删除失败');
  }

  Future<void> _showRemoveRemoteCollectionDialog(
    FavoriteCollection collection,
  ) async {
    if (!collection.isRemote) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('解除绑定'),
          content: Text(
            '确认解除“${collection.name}”与 App 的绑定？只会从列表移除，不会删除 B 站收藏夹。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('解除绑定'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool removed = await ref
        .read(favoritesControllerProvider.notifier)
        .removeRemoteCollection(collection.id);
    if (!mounted) {
      return;
    }
    ToastUtil.show(removed ? '已解除绑定' : '解除绑定失败');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ToastUtil.show(message);
  }
}

enum _CollectionAction { rename, delete, remove, sync, uploadToRemote }

enum _AddAction { localCreate, remoteImport }

enum _RemoteImportMode { localCopy, bindAndSync }

class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog({
    required this.title,
    required this.hintText,
    required this.confirmText,
    this.initialValue = '',
  });

  final String title;
  final String hintText;
  final String confirmText;
  final String initialValue;

  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: 24,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (String value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Row(
      children: <Widget>[
        Text(
          '我的歌单',
          style: TextStyle(
            fontSize: 17,
            height: 1.2,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onAddPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add_rounded, size: 17, color: colorScheme.primary),
                  const SizedBox(width: 2),
                  Text(
                    '新建',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
