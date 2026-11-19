import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 用户卡片：白底卡面 + 圆形头像，未登录时用品牌实心胶囊作主 CTA。
class UserCard extends ConsumerWidget {
  const UserCard({super.key, this.onSettingsPressed});

  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final String? face = session?.face;
    final String? uname = session?.uname;
    final int? mid = session?.mid;

    return Material(
      color: appCardSurfaceColor(context),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: isLoggedIn ? null : () => context.push('/auth'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              CommonCachedAvatar(
                imageUrl: isLoggedIn ? face : null,
                radius: 26,
                backgroundColor: appFillColor(context),
                fallbackIcon: Icons.person_rounded,
                iconColor: appTertiaryTextColor(context),
                iconSize: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: isLoggedIn
                    ? _LoggedInInfo(uname: uname, mid: mid)
                    : const _LoginPrompt(),
              ),
              if (onSettingsPressed != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: onSettingsPressed,
                  tooltip: '设置',
                  iconSize: 22,
                  color: appSecondaryTextColor(context),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LoggedInInfo extends StatelessWidget {
  const _LoggedInInfo({required this.uname, required this.mid});

  final String? uname;
  final int? mid;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = (uname?.isNotEmpty ?? false) ? uname! : '已登录 B 站账号';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.pageTitle(theme).copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'mid: ${mid ?? '-'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.meta(
            theme,
          ).copyWith(color: appTertiaryTextColor(context)),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: appBrandFillColor(context),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => context.push('/auth'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: appOnBrandFillColor(context),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    '立即登录',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: appOnBrandFillColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '扫码同步 B 站账号信息',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.meta(
            theme,
          ).copyWith(color: appTertiaryTextColor(context)),
        ),
      ],
    );
  }
}
