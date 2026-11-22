import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:bilimusic/feature/setting/logic/hotkey_settings_logic.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeySettingsPage extends ConsumerWidget {
  const HotkeySettingsPage({super.key});

  static const List<HotkeyAction> _playbackActions = <HotkeyAction>[
    HotkeyAction.playPause,
    HotkeyAction.previousTrack,
    HotkeyAction.nextTrack,
  ];

  static const List<HotkeyAction> _windowActions = <HotkeyAction>[
    HotkeyAction.toggleDesktop,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HotkeyBinding> bindings = ref.watch(hotkeySettingsLogicProvider);

    HotkeyBinding bindingOf(HotkeyAction action) {
      return bindings.firstWhere(
        (HotkeyBinding binding) => binding.action == action,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('快捷键设置'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await ref
                  .read(hotkeySettingsLogicProvider.notifier)
                  .resetDefaults();
              ToastUtil.show('已恢复默认快捷键');
            },
            child: const Text('恢复默认'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: <Widget>[
          const SettingsInfoNote(
            text: '桌面端全局快捷键；点某一行后按下新的组合键即可修改，保存后生效。若组合键已被系统或其他应用占用，请更换后再保存。',
          ),
          SettingsGroup(
            title: '播放控制',
            children: <Widget>[
              for (final HotkeyAction action in _playbackActions)
                _HotkeyRow(binding: bindingOf(action)),
            ],
          ),
          SettingsGroup(
            title: '界面',
            children: <Widget>[
              for (final HotkeyAction action in _windowActions)
                _HotkeyRow(binding: bindingOf(action)),
            ],
          ),
          SettingsGroup(
            title: '前台固定',
            children: <Widget>[
              SettingsTile(
                icon: Icons.keyboard_rounded,
                tint: SettingsTint.blue,
                title: HotkeyAction.foregroundPlayPause.title,
                subtitle: '窗口聚焦时固定为空格，不可修改',
                showChevron: false,
                trailing: const SettingsKeycap(keys: <String>['Space']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HotkeyRow extends ConsumerWidget {
  const _HotkeyRow({required this.binding});

  final HotkeyBinding binding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HotKey? hotKey = binding.toHotKey();
    final bool enabled = binding.enabled && hotKey != null;
    final String scopeLabel = binding.scope == HotKeyScope.inapp ? '前台' : '全局';

    return SettingsTile(
      icon: _actionIcon(binding.action),
      tint: _actionTint(binding.action),
      title: binding.action.title,
      subtitle: enabled
          ? '${binding.action.description} · $scopeLabel'
          : binding.action.description,
      showChevron: false,
      trailing: enabled
          ? HotKeyVirtualView(hotKey: hotKey)
          : const SettingsKeycap(keys: <String>[]),
      onTap: () => _showHotkeySheet(context, ref, binding),
    );
  }

  IconData _actionIcon(HotkeyAction action) {
    return switch (action) {
      HotkeyAction.playPause => Icons.play_circle_outline_rounded,
      HotkeyAction.foregroundPlayPause => Icons.keyboard_rounded,
      HotkeyAction.previousTrack => Icons.skip_previous_rounded,
      HotkeyAction.nextTrack => Icons.skip_next_rounded,
      HotkeyAction.toggleDesktop => Icons.window_outlined,
    };
  }

  SettingsTint _actionTint(HotkeyAction action) {
    return switch (action) {
      HotkeyAction.playPause => SettingsTint.green,
      HotkeyAction.foregroundPlayPause => SettingsTint.blue,
      HotkeyAction.previousTrack => SettingsTint.blue,
      HotkeyAction.nextTrack => SettingsTint.blue,
      HotkeyAction.toggleDesktop => SettingsTint.violet,
    };
  }
}

Future<void> _showHotkeySheet(
  BuildContext context,
  WidgetRef ref,
  HotkeyBinding binding,
) async {
  HotKey? recordedHotKey = binding.toHotKey();

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      final ThemeData theme = Theme.of(context);

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(binding.action.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('按下新的组合键后会自动记录，点击保存后生效。', style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.keyboard_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HotKeyRecorder(
                          initalHotKey: recordedHotKey,
                          onHotKeyRecorded: (HotKey hotKey) {
                            recordedHotKey = hotKey;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(hotkeySettingsLogicProvider.notifier)
                          .setBinding(binding.copyWith(enabled: false));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.block_rounded),
                    label: const Text('禁用'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      final HotKey? hotKey = recordedHotKey;
                      if (hotKey == null) {
                        ToastUtil.show('请先按下一个快捷键');
                        return;
                      }
                      await ref
                          .read(hotkeySettingsLogicProvider.notifier)
                          .setBinding(
                            HotkeyBinding.fromHotKey(
                              action: binding.action,
                              hotKey: hotKey,
                            ),
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
