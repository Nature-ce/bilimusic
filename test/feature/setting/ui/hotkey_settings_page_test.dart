import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:bilimusic/feature/setting/ui/hotkey_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lists every editable hotkey grouped by action', (
    WidgetTester tester,
  ) async {
    final _FakeSettingsStore store = _FakeSettingsStore();
    final ProviderContainer container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HotkeySettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('快捷键设置'), findsOneWidget);
    expect(find.text('播放控制'), findsOneWidget);
    expect(find.text('界面'), findsOneWidget);
    expect(find.text('前台固定'), findsOneWidget);
    expect(find.text(HotkeyAction.playPause.title), findsOneWidget);
    expect(find.text(HotkeyAction.previousTrack.title), findsOneWidget);
    expect(find.text(HotkeyAction.nextTrack.title), findsOneWidget);
    expect(find.text(HotkeyAction.toggleDesktop.title), findsOneWidget);
    expect(find.text('未启用'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled bindings render an unbound hint', (
    WidgetTester tester,
  ) async {
    final List<HotkeyBinding> bindings = defaultHotkeyBindings()
        .map(
          (HotkeyBinding binding) => binding.action == HotkeyAction.nextTrack
              ? binding.copyWith(enabled: false)
              : binding,
        )
        .toList(growable: false);
    final _FakeSettingsStore store = _FakeSettingsStore()
      ..values[HiveKeys.desktopHotkeys] = jsonEncode(
        bindings.map((HotkeyBinding binding) => binding.toJson()).toList(),
      );
    final ProviderContainer container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HotkeySettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('未启用'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeSettingsStore implements AppSettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  String readString(String key, {required String defaultValue}) {
    return values[key] ?? defaultValue;
  }

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
