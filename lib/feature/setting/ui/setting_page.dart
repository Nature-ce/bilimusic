import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  late Future<int> _cacheSizeFuture;

  @override
  void initState() {
    super.initState();
    _cacheSizeFuture = CacheUtil.getTotalCacheSizeBytes();
  }

  Future<void> _reloadCacheSize() async {
    setState(() {
      _cacheSizeFuture = CacheUtil.getTotalCacheSizeBytes();
    });
  }

  Future<bool> _confirm({
    required String title,
    required String content,
    required String confirmText,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  String _logoutMessage(LogoutResult result) {
    if (result.remoteLoggedOut) {
      return '已退出登录';
    }
    return result.message?.isNotEmpty == true
        ? '服务端退出失败，已清除本地登录状态'
        : '已清除本地登录状态';
  }

  Future<void> _handleLogoutPressed() async {
    final bool confirmed = await _confirm(
      title: '退出登录',
      content: '确认退出当前 B 站账号吗？',
      confirmText: '退出',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final LogoutResult result = await ref
        .read(biliAuthControllerProvider.notifier)
        .logout();
    if (!mounted) {
      return;
    }
    ToastUtil.show(_logoutMessage(result));
  }

  Future<void> _handleSwitchAccount() async {
    final BiliSession? session = ref.read(biliSessionControllerProvider);
    final String accountName = session?.uname?.isNotEmpty == true
        ? session!.uname!
        : '当前账号';
    final bool confirmed = await _confirm(
      title: '切换账号',
      content: '将退出「$accountName」，随后使用新账号扫码登录。',
      confirmText: '继续',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final LogoutResult result = await ref
        .read(biliAuthControllerProvider.notifier)
        .logout();
    if (!mounted) {
      return;
    }
    ToastUtil.show(
      result.remoteLoggedOut ? '已退出当前账号，请登录新账号' : '已清除本地登录状态，请登录新账号',
    );
    await context.push('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final String accountName = isLoggedIn
        ? (session?.uname?.isNotEmpty == true ? session!.uname! : '已登录 B 站账号')
        : '未登录';

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          _SettingsGroup(
            title: '账号与同步',
            children: <Widget>[
              _SettingsTile(
                icon: Icons.account_circle_outlined,
                iconColor: const Color(0xFF256A4C),
                label: 'B 站账号',
                subtitle: isLoggedIn
                    ? 'mid: ${session?.mid ?? '-'}'
                    : '登录后可同步收藏与歌单',
                value: accountName,
                onTap: isLoggedIn ? null : () => context.push('/auth'),
              ),
              if (isLoggedIn)
                _SettingsTile(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: const Color(0xFF2F5FB8),
                  label: '切换账号',
                  subtitle: '退出当前账号并使用新账号登录',
                  onTap: _handleSwitchAccount,
                ),
              if (isLoggedIn)
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: colorScheme.error,
                  label: '退出登录',
                  subtitle: '清除本地登录状态',
                  danger: true,
                  onTap: _handleLogoutPressed,
                ),
              _SettingsTile(
                icon: Icons.import_export_rounded,
                iconColor: const Color(0xFFB4671F),
                label: '数据导入导出',
                subtitle: '导出或导入收藏与应用设置',
                onTap: () => context.push('/settings/app-transfer'),
              ),
            ],
          ),
          _SettingsGroup(
            title: '播放',
            children: <Widget>[
              _SettingsTile(
                icon: Icons.multitrack_audio_outlined,
                iconColor: const Color(0xFF256A4C),
                label: '播放器设置',
                subtitle: '后台播放与音频策略',
                onTap: () => context.push('/settings/player'),
              ),
              if (PlatformUtil.isDesktop)
                _SettingsTile(
                  icon: Icons.keyboard_command_key_rounded,
                  iconColor: const Color(0xFF6B45A6),
                  label: '快捷键',
                  subtitle: '全局播放控制与窗口显示隐藏',
                  onTap: () => context.push('/settings/hotkeys'),
                ),
            ],
          ),
          _SettingsGroup(
            title: '外观与存储',
            children: <Widget>[
              _SettingsTile(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFF6B45A6),
                label: '外观设置',
                subtitle: '主题模式与主题颜色',
                onTap: () => context.push('/settings/theme'),
              ),
              FutureBuilder<int>(
                future: _cacheSizeFuture,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  final int size = snapshot.data ?? 0;
                  return _SettingsTile(
                    icon: Icons.pie_chart_outline,
                    iconColor: const Color(0xFFB4671F),
                    label: '缓存管理',
                    subtitle: '图片、音频、歌词与元信息',
                    value: size > 0 ? formatBytes(size) : null,
                    onTap: () async {
                      await context.push('/settings/cache');
                      if (!mounted) {
                        return;
                      }
                      await _reloadCacheSize();
                    },
                  );
                },
              ),
            ],
          ),
          _SettingsGroup(
            title: '关于',
            children: <Widget>[
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFFB33A26),
                label: '版本与更新',
                subtitle: '检查更新 / 问题反馈 / 开源许可',
                onTap: () => context.push('/settings/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 设置页分组卡片：白底圆角 + 组名 + 内嵌若干行。
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Material(
            color: appCardSurfaceColor(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                for (int index = 0; index < children.length; index += 1) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 56,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  children[index],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.subtitle,
    this.value,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color labelColor = danger ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                  if ((subtitle ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if ((value ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Text(
                value!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
