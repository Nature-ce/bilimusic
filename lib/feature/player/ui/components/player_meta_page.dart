import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
import 'package:bilimusic/feature/radar/logic/radar_pick_reasons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class PlayerMetaPage extends ConsumerWidget {
  const PlayerMetaPage({super.key, required this.state, required this.item});

  final PlayerState state;
  final PlayableItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color activeColor =
        ref.watch(playerCoverColorControllerProvider) ??
        Theme.of(context).colorScheme.primary;
    final PlayableItem? currentItem = item;
    final RadarPick? radarPick = ref.watch(
      radarPickReasonsProvider.select(
        (Map<String, RadarPick> reasons) =>
            currentItem == null ? null : reasons[radarReasonKey(currentItem)],
      ),
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        PlayerMetaSheet(state: state, item: item),
        if (radarPick != null) ...<Widget>[
          const SizedBox(height: 12),
          PlayerRadarReasonCard(pick: radarPick),
        ],
        const SizedBox(height: 18),
        PlayerStatsGrid(item: item, activeColor: activeColor),
        const SizedBox(height: 18),
        if ((item?.description ?? '').trim().isNotEmpty)
          PlayerDescriptionCard(description: item!.description!),
      ],
    );
  }
}

/// 刷歌推过来的歌会带一句推荐理由（为什么推这首）。
class PlayerRadarReasonCard extends StatelessWidget {
  const PlayerRadarReasonCard({super.key, required this.pick});

  final RadarPick pick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IconData icon = switch (pick.reason) {
      RadarReason.familiarArtist => Icons.favorite_rounded,
      RadarReason.relatedPlaylist => Icons.playlist_add_check_rounded,
      RadarReason.explorer => Icons.explore_rounded,
      RadarReason.coldStart => Icons.radar_rounded,
    };
    return GlassPanel(
      tone: GlassTone.smoke,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: GlassTone.smoke.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '私人雷达',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: GlassTone.smoke.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pick.reasonLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: GlassTone.smoke.primaryText,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerMetaSheet extends StatelessWidget {
  const PlayerMetaSheet({super.key, required this.state, required this.item});

  final PlayerState state;
  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = normalizeDisplayTextOrEmpty(item?.title);
    final String author = normalizeDisplayTextOrEmpty(item?.author);

    return GlassPanel(
      tone: GlassTone.smoke,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '播放信息',
            style: theme.textTheme.titleMedium?.copyWith(
              color: GlassTone.smoke.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          PlayerMetaRow(label: '标题', value: title.isEmpty ? '--' : title),
          PlayerMetaRow(label: 'UP主', value: author.isEmpty ? '--' : author),
          PlayerMetaRow(label: '发布时间', value: item?.publishTimeText ?? '--'),
          PlayerMetaRow(label: 'BV', value: item?.bvid ?? '--'),
          PlayerMetaRow(
            label: '时长',
            value: resolvePlayerDurationLabel(state, item),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class PlayerMetaRow extends StatelessWidget {
  const PlayerMetaRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: GlassTone.smoke.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: GlassTone.smoke.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: GlassTone.smoke.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerStatsGrid extends StatelessWidget {
  const PlayerStatsGrid({
    super.key,
    required this.item,
    required this.activeColor,
  });

  final PlayableItem? item;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final List<PlayerStatEntry> stats = <PlayerStatEntry>[
      PlayerStatEntry(
        icon: Icons.play_circle_outline_rounded,
        label: '播放',
        value: item?.playCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.subtitles_outlined,
        label: '弹幕',
        value: item?.danmakuCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.thumb_up_alt_outlined,
        label: '点赞',
        value: item?.likeCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.monetization_on_outlined,
        label: '投币',
        value: item?.coinCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.star_border_rounded,
        label: '收藏',
        value: item?.favoriteCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.reply_all_rounded,
        label: '分享',
        value: item?.shareCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.chat_bubble_outline_rounded,
        label: '评论',
        value: item?.replyCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.timelapse_rounded,
        label: '时长',
        value: item?.durationText ?? '--:--',
      ),
    ];

    return GlassPanel(
      tone: GlassTone.smoke,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.85,
        ),
        itemBuilder: (BuildContext context, int index) {
          return PlayerStatCard(entry: stats[index], activeColor: activeColor);
        },
      ),
    );
  }
}

class PlayerStatEntry {
  const PlayerStatEntry({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class PlayerStatCard extends StatelessWidget {
  const PlayerStatCard({
    super.key,
    required this.entry,
    required this.activeColor,
  });

  final PlayerStatEntry entry;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              entry.icon,
              color: ColorUtil.getLight(activeColor),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: GlassTone.smoke.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: GlassTone.smoke.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerDescriptionCard extends StatelessWidget {
  const PlayerDescriptionCard({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GlassPanel(
      tone: GlassTone.smoke,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '简介',
            style: theme.textTheme.titleMedium?.copyWith(
              color: GlassTone.smoke.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: GlassTone.smoke.secondaryText,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
