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

/// 歌词面板实际展示的来源：Meting 歌词、B 站字幕，或者都没有。
enum LyricSource { meting, subtitle, none }

/// 统一判定当前该用哪种歌词。
///
/// 面板渲染、字幕弹窗的勾选状态、工具栏按钮都走这一个函数，
/// 避免出现「面板显示 Meting、弹窗勾着 AI 字幕」这种不一致。
LyricSource resolveLyricSource({
  required bool itemIsSpoken,
  required bool hasMetingLyrics,
  required bool subtitlesSelected,
  required bool userSelected,
}) {
  final bool useSubtitles = shouldRenderSubtitleLyrics(
    itemIsSpoken: itemIsSpoken,
    hasMetingLyrics: hasMetingLyrics,
    subtitlesSelected: subtitlesSelected,
    userSelected: userSelected,
  );
  if (useSubtitles) {
    return LyricSource.subtitle;
  }
  if (hasMetingLyrics) {
    return LyricSource.meting;
  }
  return LyricSource.none;
}
