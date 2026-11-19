import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:flutter_lyric/flutter_lyric.dart';

/// 字幕正文里会混入的装饰性音符：B 站 AI 字幕常用 `♪ 歌词 ♪` 包裹整行。
const Set<String> _noteGlyphs = <String>{
  '♪',
  '♫',
  '♬',
  '♩',
  '♭',
  '♮',
  '♯',
  '🎵',
  '🎶',
};

/// 去掉行首行尾的装饰音符与多余空白；行内音符保留（可能是歌词内容）。
String stripSubtitleDecorations(String raw) {
  String text = raw.trim();
  bool changed = true;
  while (changed) {
    changed = false;
    for (final String glyph in _noteGlyphs) {
      if (text.startsWith(glyph)) {
        text = text.substring(glyph.length).trimLeft();
        changed = true;
      }
      if (text.endsWith(glyph)) {
        text = text.substring(0, text.length - glyph.length).trimRight();
        changed = true;
      }
    }
  }
  return text.trim();
}

/// 单字显示的相对宽度，用于把整行时长按可见宽度分配，避免中英混排时扫过速度忽快忽慢。
double _glyphWeight(int rune) {
  if (rune == 0x20) {
    return 0.35;
  }
  if (rune < 0x2E80) {
    return 0.55;
  }
  return 1;
}

/// 为整行合成逐字时间戳。
///
/// 字幕只有整行时间，没有逐字时间；不补这份数据时高亮引擎拿不到分段，
/// 只能整句一次性填色。按字符宽度均分整行时长后，高亮会跟随播放进度逐字扫过。
List<LyricWord> buildSubtitleWordTimings({
  required String text,
  required int startMs,
  required int endMs,
}) {
  final int totalMs = endMs - startMs;
  if (text.isEmpty || totalMs <= 0) {
    return const <LyricWord>[];
  }

  final List<String> glyphs = <String>[
    for (final int rune in text.runes) String.fromCharCode(rune),
  ];
  final List<double> weights = <double>[
    for (final String glyph in glyphs) _glyphWeight(glyph.runes.first),
  ];
  final double totalWeight = weights.fold<double>(
    0,
    (double sum, double weight) => sum + weight,
  );
  if (totalWeight <= 0) {
    return const <LyricWord>[];
  }

  final List<LyricWord> words = <LyricWord>[];
  int cursorMs = startMs;
  int consumedMs = 0;
  for (int index = 0; index < glyphs.length; index += 1) {
    consumedMs += (totalMs * weights[index] / totalWeight).round();
    final int wordEnd = index == glyphs.length - 1
        ? endMs
        : (startMs + consumedMs).clamp(startMs, endMs);
    words.add(
      LyricWord(
        text: glyphs[index],
        start: Duration(milliseconds: cursorMs),
        end: Duration(milliseconds: wordEnd),
      ),
    );
    cursorMs = wordEnd;
  }
  return words;
}

LyricDocument buildSubtitleDocument(List<BiliSubtitleLine> subtitles) {
  final List<LyricLine> lines = <LyricLine>[];
  for (final BiliSubtitleLine subtitle in subtitles) {
    final String text = stripSubtitleDecorations(subtitle.text);
    if (text.isEmpty) {
      continue;
    }
    lines.add(
      LyricLine(
        start: Duration(milliseconds: subtitle.startMs),
        end: Duration(milliseconds: subtitle.endMs),
        text: text,
        words: buildSubtitleWordTimings(
          text: text,
          startMs: subtitle.startMs,
          endMs: subtitle.endMs,
        ),
      ),
    );
  }
  if (lines.isEmpty) {
    return LyricDocument(lines: _rawLines(subtitles));
  }
  return LyricDocument(lines: lines);
}

List<LyricLine> _rawLines(List<BiliSubtitleLine> subtitles) {
  return <LyricLine>[
    for (final BiliSubtitleLine subtitle in subtitles)
      LyricLine(
        start: Duration(milliseconds: subtitle.startMs),
        end: Duration(milliseconds: subtitle.endMs),
        text: subtitle.text.trim(),
        words: buildSubtitleWordTimings(
          text: subtitle.text.trim(),
          startMs: subtitle.startMs,
          endMs: subtitle.endMs,
        ),
      ),
  ];
}
