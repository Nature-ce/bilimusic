import 'package:bilimusic/feature/player/logic/lyrics/lyric_source_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldRenderSubtitleLyrics', () {
    test('never renders subtitles when no track is selected', () {
      expect(
        shouldRenderSubtitleLyrics(
          hasMetingLyrics: false,
          subtitlesSelected: false,
          userSelected: false,
        ),
        isFalse,
      );
    });

    test('prefers Meting lyrics when the regular lyric is available', () {
      expect(
        shouldRenderSubtitleLyrics(
          hasMetingLyrics: true,
          subtitlesSelected: true,
          userSelected: false,
        ),
        isFalse,
      );
    });

    test('falls back to AI subtitles when there is no regular lyric', () {
      expect(
        shouldRenderSubtitleLyrics(
          hasMetingLyrics: false,
          subtitlesSelected: true,
          userSelected: false,
        ),
        isTrue,
      );
    });

    test('honours an explicit subtitle pick even with a regular lyric', () {
      expect(
        shouldRenderSubtitleLyrics(
          hasMetingLyrics: true,
          subtitlesSelected: true,
          userSelected: true,
        ),
        isTrue,
      );
    });
  });

  group('looksLikeInstrumental', () {
    test('instrumental titles and descriptions are detected', () {
      expect(looksLikeInstrumental(title: '助眠纯音乐合集'), isTrue);
      expect(looksLikeInstrumental(description: '轻音乐 / 白噪音'), isTrue);
      expect(looksLikeInstrumental(title: '晴天', description: null), isFalse);
      expect(looksLikeInstrumental(title: '  '), isFalse);
      expect(looksLikeInstrumental(), isFalse);
    });
  });

  group('resolveLyricSource', () {
    test('Meting 歌词存在而字幕只是自动选中时，算 Meting', () {
      // 这就是「面板显示 Meting、弹窗却勾着 ai-zh」的场景。
      expect(
        resolveLyricSource(
          hasMetingLyrics: true,
          subtitlesSelected: true,
          userSelected: false,
        ),
        LyricSource.meting,
      );
    });

    test('用户主动选了字幕轨就渲染字幕', () {
      expect(
        resolveLyricSource(
          hasMetingLyrics: true,
          subtitlesSelected: true,
          userSelected: true,
        ),
        LyricSource.subtitle,
      );
    });

    test('没有 Meting 歌词时用字幕', () {
      expect(
        resolveLyricSource(
          hasMetingLyrics: false,
          subtitlesSelected: true,
          userSelected: false,
        ),
        LyricSource.subtitle,
      );
    });

    test('两边都没有时是 none', () {
      expect(
        resolveLyricSource(
          hasMetingLyrics: false,
          subtitlesSelected: false,
          userSelected: false,
        ),
        LyricSource.none,
      );
    });
  });
}
