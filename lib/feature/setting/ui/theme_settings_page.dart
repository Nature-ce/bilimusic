import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/display/player_chapter_marker_style_logic.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeUiModel themeState = ref.watch(themeLogicProvider);
    final bool useGlassBar = ref.watch(appearanceSettingLogicProvider);
    final PlayerChapterMarkerStyle markerStyle = ref.watch(
      playerChapterMarkerStyleLogicProvider,
    );

    return Scaffold(
      appBar: PageAppBar(title: const Text('外观设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: <Widget>[
          if (PlatformUtil.isMobile)
            SettingsGroup(
              title: '材质',
              children: <Widget>[
                SettingsSwitchTile(
                  icon: Icons.blur_on_rounded,
                  tint: SettingsTint.violet,
                  title: '玻璃导航栏 / 播放栏',
                  subtitle: '关闭后使用纯色底，低端机更流畅',
                  value: useGlassBar,
                  onChanged: (bool value) async {
                    await ref
                        .read(appearanceSettingLogicProvider.notifier)
                        .setUseGlassBar(value);
                  },
                ),
              ],
            ),
          SettingsGroup(
            title: '主题模式',
            children: <Widget>[
              for (final ThemeMode mode in ThemeMode.values)
                SettingsRadioTile(
                  icon: _themeModeIcon(mode),
                  tint: SettingsTint.green,
                  title: _themeModeLabel(mode),
                  subtitle: _themeModeDescription(mode),
                  selected: themeState.themeMode == mode,
                  onTap: () {
                    ref.read(themeLogicProvider.notifier).setThemeMode(mode);
                  },
                ),
            ],
          ),
          SettingsGroup(
            title: '主题颜色',
            children: <Widget>[
              SettingsSwatchPicker(
                options: themeCatalog
                    .map(
                      (ThemeDefinition definition) => SettingsSwatchOption(
                        id: definition.id,
                        label: definition.label,
                        color: definition.primaryColor ?? definition.seedColor,
                      ),
                    )
                    .toList(growable: false),
                selectedId: themeState.themeVariantId,
                onSelected: (String id) {
                  ref.read(themeLogicProvider.notifier).setThemeVariant(id);
                },
              ),
            ],
          ),
          SettingsGroup(
            title: '进度条',
            children: <Widget>[
              SettingsTile(
                icon: Icons.linear_scale_rounded,
                tint: SettingsTint.amber,
                title: '章节分隔样式',
                subtitle: '当前：${markerStyle.label}',
                onTap: () => context.push('/settings/progress'),
              ),
            ],
          ),
          SettingsInfoNote(text: '深色模式与主题颜色会立即生效；玻璃材质在部分低端设备上可能影响滚动流畅度，可随时关闭。'),
        ],
      ),
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => '跟随系统',
      ThemeMode.light => '浅色',
      ThemeMode.dark => '深色',
    };
  }

  String _themeModeDescription(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => '随系统深浅色自动切换',
      ThemeMode.light => '始终使用浅色外观',
      ThemeMode.dark => '始终使用深色外观',
    };
  }
}
