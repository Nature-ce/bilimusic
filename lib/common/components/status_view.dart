import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

// 全站统一的状态块（空态/错误/未登录）。样式在这里定死，调用点不要再调尺寸、
// 间距、颜色，否则又会长出 20 种不同的空态。
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.onRetry,
    this.retryLabel = '重试',
    this.isRetrying = false,
    this.actions = const <Widget>[],
  });

  static const double _iconBoxSize = 80;
  static const double _iconSize = 34;

  final String title;
  final String? description;
  final IconData? icon;

  // 错误态传 colorScheme.error，其余走中性灰
  final Color? iconColor;

  // 最常见的动作，单独留参数省得到处拼按钮
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool isRetrying;

  // 其余按钮：去登录、在线搜索等
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? description = this.description;
    final Color tint = iconColor ?? appTertiaryTextColor(context);
    final bool hasAction = onRetry != null || actions.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Container(
                width: _iconBoxSize,
                height: _iconBoxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appSkeletonColor(context),
                ),
                child: Icon(icon, size: _iconSize, color: tint),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (description != null && description.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: appTertiaryTextColor(context),
                ),
              ),
            ],
            if (hasAction) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  if (onRetry != null)
                    Material(
                      color: appBrandFillColor(context),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: isRetrying ? null : onRetry,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.sm + 2,
                          ),
                          child: Text(
                            isRetrying ? '重试中' : retryLabel,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: appOnBrandFillColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ...actions,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 滚动列表里用：撑满剩余空间，保证空态和整页空态一样居中
class SliverStatusView extends StatelessWidget {
  const SliverStatusView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(hasScrollBody: false, child: child);
  }
}
