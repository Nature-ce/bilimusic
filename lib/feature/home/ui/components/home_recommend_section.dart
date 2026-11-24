import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/home_chart_platform_card.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 首页「推荐」：今日推荐墙（每日推荐前 10 首）+ 四平台排行榜卡片入口。
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
        const _DailyWall(),
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

class _DailyWall extends ConsumerWidget {
  const _DailyWall();

  static const int _previewCount = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DailyRecommendationState state = ref.watch(
      dailyRecommendationControllerProvider,
    );
    final List<DailyPick> picks = state.picks;
    final List<DailyPick> preview = picks.length > _previewCount
        ? picks.take(_previewCount).toList(growable: false)
        : picks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(2, AppSpacing.lg, 2, 0),
          child: Row(
            children: <Widget>[
              Text(
                '今日推荐',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              if (preview.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/daily'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('查看全部 ›'),
                ),
            ],
          ),
        ),
        if (preview.isEmpty)
          _DailyWallPlaceholder(
            isLoading: state.isLoading,
            hasError: state.hasError,
            onRetry: () => ref
                .read(dailyRecommendationControllerProvider.notifier)
                .retry(),
          )
        else
          SizedBox(
            height: _DailyWallCard.height + 10,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(2, 9, 2, 0),
              itemCount: preview.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) =>
                  _DailyWallCard(pick: preview[index], rank: index + 1),
            ),
          ),
      ],
    );
  }
}

class _DailyWallCard extends StatelessWidget {
  const _DailyWallCard({required this.pick, required this.rank});

  static const double coverSize = 96;
  static const double height = 96 + 6 + 17 + 2 + 14;

  final DailyPick pick;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/daily'),
      child: SizedBox(
        width: coverSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: coverSize,
              height: coverSize,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CommonCachedImage(
                      imageUrl: pick.coverUrl,
                      width: coverSize,
                      height: coverSize,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      placeholder: _DailyWallCoverFallback(primary: primary),
                      errorWidget: _DailyWallCoverFallback(primary: primary),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          fontSize: 9.5,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pick.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pick.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyWallCoverFallback extends StatelessWidget {
  const _DailyWallCoverFallback({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(Icons.music_note_rounded, color: primary, size: 28),
    );
  }
}

class _DailyWallPlaceholder extends StatelessWidget {
  const _DailyWallPlaceholder({
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (hasError && !isLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(2, 10, 2, 2),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '今日推荐生成失败',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 2),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < 4; index += 1) ...<Widget>[
            if (index > 0) const SizedBox(width: 10),
            Container(
              width: _DailyWallCard.coverSize,
              height: _DailyWallCard.coverSize,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ],
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
