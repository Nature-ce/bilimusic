import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/core/theme/app_design.dart';
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
  DateTime? _lastCheckedAt;

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
          _lastCheckedAt = DateTime.now();
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
          _UpdateBanner(
            checking: _checking,
            lastCheckedAt: _lastCheckedAt,
            onTap: _handleCheck,
          ),
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

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({
    required this.checking,
    required this.lastCheckedAt,
    required this.onTap,
  });

  final bool checking;
  final DateTime? lastCheckedAt;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final DateTime? lastChecked = lastCheckedAt;
    final String subtitle = checking
        ? '正在检查新版本…'
        : lastChecked == null
        ? '点击检查是否有新版本'
        : '上次检查：${lastChecked.hour.toString().padLeft(2, '0')}:${lastChecked.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.primary.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: InkWell(
            onTap: checking ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.22),
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '检查更新',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (checking)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      '检查',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
