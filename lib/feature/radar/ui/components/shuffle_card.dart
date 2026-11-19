import 'dart:ui' as ui;

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/home/domain/hot_playlist_track.dart';
import 'package:flutter/material.dart';

/// 刷歌单曲卡：整屏沉浸，模糊封面背景 + 大封面 + 歌曲信息 + 进度与播放控制。
///
/// 规格参考 QQ音乐刷歌页：黑底页面文字全白，信息靠字重与透明度分层。
class ShuffleCard extends StatelessWidget {
  const ShuffleCard({
    super.key,
    required this.track,
    required this.index,
    required this.total,
    required this.isActive,
    required this.isPlaying,
    required this.isResolving,
    required this.progress,
    required this.positionText,
    required this.durationText,
    required this.bottomInset,
    required this.onTogglePlayback,
    required this.onOpenPlayer,
    required this.onShuffle,
    this.errorMessage,
    this.onRetry,
  });

  final HotPlaylistTrack track;
  final int index;
  final int total;
  final bool isActive;
  final bool isPlaying;
  final bool isResolving;
  final double progress;
  final String positionText;
  final String durationText;
  final double bottomInset;
  final VoidCallback onTogglePlayback;
  final VoidCallback onOpenPlayer;
  final VoidCallback onShuffle;
  final String? errorMessage;
  final VoidCallback? onRetry;

  static const Color _onDark = Colors.white;
  static const Color _onDarkMuted = Color(0xB3FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _ShuffleBackdrop(coverUrl: track.coverUrl),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTopBar(context),
                const SizedBox(height: AppSpacing.md),
                Expanded(flex: 58, child: _buildCover(context)),
                Expanded(flex: 42, child: _buildInfo(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.waves_rounded,
          size: 20,
          color: _onDark.withValues(alpha: 0.85),
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Text(
          '刷歌',
          style: TextStyle(
            fontSize: 15,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: _onDark.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${index + 1} / $total',
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            color: _onDarkMuted,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: '换一批',
          onPressed: onShuffle,
          color: _onDark.withValues(alpha: 0.85),
          iconSize: 22,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildCover(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: onOpenPlayer,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CommonCachedImage(
                imageUrl: track.coverUrl,
                fit: BoxFit.cover,
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                fallbackIcon: Icons.music_note_rounded,
                iconColor: _onDarkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final String platform = track.playlist.platform.label;
    final String artist = track.artist.isEmpty ? platform : track.artist;
    final String sourceLine = track.playlist.name.isEmpty
        ? '来自 $platform'
        : '来自 $platform · ${track.playlist.name}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Spacer(),
        Text(
          sourceLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            color: _onDark.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: _onDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  color: _onDark.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ShuffleTag(label: platform),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (errorMessage != null)
          _buildErrorRow(context)
        else
          _ShuffleProgress(
            progress: isActive ? progress : 0,
            positionText: isActive ? positionText : '--:--',
            durationText: track.durationText.isEmpty
                ? durationText
                : track.durationText,
          ),
        const SizedBox(height: AppSpacing.md),
        _buildControls(context),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            '试试上下滑，发现更多好歌',
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: _onDark.withValues(alpha: 0.42),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorRow(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: Colors.orange.shade200,
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Expanded(
          child: Text(
            errorMessage ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Colors.orange.shade200,
            ),
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: _onDark,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('重试'),
          ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          tooltip: '打开播放器',
          onPressed: onOpenPlayer,
          color: _onDark.withValues(alpha: 0.9),
          iconSize: 26,
          icon: const Icon(Icons.play_circle_outline_rounded),
        ),
        IconButton(
          tooltip: isActive && isPlaying ? '暂停' : '播放',
          onPressed: onTogglePlayback,
          color: _onDark,
          iconSize: 48,
          padding: EdgeInsets.zero,
          icon: isResolving
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  isActive && isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
        ),
        IconButton(
          tooltip: '在播放器中打开',
          onPressed: onOpenPlayer,
          color: _onDark.withValues(alpha: 0.9),
          iconSize: 26,
          icon: const Icon(Icons.queue_music_rounded),
        ),
      ],
    );
  }
}

class _ShuffleTag extends StatelessWidget {
  const _ShuffleTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          height: 1.3,
          color: Color(0xCCFFFFFF),
        ),
      ),
    );
  }
}

class _ShuffleProgress extends StatelessWidget {
  const _ShuffleProgress({
    required this.progress,
    required this.positionText,
    required this.durationText,
  });

  final double progress;
  final String positionText;
  final String durationText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Row(
          children: <Widget>[
            Text(
              positionText,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                color: Color(0x99FFFFFF),
              ),
            ),
            const Spacer(),
            Text(
              durationText,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                color: Color(0x99FFFFFF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 背景：封面放大 + 高斯模糊 + 自上而下加深的蒙层。
class _ShuffleBackdrop extends StatelessWidget {
  const _ShuffleBackdrop({required this.coverUrl});

  final String coverUrl;

  static const double _blurSigma = 36;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(color: Color(0xFF15100E)),
        if (coverUrl.isNotEmpty)
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: _blurSigma,
              sigmaY: _blurSigma,
              tileMode: TileMode.decal,
            ),
            child: CommonCachedImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              backgroundColor: Colors.transparent,
              fallbackIcon: Icons.music_note_rounded,
              iconColor: const Color(0x33FFFFFF),
            ),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x66000000),
                Color(0x99000000),
                Color(0xF2000000),
              ],
              stops: <double>[0, 0.55, 1],
            ),
          ),
        ),
      ],
    );
  }
}
