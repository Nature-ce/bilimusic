import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/search_bar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/home/logic/hot_playlist_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/home_recommend_section.dart';
import 'package:bilimusic/feature/home/ui/components/home_section_switch.dart';
import 'package:bilimusic/feature/home/ui/components/hot_playlist_section.dart';
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

  late final PageController _pageController;
  late final ScrollController _chartsController;
  late final ScrollController _playlistsController;
  int _pageIndex = 0;

  ScrollController get _activeController =>
      _pageIndex == HomeSection.charts.index
      ? _chartsController
      : _playlistsController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _chartsController = ScrollController()..addListener(_handleScroll);
    _playlistsController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _bindActiveController(),
    );
  }

  @override
  void dispose() {
    _chartsController
      ..removeListener(_handleScroll)
      ..dispose();
    _playlistsController
      ..removeListener(_handleScroll)
      ..dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _bindActiveController() {
    if (!mounted) {
      return;
    }
    ref
        .read(homeActiveScrollControllerProvider.notifier)
        .bind(_activeController);
  }

  void _handleScroll() {
    final ScrollController controller = _activeController;
    final bool visible =
        controller.hasClients && controller.offset > _backToTopThreshold;
    ref.read(homeBackToTopVisibilityProvider.notifier).setVisible(visible);
  }

  Future<void> _handleRefresh() {
    return Future.wait(<Future<void>>[
      ref.read(musicChartControllerProvider.notifier).refresh(),
      ref.read(hotPlaylistControllerProvider.notifier).refresh(),
    ]);
  }

  void _selectSection(HomeSection section) {
    final int target = section.index;
    if (target == _pageIndex || !_pageController.hasClients) {
      return;
    }
    final Duration duration = AppMotion.resolve(context, AppMotion.base);
    if (duration <= Duration.zero) {
      // 系统关闭动画时 animateToPage 会拿到零时长（偏移算成 NaN，页面反而卡住），直接跳页。
      _pageController.jumpToPage(target);
      return;
    }
    _pageController.animateToPage(
      target,
      duration: duration,
      curve: AppMotion.standard,
    );
  }

  void _handlePageChanged(int index) {
    setState(() => _pageIndex = index);
    _bindActiveController();
    _handleScroll();
  }

  @override
  Widget build(BuildContext context) {
    final HomeSection section = HomeSection.values[_pageIndex];

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
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              PlatformUtil.isDesktop ? AppSpacing.lg : 16,
              16,
              PlatformUtil.isDesktop ? AppSpacing.lg : 16,
              0,
            ),
            child: HomeSectionSwitch(
              selected: section,
              onSelected: _selectSection,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              children: <Widget>[
                _HomeSectionPage(
                  controller: _chartsController,
                  onRefresh: _handleRefresh,
                  child: const HomeRecommendSection(),
                ),
                _HomeSectionPage(
                  controller: _playlistsController,
                  onRefresh: _handleRefresh,
                  child: const HotPlaylistSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个 section 的可滚动页面：刷新 + 列表 + 底部留白。
class _HomeSectionPage extends StatelessWidget {
  const _HomeSectionPage({
    required this.controller,
    required this.onRefresh,
    required this.child,
  });

  final ScrollController controller;
  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: PlatformUtil.isDesktop
            ? const EdgeInsets.symmetric(horizontal: 0)
            : const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: <Widget>[child, const BottomPageSpacer()],
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
