import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _openQueueSheet(
  WidgetTester tester,
  ProviderContainer container,
) async {
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
      overrides: [playerControllerProvider.overrideWith(_ReorderablePlayer.new)],
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
      overrides: [playerControllerProvider.overrideWith(_ReorderablePlayer.new)],
    );
    addTearDown(container.dispose);

    await _openQueueSheet(tester, container);

    expect(find.byTooltip('移出队列'), findsWidgets);
  });
}
