import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key, this.onSettingsPressed});

  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final ColorScheme colorScheme = theme.colorScheme;
    final String? face = session?.face;
    final String? uname = session?.uname;
    final int? mid = session?.mid;
    final String title = isLoggedIn
        ? (uname?.isNotEmpty == true ? uname! : '已登录 B 站账号')
        : '点击登录';
    final String subtitle = isLoggedIn ? 'mid: ${mid ?? '-'}' : '扫码同步 B 站账号信息';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: isLoggedIn ? null : () => context.push('/auth'),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  colorScheme.primary.withValues(alpha: 0.16),
                  colorScheme.primary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: CommonCachedAvatar(
                      imageUrl: isLoggedIn ? face : null,
                      radius: 23,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      fallbackIcon: Icons.person,
                      iconColor: colorScheme.primary,
                      iconSize: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.pageTitle(
                            theme,
                          ).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.meta(theme),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (!isLoggedIn)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.primary,
                    ),
                  Material(
                    color: colorScheme.surface.withValues(alpha: 0.6),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: onSettingsPressed,
                      tooltip: '设置',
                      iconSize: 20,
                      icon: Icon(
                        Icons.settings_rounded,
                        color: colorScheme.primary,
                      ),
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
