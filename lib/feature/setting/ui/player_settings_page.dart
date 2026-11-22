import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_preference.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:bilimusic/feature/meting/ui/meting_source_rule_dialog.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_quality_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/playback/player_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerSettingsPage extends ConsumerWidget {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool allowMixWithOthers = ref.watch(playerSettingsLogicProvider);
    final bool preferMetadata = ref.watch(playerDisplaySettingsLogicProvider);
    final PlayerAudioQualityPreference audioQualityPreference = ref.watch(
      playerAudioQualityPreferenceLogicProvider,
    );
    final MetingSourcePreference sourcePreference = ref.watch(
      metingSourcePreferenceLogicProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('播放器设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: <Widget>[
          SettingsGroup(
            title: '播放',
            children: <Widget>[
              if (PlatformUtil.isMobile)
                SettingsSwitchTile(
                  icon: Icons.multitrack_audio_outlined,
                  tint: SettingsTint.green,
                  title: '与其他应用同时播放',
                  subtitle: '重启后生效',
                  value: allowMixWithOthers,
                  onChanged: (bool value) async {
                    await ref
                        .read(playerSettingsLogicProvider.notifier)
                        .setAllowMixWithOthers(value);
                  },
                ),
              SettingsSwitchTile(
                icon: Icons.image_outlined,
                tint: SettingsTint.blue,
                title: '优先使用元信息',
                subtitle: '封面、歌名与歌手优先显示匹配到的元信息',
                value: preferMetadata,
                onChanged: (bool value) async {
                  await ref
                      .read(playerDisplaySettingsLogicProvider.notifier)
                      .setPreferMetadata(value);
                },
              ),
              SettingsTile(
                icon: Icons.graphic_eq_rounded,
                tint: SettingsTint.amber,
                title: '默认音质',
                subtitle: '优先请求该音质，不可用时自动降级',
                value: audioQualityPreference.title,
                onTap: () => _showAudioQualitySheet(context, ref),
              ),
            ],
          ),
          SettingsGroup(
            title: '歌词源',
            children: <Widget>[
              for (final MetingServer server in MetingServer.values)
                SettingsRadioTile(
                  icon: _serverIcon(server),
                  tint: _serverTint(server),
                  title: server.label,
                  subtitle: server == sourcePreference.defaultServer
                      ? '默认音源'
                      : null,
                  selected: server == sourcePreference.defaultServer,
                  onTap: () async {
                    await ref
                        .read(metingSourcePreferenceLogicProvider.notifier)
                        .setDefaultServer(server);
                  },
                ),
            ],
          ),
          SettingsGroup(
            title: '关键词规则',
            children: <Widget>[
              if (sourcePreference.rules.isEmpty)
                SettingsTile(
                  icon: Icons.tag_rounded,
                  tint: SettingsTint.violet,
                  title: '暂无规则',
                  subtitle: '在歌词搜索面板点「添加规则」即可添加',
                  showChevron: false,
                ),
              for (final MetingSourceRule rule in sourcePreference.rules)
                SettingsTile(
                  icon: Icons.tag_rounded,
                  tint: SettingsTint.violet,
                  title: rule.keyword,
                  subtitle: rule.server.label,
                  showChevron: false,
                  trailing: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    tooltip: '删除',
                    onPressed: () => ref
                        .read(metingSourcePreferenceLogicProvider.notifier)
                        .removeRule(rule),
                  ),
                ),
              SettingsTile(
                icon: Icons.add_rounded,
                tint: SettingsTint.green,
                title: '添加规则',
                subtitle: '固定某个关键词只查指定平台',
                onTap: () => _addRule(context, ref),
              ),
            ],
          ),
          SettingsInfoNote(
            text:
                '关键词规则只在歌词/元信息搜索时生效，命中规则的关键词会固定查指定平台，其余走默认音源。开启「优先使用元信息」后，双击播放页封面可切回 B 站信息。',
          ),
        ],
      ),
    );
  }

  IconData _serverIcon(MetingServer server) {
    return switch (server) {
      MetingServer.netease => Icons.cloud_outlined,
      MetingServer.tencent => Icons.music_note_outlined,
      MetingServer.kugou => Icons.album_outlined,
    };
  }

  SettingsTint _serverTint(MetingServer server) {
    return switch (server) {
      MetingServer.netease => SettingsTint.green,
      MetingServer.tencent => SettingsTint.amber,
      MetingServer.kugou => SettingsTint.violet,
    };
  }
}

Future<void> _showAudioQualitySheet(BuildContext context, WidgetRef ref) async {
  final ThemeData theme = Theme.of(context);
  final PlayerAudioQualityPreference currentPreference = ref.read(
    playerAudioQualityPreferenceLogicProvider,
  );
  const List<PlayerAudioQualityPreference> preferences =
      <PlayerAudioQualityPreference>[
        PlayerAudioQualityPreference.auto,
        PlayerAudioQualityPreference.hires,
        PlayerAudioQualityPreference.k192,
        PlayerAudioQualityPreference.k132,
      ];

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: preferences.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final PlayerAudioQualityPreference preference = preferences[index];
            final bool isSelected = preference == currentPreference;
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              title: Text(preference.title),
              subtitle: Text(preference.description),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playerControllerProvider.notifier)
                    .setAudioQualityPreference(preference);
              },
            );
          },
        ),
      );
    },
  );
}

Future<void> _addRule(BuildContext context, WidgetRef ref) async {
  final MetingSourceRule? rule = await showMetingSourceRuleDialog(
    context: context,
    initialKeyword: '',
    initialServer: ref.read(metingSourcePreferenceLogicProvider).defaultServer,
  );
  if (rule == null) {
    return;
  }

  await ref
      .read(metingSourcePreferenceLogicProvider.notifier)
      .upsertRule(keyword: rule.keyword, server: rule.server);
}
