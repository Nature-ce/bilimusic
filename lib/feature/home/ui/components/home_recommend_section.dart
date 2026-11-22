import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/home_chart_platform_card.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/radar/logic/music_radar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 首页「推荐」：快捷入口 + 私人雷达大卡 + 四平台排行榜卡片入口。
class HomeRecommendSection extends ConsumerStatefulWidget {
  const HomeRecommendSection({super.key});

  @override
  ConsumerState<HomeRecommendSection> createState() =>
      _HomeRecommendSectionState();
}

class _HomeRecommendSectionState extends ConsumerState<HomeRecommendSection> {
  String? _resolvingTrackKey;

  @override
  Widget build(BuildContext context) {
    final MusicChartState state = ref.watch(musicChartControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _QuickActions(),
        const SizedBox(height: AppSpacing.lg),
        const _RadarHeroCard(),
        const _SectionHeader(title: '排行榜', subtitle: 'Charts'),
        _ChartCardRow(state: state, onPlay: _playTrack, onTrackTap: _playTrack),
      ],
    );
  }

  Future<void> _playTrack(MusicChartTrack track) async {
    final PlayableItem? directItem = track.directItem;
    if (directItem != null) {
      await PlayerUtil.playItemAndOpenPlayer(
        context,
        ref,
        item: directItem,
        sourceLabel: track.chart.displayTitle,
      );
      return;
    }
    if (_resolvingTrackKey != null) {
      return;
    }
    setState(() => _resolvingTrackKey = track.key);
    try {
      final PlayableItem? item = await ref
          .read(musicChartResolverProvider)
          .resolve(track);
      if (!mounted) {
        return;
      }
      if (item == null) {
        ToastUtil.show('没找到匹配的 B 站视频');
        return;
      }
      await PlayerUtil.playItemAndOpenPlayer(
        context,
        ref,
        item: item,
        sourceLabel: track.chart.displayTitle,
      );
    } on Object {
      if (mounted) {
        ToastUtil.show('匹配失败，请稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() => _resolvingTrackKey = null);
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, AppSpacing.xl, 2, AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Text(
              subtitle!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const List<({String label, IconData icon, String route})> _items =
      <({String label, IconData icon, String route})>[
        (label: '私人雷达', icon: Icons.radar_rounded, route: '/radar'),
        (label: '最近播放', icon: Icons.history_rounded, route: '/profile/recent'),
        (
          label: '我的收藏',
          icon: Icons.favorite_rounded,
          route: '/profile/favorites/liked',
        ),
        (
          label: '下载',
          icon: Icons.download_rounded,
          route: '/profile/downloads',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        for (final ({String label, IconData icon, String route}) item in _items)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => context.go(item.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RadarHeroCard extends ConsumerWidget {
  const _RadarHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final radar = ref.watch(musicRadarControllerProvider);
    final int count = radar.isPersonalized ? radar.listenedCount : 0;
    final String title = radar.isPersonalized
        ? '按你的口味挑了 ${radar.tracks.length} 首'
        : '还没听够，先按各平台热门挑';
    final String subtitle = radar.isPersonalized
        ? '已根据你最近收听 ${count > 0 ? count : radar.tracks.length} 首歌调整'
        : '多听几首后会自动学习你的口味';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.14),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.radar_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                '私人雷达',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => context.go('/radar'),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('开始听'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCardRow extends StatelessWidget {
  const _ChartCardRow({
    required this.state,
    required this.onPlay,
    required this.onTrackTap,
  });

  final MusicChartState state;
  final ValueChanged<MusicChartTrack> onPlay;
  final ValueChanged<MusicChartTrack> onTrackTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final MusicChartPlatform platform in MusicChartPlatform.values)
            Padding(
              padding: EdgeInsets.only(
                right: platform == MusicChartPlatform.values.last
                    ? 0
                    : AppSpacing.md,
              ),
              child: Builder(
                builder: (BuildContext context) {
                  final MusicChartEntry entry =
                      state.entryOf(platform) ??
                      MusicChartEntry(
                        chart: MusicChartCatalog.defaultChartOf(platform),
                      );
                  return HomeChartPlatformCard(
                    entry: entry,
                    selected: state.selected == platform,
                    onOpen: () => context.push('/home/charts/${platform.name}'),
                    onPlay: () {
                      if (entry.tracks.isNotEmpty) {
                        onPlay(entry.tracks.first);
                      }
                    },
                    onTrackTap: onTrackTap,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
