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
import 'package:bilimusic/feature/radar/domain/music_radar_state.dart';
import 'package:bilimusic/feature/radar/domain/radar_pick.dart';
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

  static const List<
    ({String label, String glyph, List<Color> colors, String route})
  >
  _items = <({String label, String glyph, List<Color> colors, String route})>[
    (
      label: '私人雷达',
      glyph: '雷',
      colors: <Color>[Color(0xFF3E7BD0), Color(0xFF6AA3E8)],
      route: '/radar',
    ),
    (
      label: '最近播放',
      glyph: '近',
      colors: <Color>[Color(0xFFC97B3E), Color(0xFFE3A46A)],
      route: '/profile/recent',
    ),
    (
      label: '我的收藏',
      glyph: '藏',
      colors: <Color>[Color(0xFF8B5CC4), Color(0xFFB183E0)],
      route: '/profile/favorites/liked',
    ),
    (
      label: '下载',
      glyph: '下',
      colors: <Color>[Color(0xFF2E7D5B), Color(0xFF4FA97C)],
      route: '/profile/downloads',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        for (final ({
              String label,
              String glyph,
              List<Color> colors,
              String route,
            })
            item
            in _items)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => context.go(item.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: item.colors,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: item.colors.last.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        item.glyph,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
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
    final MusicRadarState radar = ref.watch(musicRadarControllerProvider);
    final int trackCount = radar.tracks.length;
    final bool personalized = radar.isPersonalized && trackCount > 0;
    final String title = personalized
        ? '今天为你挑了 $trackCount 首'
        : trackCount > 0
        ? '先按各平台热门挑了 $trackCount 首'
        : '进来挑第一批适合你的歌';
    final String subtitle = personalized
        ? _reasonSummary(radar)
        : '多听几首后会自动学习你的口味';

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -22,
            top: -30,
            child: Transform.rotate(
              angle: 0.22,
              child: _RadarDecorSquare(
                size: 86,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 58,
            top: -34,
            child: Transform.rotate(
              angle: -0.16,
              child: _RadarDecorSquare(
                size: 56,
                color: colorScheme.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        personalized ? '私人雷达 · 随收听更新' : '私人雷达',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    FilledButton.icon(
                      onPressed: () => context.go('/radar'),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('开始听'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md + 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _reasonSummary(MusicRadarState radar) {
    final List<RadarPick> picks = radar.picks
        .where((RadarPick pick) => pick.reason != RadarReason.coldStart)
        .toList(growable: false);
    if (picks.isEmpty) {
      final int listened = radar.listenedCount;
      return listened > 0 ? '已根据你最近收听 $listened 首歌调整' : '已根据你的收听口味挑选';
    }
    int familiar = 0;
    int related = 0;
    int explorer = 0;
    for (final RadarPick pick in picks) {
      switch (pick.reason) {
        case RadarReason.familiarArtist:
          familiar += 1;
        case RadarReason.relatedPlaylist:
          related += 1;
        case RadarReason.explorer:
          explorer += 1;
        case RadarReason.coldStart:
          break;
      }
    }
    final List<int> shares = _percentages(<int>[familiar, related, explorer]);
    final List<String> parts = <String>[
      if (shares[0] > 0) '常听歌手 ${shares[0]}%',
      if (shares[1] > 0) '同歌单 ${shares[1]}%',
      if (shares[2] > 0) '换口味 ${shares[2]}%',
    ];
    return parts.isEmpty ? '已根据你的收听口味挑选' : parts.join(' · ');
  }

  /// 让三段占比取整后正好加起来 100（最大余数法）。
  static List<int> _percentages(List<int> counts) {
    final int total = counts.fold<int>(0, (int sum, int value) => sum + value);
    if (total <= 0) {
      return const <int>[0, 0, 0];
    }
    final List<double> exact = counts
        .map((int value) => value * 100 / total)
        .toList(growable: false);
    final List<int> floors = exact
        .map((double value) => value.floor())
        .toList(growable: false);
    int remainder =
        100 - floors.fold<int>(0, (int sum, int value) => sum + value);
    final List<int> order =
        List<int>.generate(counts.length, (int index) => index)..sort(
          (int a, int b) => (exact[b] - exact[b].floorToDouble()).compareTo(
            exact[a] - exact[a].floorToDouble(),
          ),
        );
    final List<int> result = List<int>.of(floors);
    for (int index = 0; index < order.length && remainder > 0; index += 1) {
      result[order[index]] += 1;
      remainder -= 1;
    }
    return result;
  }
}

class _RadarDecorSquare extends StatelessWidget {
  const _RadarDecorSquare({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.32),
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
