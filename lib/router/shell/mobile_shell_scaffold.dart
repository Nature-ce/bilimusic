import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/home/ui/components/home_back_to_top_button.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/player_gestures.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:bilimusic/router/shell/components/mobile_bottom_bar.dart';
import 'package:bilimusic/router/util/mobile_branch_navigator_keys.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:bilimusic/router/util/shell_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MobileShellScaffold extends ConsumerStatefulWidget {
  const MobileShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
    required this.chrome,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;
  final MobileChromeConfig chrome;

  @override
  ConsumerState<MobileShellScaffold> createState() =>
      _MobileShellScaffoldState();
}

class _MobileShellScaffoldState extends ConsumerState<MobileShellScaffold> {
  static const Curve _animationCurve = Curves.easeInOutCubic;

  Offset? _miniPlayerDragOrigin;

  @override
  void initState() {
    super.initState();
    UpdateChecker.scheduleStartupCheck(context);
    _reportShellLocation();
  }

  @override
  void didUpdateWidget(covariant MobileShellScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation) {
      _reportShellLocation();
    }
  }

  /// 把当前一级路由同步给页面：indexedStack 下 tab 页一直挂着，
  /// 页面靠这个信号知道自己被重新切回来了。
  void _reportShellLocation() {
    final String location = widget.currentLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(shellLocationProvider.notifier).update(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playerPageVisibilityListenable,
      builder: (BuildContext context, bool isPlayerPageVisible, _) {
        return _buildScaffold(context, isPlayerPageVisible);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, bool isPlayerPageVisible) {
    final PlayerState playerState = ref.watch(playerControllerProvider);
    final bool useGlassBar = ref.watch(appearanceSettingLogicProvider);
    final bool showTabs = widget.chrome.showBottomTabs && !isPlayerPageVisible;
    final bool showMiniPlayer =
        widget.chrome.showMiniPlayer &&
        playerState.hasItem &&
        !isPlayerPageVisible;
    final PlayableItem? currentItem = playerState.currentItem;
    final bool isFavorite = currentItem == null
        ? false
        : ref.watch(favoritesControllerProvider).isLiked(currentItem);

    return GlassPage(
      child: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        floatingActionButton: _buildHomeBackToTop(isPlayerPageVisible),
        bottomNavigationBar: _animateChrome(
          visible: showTabs || showMiniPlayer,
          child: () => MobileBottomBar(
            state: playerState,
            showPlayer: showMiniPlayer,
            showTabs: showTabs,
            selectedIndex: widget.navigationShell.currentIndex,
            glass: useGlassBar,
            isFavorite: isFavorite,
            onTabSelected: _selectBranch,
            onOpenPlayer: _openMiniPlayer,
            onTogglePlayback: _togglePlayback,
            onOpenQueue: _openQueue,
            onToggleFavorite: _toggleFavorite,
            playerRowWrapper: _buildMiniPlayerGestures,
          ),
        ),
      ),
    );
  }

  Widget? _buildHomeBackToTop(bool isPlayerPageVisible) {
    if (isPlayerPageVisible || widget.currentLocation != '/home') {
      return null;
    }
    if (!ref.watch(homeBackToTopVisibilityProvider)) {
      return null;
    }
    // 底栏会盖在 FAB 之上，抬高一点避免按钮被遮住导致点不到。
    return const Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm + 4),
      child: HomeBackToTopButton(),
    );
  }

  Widget _animateChrome({
    required bool visible,
    required Widget Function() child,
  }) {
    return AnimatedSwitcher(
      duration: AppMotion.resolve(context, AppMotion.base),
      switchInCurve: _animationCurve,
      switchOutCurve: _animationCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: visible ? child() : const SizedBox.shrink(),
    );
  }

  void _selectBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Widget _buildMiniPlayerGestures(Widget child) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        _miniPlayerDragOrigin = event.position;
      },
      onPointerCancel: (PointerCancelEvent event) {
        _miniPlayerDragOrigin = null;
      },
      onPointerUp: (PointerUpEvent event) {
        final Offset? origin = _miniPlayerDragOrigin;
        _miniPlayerDragOrigin = null;
        if (origin == null) {
          return;
        }
        final Offset delta = event.position - origin;
        switch (PlayerGestureMath.miniPlayerSwipe(delta)) {
          case MiniPlayerSwipeAction.openPlayer:
            HapticFeedback.selectionClick();
            _openMiniPlayer();
          case MiniPlayerSwipeAction.nextTrack:
            HapticFeedback.selectionClick();
            ref.read(playerControllerProvider.notifier).skipToNext();
          case MiniPlayerSwipeAction.previousTrack:
            HapticFeedback.selectionClick();
            ref.read(playerControllerProvider.notifier).skipToPrevious();
          case MiniPlayerSwipeAction.none:
            break;
        }
      },
      child: child,
    );
  }

  Future<void> _openMiniPlayer() {
    final int currentIndex = widget.navigationShell.currentIndex;
    final NavigatorState? branchNavigator =
        currentIndex >= 0 && currentIndex < mobileBranchNavigatorKeys.length
        ? mobileBranchNavigatorKeys[currentIndex].currentState
        : null;

    return openPlayerPage(context, navigator: branchNavigator);
  }

  void _togglePlayback() {
    ref.read(playerControllerProvider.notifier).togglePlayback();
  }

  Future<void> _toggleFavorite() async {
    final PlayableItem? item = ref.read(playerControllerProvider).currentItem;
    if (item == null) {
      return;
    }
    await ref.read(favoritesControllerProvider.notifier).toggleLiked(item);
  }

  void _openQueue() {
    final PlayerState state = ref.read(playerControllerProvider);
    if (!state.hasQueue) {
      return;
    }
    showPlayerQueueSheet(
      context: context,
      state: state,
      glass: ref.read(appearanceSettingLogicProvider),
    );
  }
}
