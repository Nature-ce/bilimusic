import 'package:bilimusic/feature/player/logic/lyrics/lyric_source_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldRenderSubtitleLyrics', () {
    test('never renders subtitles when no track is selected', () {
      expect(
        shouldRenderSubtitleLyrics(
          itemIsSpoken: false,
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
          itemIsSpoken: false,
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
          itemIsSpoken: false,
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
          itemIsSpoken: false,
          hasMetingLyrics: true,
          subtitlesSelected: true,
          userSelected: true,
        ),
        isTrue,
      );
    });

    test('spoken items always follow the selected subtitle track', () {
      expect(
        shouldRenderSubtitleLyrics(
          itemIsSpoken: true,
          hasMetingLyrics: true,
          subtitlesSelected: true,
          userSelected: false,
        ),
        isTrue,
      );
    });
  });

  group('allowsMetingLyrics', () {
    test('multi part and chaptered items always allow Meting lyrics', () {
      for (final bool tracks in <bool>[false, true]) {
        for (final bool manual in <bool>[false, true]) {
          expect(
            allowsMetingLyrics(
              singlePart: false,
              hasSubtitleTracks: tracks,
              manualMatch: manual,
            ),
            isTrue,
          );
        }
      }
    });

    test(
      'single part items only allow Meting lyrics with tracks or a match',
      () {
        expect(
          allowsMetingLyrics(
            singlePart: true,
            hasSubtitleTracks: false,
            manualMatch: false,
          ),
          isFalse,
        );
        expect(
          allowsMetingLyrics(
            singlePart: true,
            hasSubtitleTracks: true,
            manualMatch: false,
          ),
          isTrue,
        );
        expect(
          allowsMetingLyrics(
            singlePart: true,
            hasSubtitleTracks: false,
            manualMatch: true,
          ),
          isTrue,
        );
      },
    );
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
}
