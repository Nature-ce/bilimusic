import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

enum SettingsTint { green, blue, amber, violet, red }

extension SettingsTintStyle on SettingsTint {
  Color get foreground {
    return switch (this) {
      SettingsTint.green => const Color(0xFF256A4C),
      SettingsTint.blue => const Color(0xFF2F5FB8),
      SettingsTint.amber => const Color(0xFFB4671F),
      SettingsTint.violet => const Color(0xFF6B45A6),
      SettingsTint.red => const Color(0xFFB33A26),
    };
  }

  Color background(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return foreground.withValues(alpha: isDark ? 0.2 : 0.12);
  }
}

Color settingsDividerColor(BuildContext context) {
  return Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.32);
}

Color settingsGroupBorderColor(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.colorScheme.outlineVariant.withValues(
    alpha: theme.brightness == Brightness.dark ? 0.45 : 0.5,
  );
}

/// 行左侧 30px 浅色图标方块。
class SettingsIconBadge extends StatelessWidget {
  const SettingsIconBadge({
    super.key,
    required this.icon,
    this.tint = SettingsTint.green,
    this.size = 30,
  });

  final IconData icon;
  final SettingsTint tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.background(context),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.55, color: tint.foreground),
    );
  }
}

/// 设置分组白卡片：标题 + 若干行，行之间 1px 细线。
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    this.title,
    required this.children,
    this.margin = const EdgeInsets.only(top: AppSpacing.md),
    this.footer,
  });

  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> rows = <Widget>[];
    for (int index = 0; index < children.length; index += 1) {
      if (index > 0) {
        rows.add(
          Divider(
            height: 0.8,
            thickness: 0.8,
            color: settingsDividerColor(context),
          ),
        );
      }
      rows.add(children[index]);
    }
    if (footer != null) {
      rows
        ..add(
          Divider(
            height: 0.8,
            thickness: 0.8,
            color: settingsDividerColor(context),
          ),
        )
        ..add(footer!);
    }

    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          color: appCardSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: settingsGroupBorderColor(context),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: appShadowColor(context),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if ((title ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    12,
                    AppSpacing.lg,
                    2,
                  ),
                  child: Text(
                    title!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }
}

/// 卡片外的分组小标题。
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.lg, 0, 6),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// 通用行：图标方块 + 主副文案 + 右侧值/自定义控件/箭头。
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.tint = SettingsTint.green,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.danger = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: 11,
    ),
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final SettingsTint tint;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool danger;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color titleColor = danger ? colorScheme.error : colorScheme.onSurface;
    final double contentOpacity = enabled ? 1 : 0.45;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: contentOpacity,
        child: Padding(
          padding: padding,
          child: Row(
            children: <Widget>[
              ?leading,
              if (leading == null && icon != null)
                SettingsIconBadge(icon: icon!, tint: tint),
              if (leading != null || icon != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    if ((subtitle ?? '').isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
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
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
              if (trailing == null && showChevron) ...<Widget>[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 开关行。
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tint = SettingsTint.green,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final SettingsTint tint;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      tint: tint,
      enabled: onChanged != null,
      showChevron: false,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Transform.scale(
        scale: 0.86,
        child: Switch.adaptive(
          value: value,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// 20px 圆形勾选标记（单选/多选共用）。
class SettingsCheckMark extends StatelessWidget {
  const SettingsCheckMark({
    super.key,
    required this.selected,
    this.size = 20,
    this.enabled = true,
  });

  final bool selected;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: selected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.85 : 1),
          width: 1.6,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check_rounded,
              size: size * 0.66,
              color: enabled ? colorScheme.onPrimary : colorScheme.onPrimary,
            )
          : null,
    );
  }
}

/// 单选行（右侧圆形勾）。
class SettingsRadioTile extends StatelessWidget {
  const SettingsRadioTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tint = SettingsTint.green,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final SettingsTint tint;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      tint: tint,
      showChevron: false,
      onTap: onTap,
      trailing: SettingsCheckMark(selected: selected),
    );
  }
}

/// 左侧勾选的多选行（缓存分类）。
class SettingsCheckTile extends StatelessWidget {
  const SettingsCheckTile({
    super.key,
    required this.title,
    this.icon,
    this.tint = SettingsTint.green,
    this.value,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final IconData? icon;
  final SettingsTint tint;
  final String? value;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 11,
          ),
          child: Row(
            children: <Widget>[
              SettingsCheckMark(selected: selected),
              const SizedBox(width: 12),
              if (icon != null) ...<Widget>[
                SettingsIconBadge(icon: icon!, tint: tint),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((value ?? '').isNotEmpty)
                Text(
                  value!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 说明性小卡片。
class SettingsInfoNote extends StatelessWidget {
  const SettingsInfoNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: appCardSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: settingsGroupBorderColor(context),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11.5,
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 绿色渐变的强调卡（总缓存、更新状态等）。
class SettingsHighlightCard extends StatelessWidget {
  const SettingsHighlightCard({
    super.key,
    this.title,
    this.titleTrailing,
    required this.value,
    this.unit,
    this.footnote,
    this.onTap,
  });

  final String? title;
  final Widget? titleTrailing;
  final String value;
  final String? unit;
  final String? footnote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final bool isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: primary.withValues(alpha: 0.16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                primary.withValues(alpha: isDark ? 0.16 : 0.08),
                primary.withValues(alpha: isDark ? 0.09 : 0.04),
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if ((title ?? '').isNotEmpty || titleTrailing != null)
                    Row(
                      children: <Widget>[
                        if ((title ?? '').isNotEmpty)
                          Expanded(
                            child: Text(
                              title!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        ?titleTrailing,
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if ((unit ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(width: 6),
                        Text(
                          unit!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if ((footnote ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      footnote!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 圆角色块网格（主题颜色选择）。
class SettingsSwatchOption {
  const SettingsSwatchOption({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;
}

class SettingsSwatchPicker extends StatelessWidget {
  const SettingsSwatchPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<SettingsSwatchOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 6, AppSpacing.lg, 14),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: <Widget>[
          for (final SettingsSwatchOption option in options)
            _SwatchItem(
              option: option,
              selected: option.id == selectedId,
              onTap: () => onSelected(option.id),
              checkBackground: colorScheme.primary,
              checkForeground: colorScheme.onPrimary,
            ),
        ],
      ),
    );
  }
}

class _SwatchItem extends StatelessWidget {
  const _SwatchItem({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.checkBackground,
    required this.checkForeground,
  });

  final SettingsSwatchOption option;
  final bool selected;
  final VoidCallback onTap;
  final Color checkBackground;
  final Color checkForeground;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color base = option.color;
    final Color soft = Color.lerp(base, Colors.white, 0.45) ?? base;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 46,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[base, soft],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: base.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: selected ? checkBackground : Colors.transparent,
                        width: 1.6,
                      ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: checkBackground,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 1.6,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 9,
                          color: checkForeground,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 键帽组合（快捷键展示）。
class SettingsKeycap extends StatelessWidget {
  const SettingsKeycap({super.key, required this.keys});

  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    if (keys.isEmpty) {
      return Text(
        '未启用',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < keys.length; index += 1) ...<Widget>[
          if (index > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                '+',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.7 : 0.85,
              ),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Text(
              keys[index],
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 主操作按钮（唯一实心绿）。
class SettingsPrimaryButton extends StatelessWidget {
  const SettingsPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool enabled = onPressed != null && !busy;
    return SizedBox(
      height: 40,
      child: Material(
        color: enabled
            ? colorScheme.primary
            : colorScheme.primary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 次级操作按钮（浅底）。
class SettingsSecondaryButton extends StatelessWidget {
  const SettingsSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool enabled = onPressed != null && !busy;
    return SizedBox(
      height: 40,
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 按钮行：横向等分排列。
class SettingsButtonRow extends StatelessWidget {
  const SettingsButtonRow({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.only(top: AppSpacing.md),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          for (int index = 0; index < children.length; index += 1) ...<Widget>[
            if (index > 0) const SizedBox(width: AppSpacing.sm + 2),
            Expanded(child: children[index]),
          ],
        ],
      ),
    );
  }
}
