import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/router/shell/components/mobile_bottom_bar.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Test song',
  author: 'Test artist',
  coverUrl: '',
);
const Key _viewportKey = Key('page viewport');
const Key _lastItemKey = Key('last item');

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'test',
      version: 'invalid',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  for (final bool glass in <bool>[false, true]) {
    for (final double inset in <double>[0, 34]) {
      testWidgets(
        'bottom bar composes player row and tabs glass=$glass inset=$inset',
        (WidgetTester tester) async {
          await _pumpShell(tester, glass: glass, inset: inset);
          final Finder bar = find.byType(MobileBottomBar);
          final _FakePlayerController controller = _controllerOf(tester);

          expect(bar, findsOneWidget);
          expect(
            find.descendant(
              of: bar,
              matching: find.text('Test song - Test artist'),
            ),
            findsOneWidget,
          );
          for (final String label in <String>['首页', '刷歌', '我的']) {
            expect(
              find.descendant(of: bar, matching: find.text(label)),
              findsOneWidget,
            );
          }
          expect(find.byIcon(Icons.home), findsOneWidget);
          expect(find.byIcon(Icons.home_outlined), findsNothing);
          expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
          expect(find.byTooltip('播放'), findsOneWidget);
          expect(find.byTooltip('播放队列'), findsOneWidget);
          expect(find.byTooltip('我喜欢'), findsOneWidget);
          expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
          expect(
            tester.getSize(find.byType(MiniPlayerArtwork)),
            const Size(36, 36),
          );
          expect(
            tester.getSize(find.byType(LinearProgressIndicator)),
            const Size(388, 2),
          );
          expect(tester.getSize(bar).height, 122 + inset);
          expect(tester.getRect(bar).bottom, 900);
          expect(_spacerHeight(tester), 138 + inset);

          if (glass) {
            final GlassPanel panel = tester.widget<GlassPanel>(
              find.descendant(of: bar, matching: find.byType(GlassPanel)),
            );
            expect(panel.tone, GlassTone.frost);
            expect(panel.shape, isA<LiquidVerticalRoundedSuperellipse>());
            final LiquidVerticalRoundedSuperellipse shape =
                panel.shape as LiquidVerticalRoundedSuperellipse;
            expect(shape.topRadius, mobileBottomBarRadius);
            expect(shape.bottomRadius, 0);
          } else {
            final DecoratedBox surface = tester.widget<DecoratedBox>(
              find
                  .descendant(of: bar, matching: find.byType(DecoratedBox))
                  .first,
            );
            final BoxDecoration decoration =
                surface.decoration as BoxDecoration;
            expect(
              decoration.borderRadius,
              const BorderRadius.vertical(
                top: Radius.circular(mobileBottomBarRadius),
              ),
            );
            expect(decoration.border?.top.width, 0.8);
            expect(
              find.descendant(of: bar, matching: find.byType(GlassPanel)),
              findsNothing,
            );
          }

          await tester.tap(find.byTooltip('播放'));
          expect(controller.toggleCalls, 1);
          expect(tester.takeException(), isNull);
          await _disposeShell(tester);
        },
      );
    }
  }

  testWidgets('bottom bar keeps its fixed heights at 2x text scale', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, scale: 2);
    final Finder bar = find.byType(MobileBottomBar);

    expect(bar, findsOneWidget);
    expect(tester.getSize(bar).height, 122);
    expect(tester.getSize(find.byType(MiniPlayerArtwork)), const Size(36, 36));
    expect(
      tester.getSize(find.byType(LinearProgressIndicator)),
      const Size(388, 2),
    );
    expect(
      find.descendant(of: bar, matching: find.text('Test song - Test artist')),
      findsOneWidget,
    );
    expect(_spacerHeight(tester), 138);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets('detail routes keep the player row and drop the tab row', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpShell(tester);
    router.go('/profile/downloads');
    await tester.pumpAndSettle();
    final Finder bar = find.byType(MobileBottomBar);

    expect(bar, findsOneWidget);
    expect(find.byType(MiniPlayerArtwork), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    for (final String label in <String>['首页', '刷歌', '我的']) {
      expect(find.text(label), findsNothing);
    }
    expect(tester.getSize(bar).height, 72);
    expect(tester.getRect(bar).bottom, 900);
    expect(_spacerHeight(tester), 88);
    expect(tester.getRect(find.byKey(_viewportKey)).bottom, 900);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets('player page and full screen routes hide the whole bar', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpShell(tester, inset: 34);

    expect(find.byType(MobileBottomBar), findsOneWidget);
    expect(_spacerHeight(tester), 172);

    markPlayerPageVisible();
    await tester.pumpAndSettle();
    expect(find.byType(MobileBottomBar), findsNothing);
    expect(find.text('首页'), findsNothing);
    expect(_spacerHeight(tester), 16);
    expect(tester.getRect(find.byKey(_viewportKey)).bottom, 900);

    markPlayerPageHidden();
    await tester.pumpAndSettle();
    expect(find.byType(MobileBottomBar), findsOneWidget);
    expect(_spacerHeight(tester), 172);

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.byType(MobileBottomBar), findsNothing);
    expect(find.text('首页'), findsNothing);
    expect(_spacerHeight(tester), 16);

    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.byType(MobileBottomBar), findsOneWidget);
    expect(_spacerHeight(tester), 172);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets(
    'appearance toggle swaps the bar material without moving layout',
    (WidgetTester tester) async {
      await _pumpShell(tester);
      final Finder bar = find.byType(MobileBottomBar);
      final _FakeAppearance appearance = _appearanceOf(tester);

      expect(
        find.descendant(of: bar, matching: find.byType(GlassPanel)),
        findsNothing,
      );
      expect(tester.getSize(bar).height, 122);
      expect(_spacerHeight(tester), 138);

      appearance.setGlass(true);
      await tester.pumpAndSettle();
      expect(bar, findsOneWidget);
      expect(
        find.descendant(of: bar, matching: find.byType(GlassPanel)),
        findsOneWidget,
      );
      expect(tester.getSize(bar).height, 122);
      expect(_spacerHeight(tester), 138);

      appearance.setGlass(false);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: bar, matching: find.byType(GlassPanel)),
        findsNothing,
      );
      expect(tester.getSize(bar).height, 122);
      expect(_spacerHeight(tester), 138);
      expect(tester.takeException(), isNull);
      await _disposeShell(tester);
    },
  );

  testWidgets('tapping tabs switches branches and highlights the selection', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpShell(tester);

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsNothing);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    expect(find.byType(MobileBottomBar), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
    expect(find.byIcon(Icons.home), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(_spacerHeight(tester), 138);

    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/home');
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets('bottom page spacer follows the composed bar height', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpShell(tester);
    final _FakePlayerController controller = _controllerOf(tester);
    final Finder bar = find.byType(MobileBottomBar);

    expect(tester.getSize(bar).height, 122);
    expect(_spacerHeight(tester), 138);

    controller.clear();
    await tester.pumpAndSettle();
    expect(bar, findsOneWidget);
    expect(find.byType(MiniPlayerArtwork), findsNothing);
    expect(find.text('首页'), findsOneWidget);
    expect(tester.getSize(bar).height, 58);
    expect(_spacerHeight(tester), 74);

    controller.load();
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, 122);
    expect(_spacerHeight(tester), 138);

    router.go('/profile/downloads');
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, 72);
    expect(_spacerHeight(tester), 88);

    markPlayerPageVisible();
    await tester.pumpAndSettle();
    expect(bar, findsNothing);
    expect(_spacerHeight(tester), 16);

    markPlayerPageHidden();
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, 72);
    expect(_spacerHeight(tester), 88);

    router.go('/home');
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, 122);
    expect(_spacerHeight(tester), 138);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets('keyboard keeps the page usable and restores the spacer', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, inset: 34);
    final double spacing = _spacerHeight(tester);
    expect(spacing, 172);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.view.padding = FakeViewPadding.zero;
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_viewportKey)).bottom, 600);
    expect(find.byType(MobileBottomBar), findsOneWidget);
    await tester.drag(find.byKey(_viewportKey), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(_lastItemKey)).bottom,
      lessThanOrEqualTo(600),
    );
    expect(tester.takeException(), isNull);

    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    await tester.pumpAndSettle();
    expect(_spacerHeight(tester), spacing);
    expect(tester.getRect(find.byKey(_viewportKey)).bottom, 900);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets('page content scrolls clear of the bottom bar', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester);
    final Rect barRect = tester.getRect(find.byType(MobileBottomBar));

    await tester.drag(find.byKey(_viewportKey), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(_lastItemKey)).bottom,
      closeTo(barRect.top - 16, 0.01),
    );

    await tester.drag(find.byKey(_viewportKey), const Offset(0, 1500));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(_lastItemKey)).bottom,
      greaterThan(barRect.bottom),
    );
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });
}

double _spacerHeight(WidgetTester tester) =>
    tester.getSize(find.byType(BottomPageSpacer)).height;

_FakePlayerController _controllerOf(WidgetTester tester) {
  return ProviderScope.containerOf(
        tester.element(find.byType(MobileShellScaffold)),
      ).read(playerControllerProvider.notifier)
      as _FakePlayerController;
}

_FakeAppearance _appearanceOf(WidgetTester tester) {
  return ProviderScope.containerOf(
        tester.element(find.byType(MobileShellScaffold)),
      ).read(appearanceSettingLogicProvider.notifier)
      as _FakeAppearance;
}

Future<GoRouter> _pumpShell(
  WidgetTester tester, {
  bool glass = false,
  Brightness brightness = Brightness.light,
  double inset = 0,
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = FakeViewPadding(bottom: inset);
  tester.view.padding = FakeViewPadding(bottom: inset);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetPadding);
  addTearDown(markPlayerPageHidden);
  final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MobileShellScaffold(
          navigationShell: shell,
          currentLocation: state.uri.path,
          chrome: MobileChromeConfig.resolve(state.uri.path),
        ),
        branches: <StatefulShellBranch>[
          for (final String path in <String>[
            '/home',
            '/radar',
            '/profile',
            '/profile/downloads',
            '/settings',
          ])
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(path: path, builder: (_, _) => const _TestPage()),
              ],
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
        playerDisplayProvider.overrideWithValue(
          const PlayerDisplayInfo(title: 'Test song', artist: 'Test artist'),
        ),
        appearanceSettingLogicProvider.overrideWith(
          () => _FakeAppearance(glass),
        ),
        favoritesControllerProvider.overrideWith(_FakeFavoritesController.new),
      ],
      child: MaterialApp.router(
        theme: ThemeData(brightness: brightness),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _disposeShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

class _TestPage extends StatelessWidget {
  const _TestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page')),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          key: _viewportKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 1100),
              TextButton(
                key: _lastItemKey,
                onPressed: () {},
                child: const Text('Last item'),
              ),
              const BottomPageSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakePlayerController extends PlayerController {
  int toggleCalls = 0;

  @override
  PlayerState build() => const PlayerState(currentItem: _item);

  void clear() => state = const PlayerState();
  void load() => state = const PlayerState(currentItem: _item);

  @override
  Future<void> togglePlayback() async => toggleCalls++;
}

class _FakeAppearance extends AppearanceSettingLogic {
  _FakeAppearance(this.glass);
  final bool glass;

  @override
  bool build() => glass;

  void setGlass(bool value) => state = value;
}

class _FakeFavoritesController extends FavoritesController {
  @override
  FavoritesState build() => const FavoritesState();
}
