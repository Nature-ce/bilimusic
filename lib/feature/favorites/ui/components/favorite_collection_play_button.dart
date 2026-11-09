import 'package:bilimusic/common/components/sequence_play_icon.dart';
import 'package:flutter/material.dart';

/// 歌单的播放方式：顺序（播完即止）、随机、循环。
enum FavoriteCollectionPlayMode { sequence, shuffle, loop }

/// 歌单页统一的播放按钮：点击后弹出「顺序 / 随机 / 循环」选择。
class FavoriteCollectionPlayButton extends StatelessWidget {
  const FavoriteCollectionPlayButton({
    super.key,
    required this.onModeSelected,
    this.enabled = true,
  });

  final ValueChanged<FavoriteCollectionPlayMode> onModeSelected;
  final bool enabled;

  static const double _size = 36;

  Future<void> _showModeMenu(BuildContext context) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ThemeData theme = Theme.of(context);
    final FavoriteCollectionPlayMode? mode =
        await showModalBottomSheet<FavoriteCollectionPlayMode>(
          context: context,
          showDragHandle: true,
          builder: (BuildContext sheetContext) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '播放方式',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: SequencePlayIcon(
                      size: 24,
                      color: colorScheme.primary,
                    ),
                    title: const Text('顺序播放'),
                    subtitle: const Text('按歌单顺序播放，播完即止'),
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(FavoriteCollectionPlayMode.sequence),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.shuffle_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text('随机播放'),
                    subtitle: const Text('打乱歌单顺序播放'),
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(FavoriteCollectionPlayMode.shuffle),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.repeat_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text('循环播放'),
                    subtitle: const Text('按歌单顺序循环播放'),
                    onTap: () => Navigator.of(
                      sheetContext,
                    ).pop(FavoriteCollectionPlayMode.loop),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
    if (mode != null) {
      onModeSelected(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: _size,
      height: _size,
      child: IconButton(
        onPressed: enabled ? () => _showModeMenu(context) : null,
        tooltip: '播放',
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: _size, height: _size),
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(_size, _size),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.playlist_play_rounded),
      ),
    );
  }
}
