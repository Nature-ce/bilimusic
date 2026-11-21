import 'package:bilimusic/common/components/desktop/desktop_top_bar.dart';
import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/home/logic/home_back_to_top.dart';
import 'package:bilimusic/feature/home/ui/components/home_back_to_top_button.dart';
import 'package:bilimusic/feature/profile/ui/desktop_profile_sidebar.dart';
import 'package:bilimusic/feature/player/ui/desktop/desktop_player_bar.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:bilimusic/router/util/shell_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class DesktopShellScaffold extends ConsumerStatefulWidget {
  const DesktopShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  static const double _macOSTitleBarHeight = 24;

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  ConsumerState<DesktopShellScaffold> createState() =>
      _DesktopShellScaffoldState();
}

class _DesktopShellScaffoldState extends ConsumerState<DesktopShellScaffold> {
  @override
  void initState() {
    super.initState();
    UpdateChecker.scheduleStartupCheck(context);
    _reportShellLocation();
  }

  @override
  void didUpdateWidget(covariant DesktopShellScaffold oldWidget) {
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

  Widget? _buildHomeBackToTop() {
    if (widget.currentLocation != '/home') {
      return null;
    }
    if (!ref.watch(homeBackToTopVisibilityProvider)) {
      return null;
    }
    return const HomeBackToTopButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildHomeBackToTop(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (PlatformUtil.isMacOS)
                const _MacOSTitleBarDragArea(
                  height: DesktopShellScaffold._macOSTitleBarHeight,
                ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DesktopProfileSidebar(
                      currentLocation: widget.currentLocation,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              key: desktopSidePanelHostKey,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: <Widget>[
                                  const DesktopTopBar(),
                                  Expanded(
                                    child: Container(
                                      child: widget.navigationShell,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const DesktopPlayerBar(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// macOS 顶部交通灯按钮的留白区域，同时支持拖动窗口。
class _MacOSTitleBarDragArea extends StatelessWidget {
  const _MacOSTitleBarDragArea({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: SizedBox(height: height, width: double.infinity),
    );
  }
}
