import 'dart:async';

import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation.dart';
import 'package:bilimusic/feature/daily/domain/daily_recommendation_state.dart';
import 'package:bilimusic/feature/daily/logic/daily_recommendation_controller.dart';
import 'package:bilimusic/feature/home/logic/collection_play_all.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/home/ui/components/collection_detail_header.dart';
import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyRecommendationPage extends ConsumerStatefulWidget {
  const DailyRecommendationPage({super.key});

  @override
  ConsumerState<DailyRecommendationPage> createState() =>
      _DailyRecommendationPageState();
}

class _DailyRecommendationPageState
    extends ConsumerState<DailyRecommendationPage> {
  static const String sourceLabel = '每日推荐';

  String? _resolvingTrackKey;
  bool _isPlayingAll = false;
  int _playAllResolved = 0;
  int _playAllTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref
            .read(dailyRecommendationControllerProvider.notifier)
            .ensureUpToDate(),
      );
    });
  }

  Future<void> _playTrack(DailyPick pick) async {
    if (_resolvingTrackKey != null) {
      return;
    }
    setState(() => _resolvingTrackKey = pick.key);
    try {
      // 这首已经解析过就直接播；没有就只解析这一首，别等整份补齐。
      unawaited(
        ref
            .read(dailyRecommendationControllerProvider.notifier)
            .resolvePending(),
      );
      final PlayableItem? item = await ref
          .read(musicChartResolverProvider)
          .resolve(pick);
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
        sourceLabel: sourceLabel,
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

  Future<void> _playAll(List<DailyPick> picks) async {
    if (_isPlayingAll || picks.isEmpty) {
      return;
    }
    setState(() {
      _isPlayingAll = true;
      _playAllResolved = 0;
      _playAllTotal = picks.length;
    });
    try {
      // 匹配到第一首就进播放页，其余边播边补；后台解析继续跑，结果会落盘。
      unawaited(
        ref
            .read(dailyRecommendationControllerProvider.notifier)
            .resolvePending(),
      );
      await CollectionPlayAllRunner(
        context: context,
        ref: ref,
        sourceLabel: sourceLabel,
        onProgress: (int resolved, int total) {
          if (!mounted) {
            return;
          }
          setState(() {
            _playAllResolved = resolved;
            _playAllTotal = total;
          });
        },
      ).run(picks);
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAll = false;
          _playAllResolved = 0;
          _playAllTotal = 0;
        });
      }
    }
  }

  void _retry() {
    unawaited(ref.read(dailyRecommendationControllerProvider.notifier).retry());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DailyRecommendationState state = ref.watch(
      dailyRecommendationControllerProvider,
    );

    return Scaffold(
      appBar: PageAppBar(title: const Text('每日推荐')),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: state.picks.isEmpty
            ? <Widget>[
                ..._buildEmptyState(state, colorScheme),
                const BottomPageSpacer(),
              ]
            : <Widget>[..._buildContent(state), const BottomPageSpacer()],
      ),
    );
  }

  List<Widget> _buildEmptyState(
    DailyRecommendationState state,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading) {
      return const <Widget>[_DailyLoading()];
    }
    if (state.hasError) {
      return <Widget>[
        StatusView(
          icon: Icons.cloud_off_rounded,
          iconColor: colorScheme.error,
          title: '每日推荐加载失败',
          description: '网络不太稳定，请稍后重试',
          onRetry: _retry,
        ),
      ];
    }
    return <Widget>[
      StatusView(
        icon: Icons.queue_music_rounded,
        title: '今天还没有推荐',
        description: '点一下重新挑一批适合你的歌',
        onRetry: _retry,
      ),
    ];
  }

  List<Widget> _buildContent(DailyRecommendationState state) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<DailyPick> picks = state.picks;

    return <Widget>[
      CollectionDetailHeader(
        coverUrl: picks.first.coverUrl.trim(),
        chipLabel: '每日推荐 · 每天 0 点更新',
        title: '每日推荐',
        meta: '共 ${picks.length} 首 · 今天更新',
        subMeta: state.isPersonalized ? '按你的收听口味挑选' : '先按各平台热门挑',
      ),
      const SizedBox(height: AppSpacing.lg),
      CollectionActionRow(
        playAllKey: const Key('dailyPlayAll'),
        canPlayAll: true,
        onPlayAll: () => _playAll(picks),
        busy: _isPlayingAll,
        resolved: _playAllResolved,
        total: _playAllTotal,
        playAllLabel: '播放全部',
      ),
      const SizedBox(height: AppSpacing.xl),
      Row(
        children: <Widget>[
          Text(
            '歌曲',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            '共 ${picks.length} 首',
            style: AppTextStyles.meta(theme, fontSize: 11.5).copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      for (int index = 0; index < picks.length; index += 1)
        TrackRowTile(
          rank: index + 1,
          title: picks[index].title,
          artist: picks[index].artist,
          coverUrl: picks[index].coverUrl,
          durationText: picks[index].durationText,
          isResolving: _resolvingTrackKey == picks[index].key,
          onTap: () => _playTrack(picks[index]),
        ),
    ];
  }
}

class _DailyLoading extends StatelessWidget {
  const _DailyLoading();

  @override
  Widget build(BuildContext context) {
    final Color placeholder = appSkeletonColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: placeholder,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 132,
                    height: 18,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 132,
                    height: 12,
                    decoration: BoxDecoration(
                      color: placeholder.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: placeholder,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (int index = 0; index < 6; index += 1) const _DailyTrackSkeleton(),
      ],
    );
  }
}

class _DailyTrackSkeleton extends StatelessWidget {
  const _DailyTrackSkeleton();

  @override
  Widget build(BuildContext context) {
    final Color placeholder = appSkeletonColor(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm - 2,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: placeholder,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: AppSizes.listCover,
              height: AppSizes.listCover,
              decoration: BoxDecoration(
                color: placeholder,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: placeholder.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
