import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/badged_icon_button.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/download/ui/track_download_action.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_online_audience_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_quality_badge.dart';
import 'package:bilimusic/feature/player/ui/components/player_quality_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerMainPage extends ConsumerWidget {
  const PlayerMainPage({
    super.key,
    required this.state,
    required this.item,
    required this.display,
    required this.commentCount,
    required this.canOpenJumpPanel,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onToggleSource,
    required this.onSeek,
    required this.onToggleQueueMode,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
    required this.onOpenQueue,
    required this.onOpenComments,
  });

  final PlayerState state;
  final PlayableItem? item;
  final PlayerDisplayInfo display;
  final int? commentCount;
  final bool canOpenJumpPanel;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onToggleSource;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final bool isCompact = screenSize.height < 600;
    final double artworkSize = playerArtworkSize(screenSize);
    final AsyncValue<PlayerOnlineAudience?> onlineAudienceAsync = ref.watch(
      playerOnlineAudienceControllerProvider,
    );
    final PlayerOnlineAudience? onlineAudience = switch (onlineAudienceAsync) {
      AsyncData<PlayerOnlineAudience?>(:final value) => value,
      _ => null,
    };
    final String? onlineAudienceLabel = onlineAudience == null
        ? null
        : _buildAudienceLabel(onlineAudience);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _RepaintSection(
                    child: _PlayerHeroAndTitle(
                      artworkSize: artworkSize,
                      isCompact: isCompact,
                      item: item,
                      display: display,
                      isFavorite: isFavorite,
                      onlineAudienceLabel: onlineAudienceLabel,
                      onFavoriteToggle: onFavoriteToggle,
                      onToggleSource: onToggleSource,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _RepaintSection(
                        child: _PlayerStatusAndTools(
                          state: state,
                          item: item,
                          commentCount: commentCount,
                          canOpenJumpPanel: canOpenJumpPanel,
                          onPartTap: onPartTap,
                          onOpenCollectionSheet: onOpenCollectionSheet,
                          onOpenComments: onOpenComments,
                        ),
                      ),
                      SizedBox(height: isCompact ? 6 : 10),
                      _RepaintSection(
                        child: PlayerProgressHost(
                          state: state,
                          onChanged: onSeek,
                        ),
                      ),
                      SizedBox(height: isCompact ? 6 : 10),
                      _RepaintSection(
                        child: PlayerTransportControls(
                          state: state,
                          onToggleQueueMode: onToggleQueueMode,
                          onBackward: onBackward,
                          onTogglePlayback: onTogglePlayback,
                          onForward: onForward,
                          onOpenQueue: onOpenQueue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: isCompact || mediaQuery.padding.bottom > 0
                        ? 40
                        : 50,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RepaintSection extends StatelessWidget {
  const _RepaintSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

class _PlayerHeroAndTitle extends StatelessWidget {
  const _PlayerHeroAndTitle({
    required this.artworkSize,
    required this.isCompact,
    required this.item,
    required this.display,
    required this.isFavorite,
    required this.onlineAudienceLabel,
    required this.onFavoriteToggle,
    required this.onToggleSource,
  });

  final double artworkSize;
  final bool isCompact;
  final PlayableItem? item;
  final PlayerDisplayInfo display;
  final bool isFavorite;
  final String? onlineAudienceLabel;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onToggleSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: isCompact ? 8 : 12),
        Center(
          child: SizedBox(
            width: artworkSize,
            height: artworkSize,
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onDoubleTap: display.canToggleSource ? onToggleSource : null,
                  child: Hero(
                    tag: 'artwork',
                    child: PlayerArtworkFrame(coverUrl: display.coverUrl ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isCompact ? 16 : 28),
        PlayerTrackHeader(
          title: display.title ?? '还没有选择播放内容',
          subtitle: display.stableId == null
              ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
              : display.artist ?? '',
          isFavoriteEnabled: item != null,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
          onSubtitleTap: _buildUpTapHandler(context, display.artistUpMid),
        ),
        if (onlineAudienceLabel != null) ...<Widget>[
          const SizedBox(height: 12),
          Row(children: <Widget>[PlayerBadge(label: onlineAudienceLabel!)]),
        ],
      ],
    );
  }

  VoidCallback? _buildUpTapHandler(BuildContext context, int? ownerMid) {
    if (ownerMid == null || ownerMid <= 0) {
      return null;
    }
    return () {
      final GoRouter router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.push('/up/$ownerMid');
    };
  }
}

class _PlayerStatusAndTools extends StatelessWidget {
  const _PlayerStatusAndTools({
    required this.state,
    required this.item,
    required this.commentCount,
    required this.canOpenJumpPanel,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final PlayerState state;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenJumpPanel;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlayerPlaybackStatusChip(state: state),
        if (state.statusHint != null) const SizedBox(height: 12),
        _PlayerToolBar(
          state: state,
          hasItem: item != null,
          item: item,
          commentCount: commentCount,
          canOpenJumpPanel: canOpenJumpPanel,
          onPartTap: onPartTap,
          onOpenCollectionSheet: onOpenCollectionSheet,
          onOpenComments: onOpenComments,
        ),
      ],
    );
  }
}

String? _buildAudienceLabel(PlayerOnlineAudience audience) {
  final String? preferredText = switch ((
    audience.showTotal,
    audience.showCount,
  )) {
    (true, _) when audience.totalText?.isNotEmpty ?? false =>
      audience.totalText,
    (_, true) when audience.countText?.isNotEmpty ?? false =>
      audience.countText,
    _ when audience.totalText?.isNotEmpty ?? false => audience.totalText,
    _ when audience.countText?.isNotEmpty ?? false => audience.countText,
    _ => null,
  };

  if (preferredText == null) {
    return null;
  }
  if (preferredText.contains('人')) {
    return preferredText;
  }
  return '$preferredText人在听';
}

class _PlayerToolBar extends StatelessWidget {
  const _PlayerToolBar({
    required this.state,
    required this.hasItem,
    required this.item,
    required this.commentCount,
    required this.canOpenJumpPanel,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final PlayerState state;
  final bool hasItem;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenJumpPanel;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    final List<AudioQualityOption> availableQualities =
        state.audioStream?.availableQualities ?? const <AudioQualityOption>[];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _PlayerPartToolButton(
          item: item,
          isEnabled: canOpenJumpPanel,
          onTap: onPartTap,
        ),
        _PlayerToolButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedFolderAdd),
          isEnabled: hasItem,
          onTap: onOpenCollectionSheet,
        ),
        _PlayerDownloadToolButton(item: item, isEnabled: hasItem),
        _PlayerQualityToolButton(
          qualities: availableQualities,
          isEnabled: hasItem && availableQualities.isNotEmpty,
        ),
        _PlayerCommentToolButton(
          commentCount: commentCount,
          isEnabled: hasItem,
          onTap: onOpenComments,
        ),
      ],
    );
  }
}

class _PlayerCommentToolButton extends StatelessWidget {
  const _PlayerCommentToolButton({
    required this.commentCount,
    required this.isEnabled,
    this.onTap,
  });

  final int? commentCount;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? badgeLabel = formatCommentBadgeCount(commentCount);

    return BadgedIconButton(
      noBadgeIcon: HugeIcon(icon: HugeIcons.strokeRoundedComment01),
      badgeIcon: const Icon(BmIcons.commentWithBadge, size: 26),
      badge: badgeLabel,
      onPressed: isEnabled ? onTap : null,
    );
  }
}

class _PlayerQualityToolButton extends ConsumerWidget {
  const _PlayerQualityToolButton({
    required this.qualities,
    required this.isEnabled,
  });

  final List<AudioQualityOption> qualities;
  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String badgeLabel = qualityBadgeLabel(qualities: qualities);
    return IconButton(
      onPressed: !isEnabled ? null : () => _pickQuality(context, ref),
      icon: PlayerQualityBadge(
        label: badgeLabel,
        color: neutralColorOf(context),
      ),
    );
  }

  Future<void> _pickQuality(BuildContext context, WidgetRef ref) async {
    final int? qualityId = await showPlayerQualitySheet(
      context: context,
      qualities: qualities,
    );
    if (qualityId == null) {
      return;
    }
    await ref
        .read(playerControllerProvider.notifier)
        .switchCurrentAudioQuality(qualityId);
  }
}

class _PlayerPartToolButton extends ConsumerWidget {
  const _PlayerPartToolButton({
    required this.item,
    required this.isEnabled,
    this.onTap,
  });

  final PlayableItem? item;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? badge = ref.watch(
      playerControllerProvider.select(
        (PlayerState state) => formatJumpBadge(
          item: state.currentItem ?? item,
          chapters: state.chapters,
          position: state.position,
        ),
      ),
    );

    return BadgedIconButton(
      noBadgeIcon: const HugeIcon(icon: HugeIcons.strokeRoundedListVideo),
      badgeIcon: const Icon(BmIcons.partListWithBadge, size: 26),
      badge: badge,
      onPressed: isEnabled ? onTap : null,
    );
  }
}

class _PlayerDownloadToolButton extends ConsumerWidget {
  const _PlayerDownloadToolButton({
    required this.item,
    required this.isEnabled,
  });

  final PlayableItem? item;
  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayableItem? currentItem = item;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DownloadState downloadState = ref.watch(downloadControllerProvider);
    final bool isDownloaded =
        currentItem != null && downloadState.contains(currentItem.contentId);
    final bool isDownloading =
        currentItem != null &&
        (downloadState.taskFor(currentItem.contentId)?.isActive ?? false);
    final String tooltip = isDownloaded
        ? '已下载'
        : isDownloading
        ? '下载中'
        : '下载';
    final Color iconColor = !isEnabled
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : isDownloaded
        ? colorScheme.primary
        : isDownloading
        ? colorScheme.primary.withValues(alpha: 0.6)
        : colorScheme.onSurface;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: const Key('playerDownloadButton'),
        onPressed: isEnabled && currentItem != null
            ? () => requestTrackDownload(ref, currentItem)
            : null,
        icon: Icon(Icons.download_rounded, color: iconColor),
      ),
    );
  }
}

class _PlayerToolButton extends StatelessWidget {
  const _PlayerToolButton({
    required this.icon,
    required this.isEnabled,
    this.onTap,
  });

  final Widget icon;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    return SizedBox(
      width: 40,
      height: 40,
      child: InkResponse(
        onTap: isEnabled ? onTap : null,
        radius: 24,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: IconTheme.merge(
              data: IconThemeData(size: 24, color: foregroundColor),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
