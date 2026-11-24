import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_body.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _GlassAppearance extends AppearanceSettingLogic {
  @override
  bool build() => true;
}

class _SolidAppearance extends AppearanceSettingLogic {
  @override
  bool build() => false;
}

const RecentPlaybackEntry _entry = RecentPlaybackEntry(
  aid: 1,
  bvid: 'BV1',
  title: '最近播放的歌曲',
  author: '某UP主',
  coverUrl: '',
  playedAtEpochMs: 0,
);

Future<void> _pump(
  WidgetTester tester, {
  required AppearanceSettingLogic Function() appearance,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appearanceSettingLogicProvider.overrideWith(appearance)],
      child: MaterialApp(
        home: Scaffold(
          body: RecentPlaybackBody(
            entries: const <RecentPlaybackEntry>[_entry],
            progress: const <String, int>{},
            onPlay: (_, _, _) {},
            onDeleteEntry: (_) async {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('向左滑动条目露出删除按钮，点删除会回调', (WidgetTester tester) async {
    final List<RecentPlaybackEntry> deleted = <RecentPlaybackEntry>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appearanceSettingLogicProvider.overrideWith(_SolidAppearance.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: RecentPlaybackBody(
              entries: const <RecentPlaybackEntry>[_entry],
              progress: const <String, int>{},
              onPlay: (_, _, _) {},
              onDeleteEntry: (RecentPlaybackEntry entry) async {
                deleted.add(entry);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text(_entry.title), const Offset(-110, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(deleted, hasLength(1));
    expect(deleted.single.stableId, _entry.stableId);
    expect(tester.takeException(), isNull);
  });
  testWidgets('玻璃开关打开时长按条目用玻璃弹层', (WidgetTester tester) async {
    await _pump(tester, appearance: _GlassAppearance.new);

    await tester.longPress(find.text(_entry.title));
    await tester.pumpAndSettle();

    expect(find.byType(AppGlassSheet), findsOneWidget);
    expect(find.text('从最近播放移除'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('玻璃开关关闭时长按条目仍是纯色弹层', (WidgetTester tester) async {
    await _pump(tester, appearance: _SolidAppearance.new);

    await tester.longPress(find.text(_entry.title));
    await tester.pumpAndSettle();

    expect(find.byType(AppGlassSheet), findsNothing);
    expect(find.text('从最近播放移除'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
