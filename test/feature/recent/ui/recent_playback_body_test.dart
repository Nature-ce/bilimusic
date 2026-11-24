import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/ui/components/recent_playback_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  Future<void> Function(RecentPlaybackEntry entry)? onDeleteEntry,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RecentPlaybackBody(
          entries: const <RecentPlaybackEntry>[_entry],
          progress: const <String, int>{},
          onPlay: (_, _, _) {},
          onDeleteEntry: onDeleteEntry,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('向左滑动条目露出删除按钮，点删除会回调', (WidgetTester tester) async {
    final List<RecentPlaybackEntry> deleted = <RecentPlaybackEntry>[];
    await _pump(
      tester,
      onDeleteEntry: (RecentPlaybackEntry entry) async {
        deleted.add(entry);
      },
    );

    await tester.drag(find.text(_entry.title), const Offset(-110, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(deleted, hasLength(1));
    expect(deleted.single.stableId, _entry.stableId);
    expect(tester.takeException(), isNull);
  });

  testWidgets('滑开后点空白处会收回删除按钮', (WidgetTester tester) async {
    final List<RecentPlaybackEntry> deleted = <RecentPlaybackEntry>[];
    await _pump(
      tester,
      onDeleteEntry: (RecentPlaybackEntry entry) async {
        deleted.add(entry);
      },
    );

    await tester.drag(find.text(_entry.title), const Offset(-110, 0));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(deleted, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('长按条目不再弹出操作面板', (WidgetTester tester) async {
    await _pump(tester, onDeleteEntry: (_) async {});

    await tester.longPress(find.text(_entry.title));
    await tester.pumpAndSettle();

    expect(find.text('从最近播放移除'), findsNothing);
    expect(find.text('播放'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
