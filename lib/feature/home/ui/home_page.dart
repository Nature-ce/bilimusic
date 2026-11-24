import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/search_bar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/home_section_switch.dart';
import 'package:bilimusic/feature/home/ui/components/hot_playlist_section.dart';
import 'package:bilimusic/feature/home/ui/components/home_recommend_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const double _backToTopThreshold = 480;

  late final ScrollController _scrollController;
  late final HomeBackToTopVisibility _backToTopVisibility;
  HomeSection _section = HomeSection.charts;

  @override
  void initState() {
    super.initState();
    _scrollController = ref.read(homeScrollControllerProvider);
    _backToTopVisibility = ref.read(homeBackToTopVisibilityProvider.notifier);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _backToTopVisibility.setVisible(false);
    super.dispose();
  }

  void _handleScroll() {
    final bool visible =
        _scrollController.hasClients &&
        _scrollController.offset > _backToTopThreshold;
    _backToTopVisibility.setVisible(visible);
  }

  Future<void> _handleRefresh() {
    // 两个 section 一起刷：只刷当前 tab 会导致「在热榜下拉刷新，切到热门歌单还是旧数据」。
    return Future.wait(<Future<void>>[
      ref.read(musicChartControllerProvider.notifier).refresh(),
      ref.read(hotPlaylistControllerProvider.notifier).refresh(),
    ]);
  }

  void _selectSection(HomeSection section) {
    if (_section == section) {
      return;
    }
    setState(() => _section = section);
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.jumpTo(0);
    }
  }

  /// 横向滑动切换 section 的速度阈值（dp/s）。
  static const double _swipeVelocityThreshold = 140;

  /// 慢速拖拽时的位移阈值（dp），避免只能靠甩动手势切换。
  static const double _swipeDistanceThreshold = 72;

  double _horizontalDragDx = 0;

  void _handleHorizontalDragStart(DragStartDetails details) {
    _horizontalDragDx = 0;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDx += details.primaryDelta ?? 0;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    final double dx = _horizontalDragDx;
    _horizontalDragDx = 0;
    final bool flung = velocity.abs() >= _swipeVelocityThreshold;
    final bool dragged = dx.abs() >= _swipeDistanceThreshold;
    if (!flung && !dragged) {
      return;
    }
    final bool toPlaylists = flung ? velocity < 0 : dx < 0;
    _selectSection(toPlaylists ? HomeSection.playlists : HomeSection.charts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformUtil.isDesktop
          ? null
          : AppBar(
              toolbarHeight: 56,
              title: Row(
                children: <Widget>[
                  Expanded(
                    child: CommonSearchBar(
                      hintText: '搜索歌曲 / UP主 / 视频',
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm - 1,
                      ),
                      onTap: () => context.push('/search'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const _HomeAvatarButton(),
                ],
              ),
            ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _handleHorizontalDragStart,
          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: PlatformUtil.isDesktop
                ? const EdgeInsets.symmetric(horizontal: 0)
                : const EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: <Widget>[
              HomeSectionSwitch(selected: _section, onSelected: _selectSection),
              const SizedBox(height: AppSpacing.lg),
              if (_section == HomeSection.charts)
                const HomeRecommendSection()
              else
                const HotPlaylistSection(),
              const BottomPageSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAvatarButton extends ConsumerWidget {
  const _HomeAvatarButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String face =
        ref.watch(biliSessionControllerProvider)?.face?.trim() ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () => context.go('/profile'),
      child: SizedBox(
        width: 32,
        height: 32,
        child: face.isEmpty
            ? CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.8,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : CommonCachedImage(
                imageUrl: face,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(99),
              ),
      ),
    );
  }
}
