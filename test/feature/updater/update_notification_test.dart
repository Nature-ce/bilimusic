import 'package:bilimusic/feature/updater/data/update_notification.dart';
import 'package:bilimusic/feature/updater/data/update_progress_reporter.dart';
import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('镜像候选=配置的镜像前缀 + 官方直链兜底', () {
    expect(UpdateRepository.mirrorPrefixes, <String>[
      'https://gh-proxy.org/',
      'https://v6.gh-proxy.org/',
    ]);

    const String assetUrl =
        'https://github.com/AprDeci/bili-music/releases/download/v1.8.2/app.apk';
    expect(UpdateRepository.buildDownloadCandidates(assetUrl), <String>[
      'https://gh-proxy.org/$assetUrl',
      'https://v6.gh-proxy.org/$assetUrl',
      assetUrl,
    ]);
  });

  test('非 Android 平台的通知调用是空操作且不抛错', () async {
    expect(await UpdateNotification.prepare(), isFalse);
    await UpdateNotification.showProgress(percent: 50, host: 'gh-proxy.org');
    await UpdateNotification.showFailure('所有下载地址均失败');
    await UpdateNotification.cancel();
  });

  test('进度通道在插件缺失的环境里也不抛错', () async {
    final UpdateProgressReporter reporter = UpdateProgressReporter();
    await reporter.prepare();
    await reporter.report(0, 'gh-proxy.org');
    await reporter.report(50, null);
    await reporter.finish();
    await reporter.fail('所有下载地址均失败');
  });

  test('通知与任务栏都不可用时，toast 兜底失败也不抛错', () async {
    // 不调用 prepare()：既不启用通知也不启用任务栏，强制走 ToastUtil 兜底。
    // 测试环境里 SmartDialog 没有初始化，这条路径在 Linux/Windows 上都会抛
    // LateInitializationError：兜底必须自己吞掉，不能影响下载流程。
    final UpdateProgressReporter reporter = UpdateProgressReporter();

    await expectLater(reporter.report(0, 'gh-proxy.org'), completes);
    await expectLater(reporter.report(50, null), completes);
    await expectLater(reporter.finish(), completes);
    await expectLater(reporter.fail('所有下载地址均失败'), completes);
  });
}
