import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/material.dart';

String buildMiniPlayerSubtitle(PlayerState state, {String? displayArtist}) {
  return switch (state.statusHint) {
    PlayerStatusHint.resolvingAudio => '正在解析音频...',
    PlayerStatusHint.connectingStream => '正在连接播放流...',
    PlayerStatusHint.loadingCache => '正在加载缓存音频...',
    PlayerStatusHint.buffering => '缓冲中...',
    PlayerStatusHint.error => state.errorMessage ?? '播放失败，请稍后重试',
    null => displayArtist ?? '',
  };
}

class MiniPlayerArtwork extends StatelessWidget {
  const MiniPlayerArtwork({super.key, required this.coverUrl});

  static const double _outerSize = 36;
  static const double _imageSize = 32;

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _outerSize,
      height: _outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: _imageSize,
            height: _imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surfaceContainerHigh,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CommonCachedImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.music_note_rounded,
                iconColor: colorScheme.onSurfaceVariant,
                backgroundColor: colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
