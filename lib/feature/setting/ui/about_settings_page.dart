import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:bilimusic/feature/updater/domain/update_source.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:bilimusic/feature/updater/logic/update_source_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsPage extends ConsumerStatefulWidget {
  const AboutSettingsPage({super.key});

  @override
  ConsumerState<AboutSettingsPage> createState() => _AboutSettingsPageState();
}

class _AboutSettingsPageState extends ConsumerState<AboutSettingsPage> {
  bool _checking = false;

  Future<void> _handleCheck() async {
    if (_checking) {
      return;
    }
    setState(() {
      _checking = true;
    });
    try {
      await UpdateChecker.checkAndPrompt(context, manual: true);
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpdateSource updateSource = ref.watch(updateSourceLogicProvider);

    return Scaffold(
      appBar: PageAppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          const _AppHero(),
          SettingsGroup(
            title: '更新',
            children: <Widget>[
              SettingsTile(
                icon: Icons.system_update_alt_rounded,
                tint: SettingsTint.green,
                title: '检查更新',
                subtitle: '查看是否有新版本 · 当前来源：${updateSource.label}',
                value: _checking ? '检查中' : null,
                onTap: _checking ? null : _handleCheck,
              ),
              SettingsSwitchTile(
                icon: Icons.alt_route_rounded,
                tint: SettingsTint.amber,
                title: '跟随上游仓库更新',
                subtitle: updateSource.description,
                value: updateSource == UpdateSource.upstream,
                onChanged: (bool value) {
                  ref
                      .read(updateSourceLogicProvider.notifier)
                      .setSource(
                        value ? UpdateSource.upstream : UpdateSource.fork,
                      );
                },
              ),
            ],
          ),
          SettingsGroup(
            title: '其它',
            children: <Widget>[
              SettingsTile(
                icon: Icons.feedback_outlined,
                tint: SettingsTint.amber,
                title: '问题反馈',
                subtitle: '在 ${updateSource.label} 提交 issue',
                onTap: () {
                  launchUrl(Uri.parse(updateSource.issuesUrl));
                },
              ),
              SettingsTile(
                icon: Icons.code_rounded,
                tint: SettingsTint.blue,
                title: '源代码',
                subtitle: updateSource.repositoryUrl,
                onTap: () {
                  launchUrl(Uri.parse(updateSource.repositoryUrl));
                },
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                tint: SettingsTint.violet,
                title: '开源许可',
                subtitle: '第三方依赖与协议',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'bili-music',
                    applicationLegalese: '第三方 B 站音乐播放器',
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'bili-music 是第三方客户端，与哔哩哔哩官方无关。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHero extends StatelessWidget {
  const _AppHero();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Image.asset('assets/icons/icon3.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'bili-music',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            final String versionLabel = snapshot.hasData
                ? 'v${snapshot.data!.version} · build ${snapshot.data!.buildNumber}'
                : '版本读取中';
            return Text(
              versionLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ],
    );
  }
}
