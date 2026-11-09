import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/download/ui/downloads_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDownloads extends DownloadController {
  _FakeDownloads(this._state);

  final DownloadState _state;
  final List<String> removed = <String>[];
  final List<String> retried = <String>[];
  final List<String> dismissed = <String>[];

  @override
  DownloadState build() => _state;

  @override
  Future<void> removeTrack(DownloadedTrack track) async {
    removed.add(track.contentId);
  }

  @override
  Future<bool> retry(String contentId) async {
    retried.add(contentId);
    return true;
  }

  @override
  void dismissTask(String contentId) {
    dismissed.add(contentId);
  }
}

DownloadedTrack _track({String contentId = 'bvid:BV1:page:1'}) {
  return DownloadedTrack(
    contentId: contentId,
    aid: 1,
    bvid: 'BV1',
    cid: 10,
    page: 1,
    title: '夜曲',
    author: '周杰伦',
    coverUrl: '',
    filePath: '/tmp/night.m4a',
    byteLength: 1024 * 1024,
    downloadedAtMs: 1,
    qualityLabel: '192K',
  );
}

DownloadTask _failedTask({String contentId = 'bvid:BV2:page:1'}) {
  return DownloadTask(
    contentId: contentId,
    status: DownloadTaskStatus.failed,
    title: '晴天',
    author: '周杰伦',
    errorMessage: '网络错误',
  );
}

Future<_FakeDownloads> _pumpPage(
  WidgetTester tester,
  DownloadState state,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeDownloads controller = _FakeDownloads(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [downloadControllerProvider.overrideWith(() => controller)],
      child: MaterialApp(
        builder: FlutterSmartDialog.init(),
        home: const DownloadsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('shows storage summary and failure count', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      DownloadState(
        tracks: <DownloadedTrack>[_track()],
        totalBytes: 1024 * 1024,
        tasks: <String, DownloadTask>{'bvid:BV2:page:1': _failedTask()},
      ),
    );

    expect(find.text('共 1 首 · 1.0 MB'), findsOneWidget);
    expect(find.text('1 项失败'), findsOneWidget);
  });

  testWidgets('failed task can be retried or dismissed', (
    WidgetTester tester,
  ) async {
    final _FakeDownloads controller = await _pumpPage(
      tester,
      DownloadState(
        tasks: <String, DownloadTask>{'bvid:BV2:page:1': _failedTask()},
      ),
    );

    expect(find.text('晴天'), findsOneWidget);
    expect(find.textContaining('网络错误'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(controller.retried, <String>['bvid:BV2:page:1']);

    await tester.tap(find.byTooltip('移除'));
    await tester.pump();
    expect(controller.dismissed, <String>['bvid:BV2:page:1']);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('batch mode deletes the selected downloads', (
    WidgetTester tester,
  ) async {
    final _FakeDownloads controller = await _pumpPage(
      tester,
      DownloadState(
        tracks: <DownloadedTrack>[_track()],
        totalBytes: 1024 * 1024,
      ),
    );

    await tester.tap(find.byTooltip('批量管理'));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '删除'),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.removed, <String>['bvid:BV1:page:1']);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('empty state stays when nothing is downloaded', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, const DownloadState());

    expect(find.text('还没有下载的歌曲'), findsOneWidget);
  });
}
