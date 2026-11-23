import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromStorage resolves every known style name', () {
    for (final PlayerChapterMarkerStyle style
        in PlayerChapterMarkerStyle.values) {
      expect(
        PlayerChapterMarkerStyle.fromStorage(style.name),
        style,
        reason: style.name,
      );
    }
  });

  test('fromStorage falls back to dot for unknown or empty values', () {
    expect(
      PlayerChapterMarkerStyle.fromStorage(null),
      PlayerChapterMarkerStyle.dot,
    );
    expect(
      PlayerChapterMarkerStyle.fromStorage(''),
      PlayerChapterMarkerStyle.dot,
    );
    expect(
      PlayerChapterMarkerStyle.fromStorage('future-style'),
      PlayerChapterMarkerStyle.dot,
    );
  });

  test('exposes the four settings labels and descriptions', () {
    expect(
      PlayerChapterMarkerStyle.values.map(
        (PlayerChapterMarkerStyle style) => style.label,
      ),
      <String>['细线刻度', '圆点', '分段色块', '不显示'],
    );
    for (final PlayerChapterMarkerStyle style
        in PlayerChapterMarkerStyle.values) {
      expect(style.description, isNotEmpty);
    }
  });
}
