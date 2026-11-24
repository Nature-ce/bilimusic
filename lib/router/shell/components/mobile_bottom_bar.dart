import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_like_button.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

const double mobileBottomBarRadius = 24;
const double mobileBottomBarPlayerRowHeight = 52;
const double mobileBottomBarTabsHeight = 50;

/// 底栏的玻璃档：比播放页的 smoke/frost 更透，并带一点主题色，
/// 让内容从底下透出来时不会糊成一块灰。
LiquidGlassSettings mobileBottomBarGlassSettings(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;
  final bool isDark = theme.brightness == Brightness.dark;
  final Color base = isDark ? const Color(0xFF101215) : Colors.white;
  final Color tinted = Color.alphaBlend(
    colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.08),
    base,
  );

  return LiquidGlassSettings(
    bodyMode: GlassBodyMode.clear,
    glassColor: tinted.withValues(alpha: isDark ? 0.34 : 0.24),
    thickness: 18,
    blur: 26,
    chromaticAberration: 0,
    saturation: 1.7,
    lightIntensity: 0.55,
    refractiveIndex: 1.12,
  );
}

/// 贴底整条：播放行 + 进度 + 导航行装在同一个容器里。
///
/// [showTabs] 为 false 时（歌单、收藏夹、下载这类详情页）只保留播放行，
/// 高度从约 106dp 降到约 60dp；[glass] 打开时换成半透明磨砂材质。
class MobileBottomBar extends ConsumerWidget {
  const MobileBottomBar({
    super.key,
    required this.state,
    required this.showPlayer,
    required this.showTabs,
    required this.selectedIndex,
    required this.glass,
    required this.isFavorite,
    required this.onTabSelected,
    required this.onOpenPlayer,
    required this.onTogglePlayback,
    required this.onOpenQueue,
    required this.onToggleFavorite,
    this.playerRowWrapper,
  });

  final PlayerState state;
  final bool showPlayer;
  final bool showTabs;
  final int selectedIndex;
  final bool glass;
  final bool isFavorite;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onOpenPlayer;
  final VoidCallback onTogglePlayback;
  final VoidCallback onOpenQueue;
  final VoidCallback onToggleFavorite;

  /// 播放行的外层包装，用来挂滑动手势（上一首 / 下一首）。
  final Widget Function(Widget child)? playerRowWrapper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final PlayerDisplayInfo display = ref.watch(playerDisplayProvider);

    final Widget content = SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showPlayer)
            playerRowWrapper?.call(
                  _PlayerRow(
                    state: state,
                    display: display,
                    isFavorite: isFavorite,
                    onOpenPlayer: onOpenPlayer,
                    onTogglePlayback: onTogglePlayback,
                    onOpenQueue: onOpenQueue,
                    onToggleFavorite: onToggleFavorite,
                  ),
                ) ??
                _PlayerRow(
                  state: state,
                  display: display,
                  isFavorite: isFavorite,
                  onOpenPlayer: onOpenPlayer,
                  onTogglePlayback: onTogglePlayback,
                  onOpenQueue: onOpenQueue,
                  onToggleFavorite: onToggleFavorite,
                ),
          if (showTabs)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _TabRow(
                selectedIndex: selectedIndex,
                onSelected: onTabSelected,
              ),
            )
          else if (showPlayer)
            const SizedBox(height: 8),
        ],
      ),
    );

    if (glass) {
      return GlassPanel(
        settings: mobileBottomBarGlassSettings(context),
        shape: const LiquidVerticalRoundedSuperellipse(
          topRadius: mobileBottomBarRadius,
          bottomRadius: 0,
        ),
        child: content,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: appCardSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(mobileBottomBarRadius),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: appShadowColor(context),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.state,
    required this.display,
    required this.isFavorite,
    required this.onOpenPlayer,
    required this.onTogglePlayback,
    required this.onOpenQueue,
    required this.onToggleFavorite,
  });

  final PlayerState state;
  final PlayerDisplayInfo display;
  final bool isFavorite;
  final VoidCallback onOpenPlayer;
  final VoidCallback onTogglePlayback;
  final VoidCallback onOpenQueue;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String title = display.title ?? '未选择播放内容';
    final String subtitle = buildMiniPlayerSubtitle(
      state,
      displayArtist: display.artist,
    );
    final bool hasStatusHint = state.statusHint != null;
    final String headline = hasStatusHint || subtitle.isEmpty
        ? title
        : '$title - $subtitle';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenPlayer,
        child: SizedBox(
          height: mobileBottomBarPlayerRowHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
            child: Row(
              children: <Widget>[
                MiniPlayerArtwork(coverUrl: display.coverUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (hasStatusHint) ...<Widget>[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                FavoriteLikeIconButton(
                  isLiked: isFavorite,
                  isEnabled: state.currentItem != null,
                  iconSize: 22,
                  onPressed: onToggleFavorite,
                ),
                _PlayPauseButton(
                  isPlaying: state.isPlaying,
                  onPressed: onTogglePlayback,
                ),
                IconButton(
                  onPressed: onOpenQueue,
                  tooltip: '播放队列',
                  iconSize: 22,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                  icon: const Icon(Icons.queue_music_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      tooltip: isPlaying ? '暂停' : '播放',
      iconSize: 28,
      color: colorScheme.primary,
      icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({required this.selectedIndex, required this.onSelected});

  static const List<({IconData icon, IconData selectedIcon, String label})>
  _tabs = <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: '首页'),
    (
      icon: Icons.radar_outlined,
      selectedIcon: Icons.radar_rounded,
      label: '刷歌',
    ),
    (
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: '我的',
    ),
  ];

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mobileBottomBarTabsHeight,
      child: Row(
        children: <Widget>[
          for (int index = 0; index < _tabs.length; index += 1)
            Expanded(
              child: _TabItem(
                icon: _tabs[index].icon,
                selectedIcon: _tabs[index].selectedIcon,
                label: _tabs[index].label,
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(selected ? selectedIcon : icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                letterSpacing: 0.2,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
