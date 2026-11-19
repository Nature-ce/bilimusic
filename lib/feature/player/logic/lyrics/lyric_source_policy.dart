bool allowsMetingLyrics({
  required bool singlePart,
  required bool hasSubtitleTracks,
  required bool manualMatch,
}) {
  if (!singlePart) {
    return true;
  }
  return hasSubtitleTracks || manualMatch;
}

/// 决定歌词面板该渲染「正规歌词」还是「B 站字幕」。
///
/// 参考 QQ音乐：正规歌词（LRC）优先，字幕只在没有歌词、口播类内容，
/// 或用户主动挑选字幕轨时启用。这样 Meting 命中正确歌词时不会被 AI 字幕顶掉。
bool shouldRenderSubtitleLyrics({
  required bool itemIsSpoken,
  required bool hasMetingLyrics,
  required bool subtitlesSelected,
  required bool userSelected,
}) {
  if (!subtitlesSelected) {
    return false;
  }
  if (itemIsSpoken) {
    return true;
  }
  if (userSelected) {
    return true;
  }
  return !hasMetingLyrics;
}

const List<String> _instrumentalMarkers = <String>[
  '纯音乐',
  '纯音',
  '轻音乐',
  '白噪音',
  '无人声',
];

bool looksLikeInstrumental({String? title, String? description}) {
  final String text = '${title ?? ''} ${description ?? ''}';
  if (text.trim().isEmpty) {
    return false;
  }
  for (final String marker in _instrumentalMarkers) {
    if (text.contains(marker)) {
      return true;
    }
  }
  return false;
}
