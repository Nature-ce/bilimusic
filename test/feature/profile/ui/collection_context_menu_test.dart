import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/bili_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/profile/ui/desktop_profile_sidebar.dart';
import 'package:bilimusic/feature/profile/ui/profile_page.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bool desktop in <bool>[true, false]) {
    for (final String id in <String>[
      'local',
      'remote:1',
      FavoriteCollection.likedCollectionId,
    ]) {
      testWidgets(
        '${desktop ? 'desktop secondary-click' : 'mobile long-press'} $id opens the action menu',
        (WidgetTester tester) async {
          final DateTime now = DateTime(2026);
          final FavoriteCollection collection = FavoriteCollection(
            id: id,
            name: '测试歌单',
            source: id.startsWith('remote:')
                ? FavoriteCollectionSource.remote
                : FavoriteCollectionSource.local,
            remoteId: id.startsWith('remote:') ? '1' : null,
            isSystem: id == FavoriteCollection.likedCollectionId,
            createdAt: now,
            updatedAt: now,
          );
          await _pumpProfile(
            tester,
            desktop: desktop,
            favorites: _Favorites(FavoritesState(collections: [collection])),
            loggedIn: collection.isRemote,
          );
          final Finder collectionTile = find.text(
            collection.isSystem ? (desktop ? '我喜欢·0' : '我喜欢') : collection.name,
          );
          final List<String> actions = <String>[
            if (!collection.isSystem)
              collection.isRemote ? '重命名 B 站收藏夹' : '重命名',
            if (collection.isRemote) '同步',
            if (collection.isRemote) '解除绑定',
            if (!collection.isSystem && !collection.isRemote) '上传到 B 站并同步',
            if (!collection.isSystem) '删除',
          ];
          if (desktop) {
            await tester.tap(
              collectionTile,
              kind: PointerDeviceKind.mouse,
              buttons: kSecondaryMouseButton,
            );
          } else {
            await tester.longPress(collectionTile);
          }
          await tester.pumpAndSettle();
          if (actions.isEmpty) {
            // 系统歌单没有可操作项时不应该弹出空菜单。
            expect(find.text('修改类型'), findsNothing);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            return;
          }
          final Finder menuText = find.descendant(
            of: find.byWidgetPredicate(
              (Widget widget) => desktop
                  ? widget is CommonAttachMenu<Object?>
                  : widget is PopupMenuEntry<Object?>,
            ),
            matching: find.byType(Text),
          );
          expect(
            tester
                .widgetList<Text>(menuText)
                .map((Text text) => text.data)
                .toList(),
            actions,
          );
          for (int index = 1; index < actions.length; index += 1) {
            expect(
              tester.getCenter(find.text(actions[index - 1])).dy,
              lessThan(tester.getCenter(find.text(actions[index])).dy),
            );
          }
          expect(find.text('修改类型'), findsNothing);
          expect(find.text('歌曲'), findsNothing);
          expect(find.text('听声'), findsNothing);
          expect(tester.takeException(), isNull);
          final Future<void> dismiss = SmartDialog.dismiss<void>();
          await tester.pumpAndSettle();
          await dismiss;
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }

    for (final String flow in <String>['local', 'bind', 'importLocal']) {
      testWidgets(
        '${desktop ? 'desktop' : 'mobile'} $flow does not ask for a collection type',
        (WidgetTester tester) async {
          final _Favorites favorites = _Favorites(const FavoritesState());
          final ProviderContainer container = await _pumpProfile(
            tester,
            desktop: desktop,
            favorites: favorites,
            loggedIn: true,
          );
          await tester.tap(
            desktop ? find.byTooltip('添加歌单') : find.byIcon(Icons.add_rounded),
          );
          await tester.pumpAndSettle();
          if (flow == 'local') {
            await tester.tap(find.text('新建歌单'));
            await tester.pumpAndSettle();
            await tester.enterText(find.byType(TextField), '新的歌单');
            await tester.tap(find.text('创建'));
            await tester.pumpAndSettle();
            expect(find.text('选择歌单类型'), findsNothing);
            expect(find.text('听声'), findsNothing);
            final FavoriteCollection created = container
                .read(favoritesControllerProvider)
                .collections
                .single;
            expect(created.name, '新的歌单');
            expect(created.kind, CollectionKind.music);
            expect(favorites.createCalls, 1);
          } else {
            await tester.tap(find.text('从 B站收藏夹导入'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('待导入收藏夹'));
            await tester.pumpAndSettle();
            expect(find.text('选择歌单类型'), findsNothing);
            expect(find.text('听声'), findsNothing);
            expect(favorites.bindCalls, 0);
            expect(favorites.importLocalCalls, 0);
            await tester.tap(find.text(flow == 'bind' ? '绑定并保持同步' : '导入为本地歌单'));
            await tester.pumpAndSettle();
            if (flow == 'bind') {
              expect(favorites.bindCalls, 1);
              expect(favorites.refreshCalls, 1);
              expect(favorites.importLocalCalls, 0);
            } else {
              expect(favorites.importLocalCalls, 1);
              expect(favorites.lastImportKind, isNull);
              expect(favorites.bindCalls, 0);
            }
          }
          expect(tester.takeException(), isNull);
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();
        },
      );
    }
  }

  testWidgets('mobile playlist settings button opens the action menu', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime(2026);
    final FavoriteCollection collection = FavoriteCollection(
      id: 'local',
      name: '测试歌单',
      source: FavoriteCollectionSource.local,
      createdAt: now,
      updatedAt: now,
    );
    await _pumpProfile(
      tester,
      desktop: false,
      favorites: _Favorites(FavoritesState(collections: [collection])),
    );

    expect(find.byTooltip('歌单设置'), findsOneWidget);

    await tester.tap(find.byTooltip('歌单设置'));
    await tester.pumpAndSettle();

    final Finder menuText = find.descendant(
      of: find.byWidgetPredicate(
        (Widget widget) => widget is PopupMenuEntry<Object?>,
      ),
      matching: find.byType(Text),
    );
    expect(
      tester.widgetList<Text>(menuText).map((Text text) => text.data).toList(),
      <String>['重命名', '上传到 B 站并同步', '删除'],
    );
    expect(tester.takeException(), isNull);
  });
}

Future<ProviderContainer> _pumpProfile(
  WidgetTester tester, {
  required bool desktop,
  required _Favorites favorites,
  bool loggedIn = false,
}) async {
  tester.view.physicalSize = desktop
      ? const Size(1000, 800)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer container = ProviderContainer(
    overrides: [
      favoritesControllerProvider.overrideWith(() => favorites),
      biliSessionControllerProvider.overrideWithValue(
        loggedIn
            ? const BiliSession(
                sessData: 'test',
                biliJct: 'test',
                dedeUserId: '1',
                refreshToken: '',
                cookie: '',
              )
            : null,
      ),
      favoriteUpControllerProvider.overrideWithValue(const <FavoriteUp>[]),
      recentPlaybackControllerProvider.overrideWithValue(
        const <RecentPlaybackEntry>[],
      ),
      downloadControllerProvider.overrideWith(_EmptyDownloads.new),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: FlutterSmartDialog.init(),
        home: desktop
            ? const Scaffold(
                body: Align(
                  alignment: Alignment.centerLeft,
                  child: DesktopProfileSidebar(currentLocation: '/profile'),
                ),
              )
            : const ProfilePage(),
      ),
    ),
  );
  addTearDown(() async {
    final Future<void> dismiss = SmartDialog.dismiss();
    final Future<void> dismissToasts = SmartDialog.dismiss(
      status: SmartStatus.allToast,
    );
    await tester.pumpAndSettle();
    await dismiss;
    await dismissToasts;
    await tester.pumpWidget(const SizedBox.shrink());
  });
  await tester.pumpAndSettle();
  return container;
}

class _Favorites extends FavoritesController {
  _Favorites(this.initial);

  final FavoritesState initial;
  int createCalls = 0;
  int bindCalls = 0;
  int refreshCalls = 0;

  @override
  FavoritesState build() => initial;

  @override
  Future<void> refreshRemoteCollections() async {}

  @override
  Future<FavoriteCollection?> createCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async {
    createCalls++;
    final DateTime now = DateTime(2026);
    final FavoriteCollection collection = FavoriteCollection(
      id: 'new_local',
      name: name,
      kind: kind,
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  @override
  Future<FavoriteCollection?> createRemoteCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async {
    createCalls++;
    final FavoriteCollection collection = _remoteCollection.copyWith(
      name: name,
      kind: kind,
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  FavoriteCollection get _remoteCollection => FavoriteCollection(
    id: 'remote:2',
    name: '待导入收藏夹',
    source: FavoriteCollectionSource.remote,
    remoteId: '2',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  int importLocalCalls = 0;
  CollectionKind? lastImportKind;

  @override
  Future<FavoriteCollection?> importRemoteCollectionAsLocal(
    FavoriteCollection remote, {
    CollectionKind? kind,
  }) async {
    importLocalCalls++;
    lastImportKind = kind;
    final DateTime now = DateTime(2026);
    final FavoriteCollection collection = FavoriteCollection(
      id: 'custom_imported',
      name: remote.name,
      kind: kind ?? remote.kind,
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  @override
  Future<List<FavoriteCollection>> fetchImportableRemoteCollections() async => [
    _remoteCollection,
  ];

  @override
  Future<void> bindRemoteCollection(FavoriteCollection collection) async {
    bindCalls++;
    state = state.copyWith(collections: [...state.collections, collection]);
  }

  @override
  Future<BiliFavoriteCollectionPage?> refreshRemoteCollectionItems({
    required String collectionId,
    int pageNumber = 1,
  }) async {
    refreshCalls++;
    return null;
  }
}

class _EmptyDownloads extends DownloadController {
  @override
  DownloadState build() => const DownloadState();
}
