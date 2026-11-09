import 'package:flutter/material.dart';

/// 歌单页的一组紧凑播放操作：播放全部 + 随机播放，常放在搜索框右侧。
class FavoriteCollectionPlayActions extends StatelessWidget {
  const FavoriteCollectionPlayActions({
    super.key,
    required this.onPlayAll,
    required this.onShuffle,
    this.enabled = true,
  });

  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;
  final bool enabled;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton.filledTonal(
          onPressed: enabled ? onPlayAll : null,
          tooltip: '播放全部',
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: _size,
            height: _size,
          ),
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size(_size, _size),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.play_arrow_rounded),
        ),
        const SizedBox(width: 2),
        IconButton(
          onPressed: enabled ? onShuffle : null,
          tooltip: '随机播放',
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: _size,
            height: _size,
          ),
          style: IconButton.styleFrom(
            minimumSize: const Size(_size, _size),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.shuffle_rounded),
        ),
      ],
    );
  }
}
