import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

PlayableItem _item(int index) {
  return PlayableItem(
    aid: index + 1,
    bvid: 'BV$index',
    title: '队列歌曲$index',
    author: 'UP主',
    coverUrl: '',
  );
}

class _ReorderablePlayer extends PlayerController {
  final List<(int, int)> reorders = <(int, int)>[];

  @override
  PlayerState build() => PlayerState(
    currentItem: _item(0),
    queue: <PlayableItem>[_item(0), _item(1), _item(2)],
    currentQueueIndex: 0,
    queueSourceLabel: '测试队列',
  );

  @override
  Future<void> reorderQueueItem(int oldIndex, int newIndex) async {
    reorders.add((oldIndex, newIndex));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {}

  @override
  Future<void> clearQueue() async {}

  @override
  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {}
}

class _FancyTextPlayer extends PlayerController {
  @override
  PlayerState build() => PlayerState(
    currentItem: const PlayableItem(
      aid: 1,
      bvid: 'BVfancy',
      title: '【𝐇𝐢-𝐑𝐞𝐬无损臻享】《Hong Kong》',
      author: '𝙅𝙪𝙡𝙞𝙚',
      coverUrl: '',
      pageTitle: '𝙋𝙡𝙖𝙮𝙡𝙞𝙨𝙩 秋季歌单',
    ),
    queue: const <PlayableItem>[
      PlayableItem(
        aid: 1,
        bvid: 'BVfancy',
        title: '【𝐇𝐢-𝐑𝐞𝐬无损臻享】《Hong Kong》',
        author: '𝙅𝙪𝙡𝙞𝙚',
        coverUrl: '',
        pageTitle: '𝙋𝙡𝙖𝙮𝙡𝙞𝙨𝙩 秋季歌单',
      ),
    ],
    currentQueueIndex: 0,
    queueSourceLabel: '测试队列',
  );

  @override
  Future<void> reorderQueueItem(int oldIndex, int newIndex) async {}

  @override
  Future<void> removeQueueItemAt(int index) async {}

  @override
  Future<void> clearQueue() async {}

  @override
  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {}
}

class _ModePlayer extends _ReorderablePlayer {
  _ModePlayer(this.mode);

  final PlayerQueueMode mode;

  @override
  PlayerState build() => super.build().copyWith(queueMode: mode);
}

Future<void> _openQueueSheet(
  WidgetTester tester,
  ProviderContainer container, {
  PlayerQueueSheetStyle style = PlayerQueueSheetStyle.home,
  bool glass = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: FilledButton(
                  onPressed: () => showPlayerQueueSheet(
                    context: context,
                    state: container.read(playerControllerProvider),
                    glass: glass,
                    style: style,
                  ),
                  child: const Text('打开队列'),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开队列'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dragging an item in the queue reorders it', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_ReorderablePlayer.new),
      ],
    );
    addTearDown(container.dispose);

    await _openQueueSheet(tester, container);

    expect(find.textContaining('队列歌曲0'), findsOneWidget);

    final Finder firstRow = find.textContaining('队列歌曲1');
    expect(firstRow, findsOneWidget);
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(firstRow),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 200));
    for (int step = 0; step < 8; step += 1) {
      await gesture.moveBy(const Offset(0, 14));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    final _ReorderablePlayer player =
        container.read(playerControllerProvider.notifier) as _ReorderablePlayer;
    expect(player.reorders, isNotEmpty);
    expect(player.reorders.first.$1, 1);
  });

  testWidgets('the queue sheet removes an item', (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_ReorderablePlayer.new),
      ],
    );
    addTearDown(container.dispose);

    await _openQueueSheet(tester, container);

    expect(find.byTooltip('移出队列'), findsWidgets);
  });

  testWidgets('decorative unicode in queue titles is normalized for display', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [playerControllerProvider.overrideWith(_FancyTextPlayer.new)],
    );
    addTearDown(container.dispose);

    await _openQueueSheet(tester, container);

    expect(find.textContaining('Playlist 秋季歌单'), findsOneWidget);
    expect(find.textContaining('Hi-Res无损臻享'), findsOneWidget);
    expect(find.textContaining('𝙋𝙡𝙖𝙮𝙡𝙞𝙨𝙩'), findsNothing);
    expect(find.textContaining('𝐇𝐢-𝐑𝐞𝐬'), findsNothing);
  });

  testWidgets('播放页队列弹层保持烟熏黑玻璃，文字为白色', (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_ReorderablePlayer.new),
      ],
    );
    addTearDown(container.dispose);

    await _openQueueSheet(
      tester,
      container,
      style: PlayerQueueSheetStyle.player,
    );

    // 播放页入口固定走烟熏玻璃，不跟随外观开关。
    final GlassContainer glass = tester.widget<GlassContainer>(
      find.byType(GlassContainer).first,
    );
    expect(glass.useOwnLayer, isTrue);
    expect(
      glass.settings?.glassColor,
      playerQueueSheetGlassSettings.glassColor,
    );
    expect(
      glass.settings?.backerColor,
      playerQueueSheetGlassSettings.backerColor,
    );

    final ModalBarrier barrier = tester.widget<ModalBarrier>(
      find.byType(ModalBarrier).last,
    );
    expect(barrier.color, Colors.black.withValues(alpha: 0.34));

    final Text title = tester.widget<Text>(find.text('播放队列'));
    expect(title.style?.color, GlassTone.smoke.primaryText);

    final Text subtitle = tester.widget<Text>(find.textContaining('项 ·'));
    expect(subtitle.style?.color, GlassTone.smoke.secondaryText);

    final Text pendingRow = tester.widget<Text>(find.textContaining('队列歌曲1'));
    expect(pendingRow.style?.color, GlassTone.smoke.primaryText);
  });

  testWidgets('首页队列弹层用更透的白雾玻璃，文字跟随主题', (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_ReorderablePlayer.new),
      ],
    );
    addTearDown(container.dispose);

    await _openQueueSheet(tester, container);

    final GlassContainer glass = tester.widget<GlassContainer>(
      find.byType(GlassContainer).first,
    );
    expect(glass.useOwnLayer, isTrue);
    final ColorScheme colorScheme = Theme.of(
      tester.element(find.text('播放队列')),
    ).colorScheme;
    final LiquidGlassSettings expected = homeQueueSheetGlassSettings(
      tester.element(find.text('播放队列')),
    );
    expect(glass.settings?.glassColor, expected.glassColor);
    expect(glass.settings?.backerColor, expected.backerColor);
    // 比播放页的烟熏玻璃更透明：背衬更淡、模糊更强。
    expect(
      expected.backerColor?.a ?? 0,
      lessThan(playerQueueSheetGlassSettings.backerColor?.a ?? 1),
    );
    expect(expected.blur, greaterThan(playerQueueSheetGlassSettings.blur));

    // 首页玻璃档不压暗背景。
    expect(
      tester
          .widgetList<ModalBarrier>(find.byType(ModalBarrier))
          .every((ModalBarrier barrier) => (barrier.color?.a ?? 0) < 0.2),
      isTrue,
    );

    final Text title = tester.widget<Text>(find.text('播放队列'));
    expect(title.style?.color, colorScheme.onSurface);

    final Text pendingRow = tester.widget<Text>(find.textContaining('队列歌曲1'));
    expect(pendingRow.style?.color, colorScheme.onSurface);

    // 行间分割线 + 标题分隔线。
    expect(find.byType(Divider), findsWidgets);

    // 清空是纯文字按钮（无背景色），模式按钮用主题色浅底。
    final TextButton clear = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '清空'),
    );
    expect(clear.style?.backgroundColor, isNull);
    final IconButton modeButton = tester
        .widgetList<IconButton>(find.byType(IconButton))
        .firstWhere(
          (IconButton button) =>
              button.style?.backgroundColor?.resolve(<WidgetState>{}) != null,
        );
    expect(
      modeButton.style?.backgroundColor?.resolve(<WidgetState>{}),
      colorScheme.primary.withValues(alpha: 0.12),
    );
  });

  for (final (PlayerQueueMode mode, Type iconType) in <(PlayerQueueMode, Type)>[
    (PlayerQueueMode.shuffle, HugeIcon),
    (PlayerQueueMode.sequence, HugeIcon),
    (PlayerQueueMode.singleRepeat, HugeIcon),
  ]) {
    testWidgets('队列模式 ${mode.name} 使用播放页同款图标', (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWith(() => _ModePlayer(mode)),
        ],
      );
      addTearDown(container.dispose);

      await _openQueueSheet(tester, container);

      final Finder header = find.ancestor(
        of: find.text('播放队列'),
        matching: find.byType(Row),
      );
      expect(
        find.descendant(of: header.first, matching: find.byType(iconType)),
        findsOneWidget,
      );
      // 旧的 Material 图标不应再出现。
      expect(find.byIcon(Icons.shuffle_rounded), findsNothing);
      expect(find.byIcon(Icons.repeat_rounded), findsNothing);
      expect(find.byIcon(Icons.repeat_one_rounded), findsNothing);
    });
  }
}
