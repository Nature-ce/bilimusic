import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
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
    final bool? confirmed = await showAppConfirmDialog(
      context: context,
      useGlass: ref.read(appearanceSettingLogicProvider),
      title: title,
      message: content,
      confirmLabel: confirmText,
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
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final String accountName = isLoggedIn
        ? (session?.uname?.isNotEmpty == true ? session!.uname! : '已登录 B 站账号')
        : '未登录';

    return Scaffold(
      appBar: PageAppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: <Widget>[
          SettingsGroup(
            title: '账号与同步',
            children: <Widget>[
              SettingsTile(
                icon: Icons.account_circle_outlined,
                tint: SettingsTint.green,
                title: 'B 站账号',
                subtitle: isLoggedIn
                    ? 'mid: ${session?.mid ?? '-'}'
                    : '登录后可同步收藏与歌单',
                value: accountName,
                onTap: isLoggedIn ? null : () => context.push('/auth'),
              ),
              if (isLoggedIn)
                SettingsTile(
                  icon: Icons.swap_horiz_rounded,
                  tint: SettingsTint.blue,
                  title: '切换账号',
                  subtitle: '退出当前账号并使用新账号登录',
                  onTap: _handleSwitchAccount,
                ),
              if (isLoggedIn)
                SettingsTile(
                  icon: Icons.logout_rounded,
                  tint: SettingsTint.red,
                  title: '退出登录',
                  subtitle: '清除本地登录状态',
                  danger: true,
                  onTap: _handleLogoutPressed,
                ),
              SettingsTile(
                icon: Icons.import_export_rounded,
                tint: SettingsTint.amber,
                title: '数据导入导出',
                subtitle: '导出或导入收藏与应用设置',
                onTap: () => context.push('/settings/app-transfer'),
              ),
            ],
          ),
          SettingsGroup(
            title: '播放',
            children: <Widget>[
              SettingsTile(
                icon: Icons.multitrack_audio_outlined,
                tint: SettingsTint.green,
                title: '播放器设置',
                subtitle: '后台播放与音频策略',
                onTap: () => context.push('/settings/player'),
              ),
              if (PlatformUtil.isDesktop)
                SettingsTile(
                  icon: Icons.keyboard_command_key_rounded,
                  tint: SettingsTint.violet,
                  title: '快捷键',
                  subtitle: '全局播放控制与窗口显示隐藏',
                  onTap: () => context.push('/settings/hotkeys'),
                ),
            ],
          ),
          SettingsGroup(
            title: '外观与存储',
            children: <Widget>[
              SettingsTile(
                icon: Icons.palette_outlined,
                tint: SettingsTint.violet,
                title: '外观设置',
                subtitle: '主题模式与主题颜色',
                onTap: () => context.push('/settings/theme'),
              ),
              FutureBuilder<int>(
                future: _cacheSizeFuture,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  final int size = snapshot.data ?? 0;
                  return SettingsTile(
                    icon: Icons.pie_chart_outline,
                    tint: SettingsTint.amber,
                    title: '缓存管理',
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
          SettingsGroup(
            title: '关于',
            children: <Widget>[
              SettingsTile(
                icon: Icons.info_outline_rounded,
                tint: SettingsTint.red,
                title: '版本与更新',
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
