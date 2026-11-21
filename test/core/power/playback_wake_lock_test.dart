import 'package:bilimusic/core/power/playback_wake_lock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('bilimusic/keep_awake');
  late List<String> calls;

  setUp(() {
    PlaybackWakeLock.resetForTest();
    PlaybackWakeLock.debugForceEnabled = true;
    calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call.method);
          return null;
        });
  });

  tearDown(() {
    PlaybackWakeLock.resetForTest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('播放时申请唤醒锁，暂停时释放', () async {
    await PlaybackWakeLock.setHeld(true);
    expect(calls, <String>['acquire']);
    expect(PlaybackWakeLock.isHeld, isTrue);

    await PlaybackWakeLock.setHeld(false);
    expect(calls, <String>['acquire', 'release']);
    expect(PlaybackWakeLock.isHeld, isFalse);
  });

  test('重复请求同一个状态不会重复调用原生', () async {
    await PlaybackWakeLock.setHeld(true);
    await PlaybackWakeLock.setHeld(true);
    expect(calls, <String>['acquire']);

    await PlaybackWakeLock.setHeld(false);
    await PlaybackWakeLock.setHeld(false);
    expect(calls, <String>['acquire', 'release']);
  });

  test('原生调用失败不影响播放，只是没拿到锁', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          throw PlatformException(code: 'boom');
        });

    await PlaybackWakeLock.setHeld(true);

    expect(PlaybackWakeLock.isHeld, isFalse);
  });
}
