import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/search_bar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/ui/components/music_chart_section.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformUtil.isDesktop
          ? null
          : AppBar(
              toolbarHeight: 48,
              title: CommonSearchBar(
                onTap: () => context.push('/search?from=/home'),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(musicChartControllerProvider.notifier).refresh(),
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: PlatformUtil.isDesktop
              ? const EdgeInsets.symmetric(horizontal: 0)
              : const EdgeInsets.fromLTRB(16, 16, 16, 0),
          children: const <Widget>[MusicChartSection(), BottomPageSpacer()],
        ),
      ),
    );
  }
}
