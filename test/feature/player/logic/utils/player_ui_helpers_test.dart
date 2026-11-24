import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

List<PlaybackChapter> _chapters({required int count, int stepSeconds = 10}) {
  return <PlaybackChapter>[
    for (int index = 0; index < count; index += 1)
      PlaybackChapter(
        start: Duration(seconds: index * stepSeconds),
        title: '章节 $index',
      ),
  ];
}

void main() {
  test('章节标记过密时不画，避免整条轨道变成一串点', () {
    final List<PlaybackChapter> chapters = _chapters(count: 90, stepSeconds: 3);

    expect(
      shouldRenderChapterMarkers(
        chapters: chapters,
        total: const Duration(minutes: 5),
        trackWidth: 330,
      ),
      isFalse,
    );
  });

  test('正常章节数量照常绘制', () {
    final List<PlaybackChapter> chapters = _chapters(count: 5, stepSeconds: 30);

    expect(
      shouldRenderChapterMarkers(
        chapters: chapters,
        total: const Duration(minutes: 5),
        trackWidth: 330,
      ),
      isTrue,
    );
  });

  test('章节不足或时长未知时不画', () {
    expect(
      shouldRenderChapterMarkers(
        chapters: const <PlaybackChapter>[
          PlaybackChapter(start: Duration(seconds: 1), title: '唯一'),
        ],
        total: const Duration(minutes: 5),
        trackWidth: 330,
      ),
      isFalse,
    );
    expect(
      shouldRenderChapterMarkers(
        chapters: _chapters(count: 4),
        total: Duration.zero,
        trackWidth: 330,
      ),
      isFalse,
    );
  });
}
