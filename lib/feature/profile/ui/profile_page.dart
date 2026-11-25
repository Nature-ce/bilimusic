import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_action_menu.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_name_dialog.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist.dart';
import 'package:bilimusic/feature/home/logic/favorite_hot_playlist_controller.dart';
import 'package:bilimusic/feature/profile/ui/components/playlist_wall.dart';
import 'package:bilimusic/feature/profile/ui/components/profile_stats_card.dart';
import 'package:bilimusic/feature/profile/ui/components/remote_collection_import_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:bilimusic/feature/profile/ui/components/weekly_listening_card.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/logic/weekly_listening.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
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
    final List<HotPlaylist> favoritePlaylists = ref.watch(
      favoriteHotPlaylistsProvider,
    );
    final WeeklyListeningSummary weeklyListening = _weeklyListeningSummary();

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
              onReportTap: () => context.push('/profile/report'),
            ),
            const SizedBox(height: 14),
            _ProfileSectionHeader(onAddPressed: _handleAddPressed),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final FavoriteCollection collection in collections)
                    Padding(
                      padding: const EdgeInsets.only(right: playlistWallGap),
                      child: PlaylistWallCard(
                        title: collection.name,
                        trackCount: favoritesState.itemCountForCollection(
                          collection.id,
                        ),
                        coverUrl: favoritesState
                            .itemsForCollection(collection.id)
                            .firstOrNull
                            ?.coverUrl,
                        updatedAt: collection.updatedAt,
                        onTap: () =>
                            context.push('/profile/favorites/${collection.id}'),
                        onLongPressStart: (LongPressStartDetails details) {
                          _showCollectionActionMenu(
                            globalPosition: details.globalPosition,
                            collection: collection,
                          );
                        },
                      ),
                    ),
                ],
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final HotPlaylist playlist in favoritePlaylists)
                      Padding(
                        padding: const EdgeInsets.only(right: playlistWallGap),
                        child: PlaylistWallCard(
                          title: playlist.name,
                          trackCount: playlist.trackCount,
                          coverUrl: playlist.coverUrl,
                          platform: playlist.platform,
                          coverSize: favoritePlaylistWallCoverSize,
                          onTap: () => context.push(
                            '/home/playlist/${playlist.platform.name}/${playlist.id}',
                            extra: playlist,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
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

  Future<void> _showCreateCollectionDialog(BuildContext context) async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return CollectionNameDialog(
          title: '新建歌单',
          hintText: '例如：深夜循环',
          confirmText: '创建',
          glass: ref.read(appearanceSettingLogicProvider),
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
          glass: ref.read(appearanceSettingLogicProvider),
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
    final bool useGlass = ref.read(appearanceSettingLogicProvider);
    Widget buildSheetContent(BuildContext sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.playlist_add_rounded),
            title: const Text('新建歌单'),
            subtitle: const Text('只在本地保存，不同步 B 站'),
            onTap: () => Navigator.of(sheetContext).pop(_AddAction.localCreate),
          ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('从 B站收藏夹导入'),
              subtitle: const Text('默认拷贝一份到本地，也可选择绑定同步'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AddAction.remoteImport),
            ),
          const SizedBox(height: 8),
        ],
      );
    }

    final _AddAction? action = useGlass
        ? await showAppHalfSheet<_AddAction>(
            context: context,
            builder: buildSheetContent,
          )
        : await showModalBottomSheet<_AddAction>(
            context: context,
            showDragHandle: true,
            useRootNavigator: true,
            builder: (BuildContext sheetContext) =>
                SafeArea(child: buildSheetContent(sheetContext)),
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
  }) {
    return showFavoriteCollectionActionMenu(
      context: context,
      ref: ref,
      collection: collection,
      globalPosition: globalPosition,
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ToastUtil.show(message);
  }
}

enum _AddAction { localCreate, remoteImport }

enum _RemoteImportMode { localCopy, bindAndSync }

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
