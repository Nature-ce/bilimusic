import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_source_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:bilimusic/feature/player/ui/components/player_landscape_page.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
import 'package:bilimusic/feature/player/ui/player_gestures.dart';
import 'package:bilimusic/feature/player/ui/player_page_pager.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_settings_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_top_bar.dart';
import 'package:bilimusic/feature/player/domain/queue_source.dart';
import 'package:bilimusic/feature/radar/logic/radar_refresh_requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({
    super.key,
    this.initialItem,
    this.embedded = false,
    this.bottomInset = 0,
    this.onExit,
  });

  final PlayableItem? initialItem;

  /// 嵌入到 Tab 里（例如刷歌页）时使用：不响应下滑关闭。
  final bool embedded;

  /// 嵌入时底部需要预留的空白，避免被悬浮导航遮挡。
  final double bottomInset;

  /// 嵌入时的退出入口（左上角向下箭头）；为 null 时不显示该按钮。
  final VoidCallback? onExit;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  int _currentPage = 1;
  double _dismissDragDy = 0;
  Offset? _dismissPointerOrigin;
  Duration? _dismissPointerAt;
  Offset? _topBarDragOrigin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialItem();
      });
    }
  }

  void _loadInitialItem() {
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayerState state = ref.read(playerControllerProvider);
    if (state.currentItem?.stableId == item.stableId && state.isReady) {
      return;
    }
    controller.setQueue(
      <PlayableItem>[item],
      startIndex: 0,
      sourceLabel: '当前播放',
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(
      playerControllerProvider.select(_withoutPlaybackPosition),
    );
    final PlayerDisplayInfo display = ref.watch(playerDisplayProvider);
    final favoritesState = ref.watch(favoritesControllerProvider);
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final bool isFavorite = item != null ? favoritesState.isLiked(item) : false;
    final Color? coverColor = ref.watch(playerCoverColorControllerProvider);

    if (MediaQuery.orientationOf(context) == Orientation.landscape) {
      return Theme(
        data: _playerTheme(context),
        child: Scaffold(
          backgroundColor: _playerBackground,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: PlayerDynamicBackdrop(
                  baseColor: coverColor,
                  coverUrl: display.coverUrl,
                ),
              ),
              SafeArea(
                child: PlayerLandscapePage(
                  state: state,
                  item: item,
                  display: display,
                  activeColor: coverColor,
                  isFavorite: isFavorite,
                  onFavoriteToggle: item == null
                      ? null
                      : () => _toggleFavorite(item),
                  onSeek: _seekFromProgressBar,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: _playerTheme(context),
      child: Scaffold(
        backgroundColor: _playerBackground,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PlayerDynamicBackdrop(
                baseColor: coverColor,
                coverUrl: display.coverUrl,
              ),
            ),
            Transform.translate(
              offset: Offset(0, _dismissDragDy),
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handleDismissPointerDown,
                onPointerMove: _handleDismissPointerMove,
                onPointerUp: _handleDismissPointerUp,
                onPointerCancel: _handleDismissPointerCancel,
                child: SafeArea(
                  minimum: EdgeInsets.only(bottom: widget.bottomInset),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),

                      child: Column(
                        children: <Widget>[
                          _buildTopBar(context, item),
                          const SizedBox(height: 18),
                          Expanded(
                            child: PlayerPagePager(
                              index: _currentPage,
                              pageCount: 3,
                              onIndexChanged: (int page) =>
                                  setState(() => _currentPage = page),
                              buildPage: (BuildContext pageContext, int page) =>
                                  _buildPage(
                                    pageContext: pageContext,
                                    page: page,
                                    state: state,
                                    display: display,
                                    item: item,
                                    isFavorite: isFavorite,
                                    coverColor: coverColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 主页面下滑退出播放页：拖到一定距离或甩得够快就关，否则弹回。
  ///
  /// 用原始指针事件而不是 GestureDetector：主页面里各种子控件（进度条、按钮、
  /// 可滚动列表）会抢手势竞技场，竖向拖动经常轮不到父级。
  void _handleDismissPointerDown(PointerDownEvent event) {
    _dismissPointerOrigin = event.position;
    _dismissPointerAt = event.timeStamp;
  }

  void _handleDismissPointerMove(PointerMoveEvent event) {
    final Offset? origin = _dismissPointerOrigin;
    if (origin == null || _currentPage != 1) {
      return;
    }
    final double next = (event.position.dy - origin.dy).clamp(0.0, 400.0);
    if (next == _dismissDragDy) {
      return;
    }
    setState(() => _dismissDragDy = next);
  }

  void _handleDismissPointerUp(PointerUpEvent event) {
    final Offset? origin = _dismissPointerOrigin;
    final Duration? startedAt = _dismissPointerAt;
    _dismissPointerOrigin = null;
    _dismissPointerAt = null;
    final double dragged = _dismissDragDy;
    double speed = 0;
    if (origin != null && startedAt != null) {
      final int elapsedMs = (event.timeStamp - startedAt).inMilliseconds;
      if (elapsedMs > 0) {
        speed = (event.position.dy - origin.dy) / (elapsedMs / 1000);
      }
    }
    if (_currentPage == 1 && (dragged > 140 || speed > 700)) {
      _closePlayerPage();
      return;
    }
    if (dragged != 0) {
      setState(() => _dismissDragDy = 0);
    }
  }

  void _handleDismissPointerCancel(PointerCancelEvent event) {
    _dismissPointerOrigin = null;
    _dismissPointerAt = null;
    if (_dismissDragDy != 0) {
      setState(() => _dismissDragDy = 0);
    }
  }

  void _closePlayerPage() {
    if (_dismissDragDy != 0) {
      setState(() => _dismissDragDy = 0);
    }
    if (widget.embedded) {
      widget.onExit?.call();
      return;
    }
    Navigator.of(context).maybePop();
  }

  /// 横滑三页：播放信息 / 播放控制 / 歌词。
  ///
  /// 唯一的数据来源是 [state]，页面本身不持有播放状态，因此可以被分页容器
  /// 随时重建（拖到一半时两侧页面会一起挂载）。
  Widget _buildPage({
    required BuildContext pageContext,
    required int page,
    required PlayerState state,
    required PlayerDisplayInfo display,
    required PlayableItem? item,
    required bool isFavorite,
    required Color? coverColor,
  }) {
    switch (page) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PlayerMetaPage(state: state, item: item),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: PlayerLyricPage(
            state: state,
            item: item,
            isActive: _currentPage == 2,
            onSeek: ref.read(playerControllerProvider.notifier).seek,
            activeColor: coverColor,
          ),
        );
      default:
        final List<PlayableItem> availableParts = state.availableParts;
        final List<PlaybackChapter> chapters = state.chapters;
        final bool canOpenJumpPanel =
            item != null && (availableParts.length > 1 || chapters.length > 1);
        final PlayerController playerController = ref.read(
          playerControllerProvider.notifier,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PlayerMainPage(
            state: state,
            item: item,
            display: display,
            commentCount: item?.replyCount,
            canOpenJumpPanel: canOpenJumpPanel,
            onPartTap: !canOpenJumpPanel
                ? null
                : () => _openJumpPanel(
                    pageContext,
                    state,
                    item,
                    availableParts,
                    playerController,
                  ),
            onOpenCollectionSheet: item == null
                ? null
                : () => showPlayerCollectionSheet(
                    context: pageContext,
                    item: item,
                    glass: GlassTone.smoke,
                  ),
            isFavorite: isFavorite,
            onFavoriteToggle: item == null ? null : () => _toggleFavorite(item),
            onToggleSource: _toggleDisplaySource,
            onSeek: _seekFromProgressBar,
            onToggleQueueMode: playerController.toggleQueueMode,
            onBackward: playerController.skipToPrevious,
            onTogglePlayback: playerController.togglePlayback,
            onForward: playerController.skipToNext,
            onOpenQueue: () => showPlayerQueueSheet(
              context: pageContext,
              state: state,
              glass: true,
              style: PlayerQueueSheetStyle.player,
            ),
            onOpenComments: item == null ? null : () => _openComments(item),
          ),
        );
    }
  }

  Widget _buildTopBar(BuildContext context, PlayableItem? item) {
    final Widget bar = PlayerTopBar(
      currentPage: _currentPage,
      onBack: widget.embedded
          ? widget.onExit
          : () => Navigator.of(context).maybePop(),
      onOpenMenu: item == null ? null : () => _showPlayerMenu(item),
    );
    if (widget.embedded) {
      return bar;
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        _topBarDragOrigin = event.position;
      },
      onPointerCancel: (PointerCancelEvent event) {
        _topBarDragOrigin = null;
      },
      onPointerUp: (PointerUpEvent event) {
        final Offset? origin = _topBarDragOrigin;
        _topBarDragOrigin = null;
        if (origin == null) {
          return;
        }
        if (PlayerGestureMath.pageShouldDismiss(event.position - origin)) {
          _closePlayerPage();
        }
      },
      child: bar,
    );
  }

  void _toggleDisplaySource() {
    HapticFeedback.lightImpact();
    ref.read(playerDisplaySourceLogicProvider.notifier).toggle();
  }

  Future<void> _openJumpPanel(
    BuildContext context,
    PlayerState state,
    PlayableItem item,
    List<PlayableItem> availableParts,
    PlayerController controller,
  ) async {
    if (availableParts.length > 1) {
      await showPlayerPartSelector(
        context: context,
        parts: availableParts,
        currentItem: item,
        state: state,
        controller: controller,
      );
      return;
    }
    final PlayerState liveState = ref.read(playerControllerProvider);
    if (liveState.chapters.length < 2) {
      return;
    }
    await showPlayerChapterSelector(
      context: context,
      chapters: liveState.chapters,
      position: liveState.position,
      isPlaying: liveState.isPlaying,
      onSeek: controller.seek,
    );
  }

  void _seekFromProgressBar(double value) {
    final Duration duration =
        ref.read(playerControllerProvider).duration ?? Duration.zero;
    ref
        .read(playerControllerProvider.notifier)
        .seekFromProgressBar(
          Duration(milliseconds: (duration.inMilliseconds * value).round()),
        );
  }

  Future<void> _toggleFavorite(PlayableItem item) async {
    final bool isLiked = await ref
        .read(favoritesControllerProvider.notifier)
        .toggleLiked(item);
    if (!mounted) {
      return;
    }
    ToastUtil.show(isLiked ? '已加入“我喜欢”' : '已从“我喜欢”移除');
  }

  Future<void> _openComments(PlayableItem item) async {
    if (item.aid <= 0) {
      return;
    }

    final CommentTarget target = CommentTarget.video(
      aid: item.aid,
      bvid: item.bvid,
      title: item.title,
      coverUrl: item.coverUrl,
    );
    // 适用navigator进入 不用gorouter 使评论区压在播放器上
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CommentPage(target: target)),
    );
  }

  Future<void> _showPlayerMenu(PlayableItem item) async {
    // 播放页菜单固定用烟熏玻璃，不跟随「玻璃导航栏 / 播放栏」开关。
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext sheetContext) {
        return AppGlassSheet(
          tone: GlassTone.smoke,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _playerMenuItems(item, sheetContext),
            ),
          ),
        );
      },
    );
  }

  Widget _playerMenuItems(PlayableItem item, BuildContext sheetContext) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isAutoFeedQueue(
          ref.read(playerControllerProvider).queueSourceLabel,
        ))
          ListTile(
            key: const Key('radarRefreshMenuEntry'),
            leading: const Icon(Icons.radar_rounded),
            title: const Text('换一批推荐'),
            subtitle: const Text('按最近的收听重新算一批'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              ref.read(radarRefreshRequestsProvider.notifier).request();
            },
          ),
        ListTile(
          key: const Key('playSettingsMenuEntry'),
          leading: const Icon(Icons.tune_rounded),
          title: const Text('播放设置'),
          subtitle: const Text('睡眠定时 · 倍速播放 · 外部打开'),
          onTap: () {
            Navigator.of(sheetContext).pop();
            showPlayerSettingsSheet(
              context: context,
              onOpenExternal: () => _openInBrowser(item),
            );
          },
        ),
      ],
    );
  }
}

PlayerState _withoutPlaybackPosition(PlayerState state) {
  if (state.position == Duration.zero) {
    return state;
  }
  return state.copyWith(position: Duration.zero);
}

/// 播放页统一深色底：与刷歌页共用同一套「深色 + 白字」视觉。
const Color _playerBackground = Color(0xFF15100E);

ThemeData _playerTheme(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  if (theme.brightness == Brightness.dark) {
    return theme;
  }
  final ColorScheme scheme = theme.colorScheme;
  return theme.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: scheme.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: _playerBackground,
    canvasColor: _playerBackground,
  );
}

Future<void> _openInBrowser(PlayableItem item) async {
  if (item.aid <= 0) {
    return;
  }
  try {
    await launchUrl(Uri.parse('bilibili://video/${item.bvid}'));
  } catch (e) {
    await launchUrl(Uri.parse('https://www.bilibili.com/video/${item.bvid}'));
  }
}
