import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_subtitle_document.dart';
import 'package:flutter_test/flutter_test.dart';

BiliSubtitleLine _line(int index, String text) {
  return BiliSubtitleLine(
    startMs: index * 1000,
    endMs: index * 1000 + 900,
    text: text,
  );
}

void main() {
  group('stripSubtitleDecorations', () {
    test('removes wrapping note glyphs and keeps the lyric text', () {
      expect(stripSubtitleDecorations('♪ 燃火光裂穹苍 ♪'), '燃火光裂穹苍');
      expect(stripSubtitleDecorations('♪ 孤鸿直远 ♪'), '孤鸿直远');
      expect(stripSubtitleDecorations('♫♫ 山长 ♫'), '山长');
    });

    test('keeps a note glyph that sits inside the lyric', () {
      expect(stripSubtitleDecorations('♪ 唱到 ♪这里♪ 才算完'), '唱到 ♪这里♪ 才算完');
    });

    test('leaves plain lines untouched and trims padding', () {
      expect(stripSubtitleDecorations('  这是一句歌词 '), '这是一句歌词');
      expect(stripSubtitleDecorations(''), '');
    });
  });

  group('buildSubtitleDocument', () {
    test('drops note decorations while keeping the timings', () {
      final document = buildSubtitleDocument(<BiliSubtitleLine>[
        _line(0, '♪ 看旌旗筑成浪真意 ♪'),
        _line(1, '♪ 难掩藏 ♪'),
      ]);

      expect(document.lines.map((line) => line.text).toList(), <String>[
        '看旌旗筑成浪真意',
        '难掩藏',
      ]);
      expect(document.lines.first.start, const Duration(milliseconds: 0));
      expect(document.lines.first.end, const Duration(milliseconds: 900));
    });

    test('skips lines that are decoration only', () {
      final document = buildSubtitleDocument(<BiliSubtitleLine>[
        _line(0, '♪♪♪'),
        _line(1, '真正的歌词'),
        _line(2, ' ♪ ♪ '),
      ]);

      expect(document.lines, hasLength(1));
      expect(document.lines.single.text, '真正的歌词');
    });

    test('falls back to raw text when every line is decoration only', () {
      final document = buildSubtitleDocument(<BiliSubtitleLine>[
        _line(0, '♪♪♪'),
        _line(1, '♫'),
      ]);

      expect(document.lines, hasLength(2));
      expect(document.lines.first.text, '♪♪♪');
    });

    test('keeps per-line ends so the highlight can pace each character', () {
      final document = buildSubtitleDocument(<BiliSubtitleLine>[
        BiliSubtitleLine(startMs: 1000, endMs: 4200, text: '♪ 一句完整的歌词 ♪'),
      ]);

      final line = document.lines.single;
      expect(line.start, const Duration(milliseconds: 1000));
      expect(line.end, const Duration(milliseconds: 4200));
      expect(line.text, '一句完整的歌词');
    });
  });

  group('buildSubtitleWordTimings', () {
    test('splits the line into one word per character', () {
      final words = buildSubtitleWordTimings(
        text: '看旌旗',
        startMs: 1000,
        endMs: 4000,
      );

      expect(words, hasLength(3));
      expect(words.map((word) => word.text).join(), '看旌旗');
      expect(words.first.start, const Duration(milliseconds: 1000));
      expect(words.last.end, const Duration(milliseconds: 4000));
    });

    test('keeps timings monotonic and inside the line window', () {
      final words = buildSubtitleWordTimings(
        text: '一骑战八方 tonight',
        startMs: 500,
        endMs: 6500,
      );

      Duration? previousEnd;
      for (final word in words) {
        expect(
          word.start,
          greaterThanOrEqualTo(const Duration(milliseconds: 500)),
        );
        expect(word.end, isNotNull);
        expect(
          word.end!,
          lessThanOrEqualTo(const Duration(milliseconds: 6500)),
        );
        expect(word.end! >= word.start, isTrue);
        if (previousEnd != null) {
          expect(word.start, greaterThanOrEqualTo(previousEnd));
        }
        previousEnd = word.end;
      }
      expect(previousEnd, const Duration(milliseconds: 6500));
    });

    test('gives wide glyphs more time than narrow latin ones', () {
      final words = buildSubtitleWordTimings(
        text: '歌a',
        startMs: 0,
        endMs: 1000,
      );

      final Duration cjk = words[0].end! - words[0].start;
      final Duration latin = words[1].end! - words[1].start;
      expect(cjk, greaterThan(latin));
    });

    test('returns nothing for empty text or collapsed durations', () {
      expect(
        buildSubtitleWordTimings(text: '', startMs: 0, endMs: 1000),
        isEmpty,
      );
      expect(
        buildSubtitleWordTimings(text: '歌词', startMs: 2000, endMs: 2000),
        isEmpty,
      );
    });
  });
}
