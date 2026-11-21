import 'package:bilimusic/feature/metadata/logic/lyric_keyword_candidates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('括号里的正式歌名排在前面', () {
    expect(
      lyricKeywordCandidates(
        title: '“直到永远”【Forever-The Little Dippers】',
        author: 'PURELOVEXYS',
      ).first,
      '直到永远',
    );
  });

  test('引号里的歌名优先，英文歌名能被取到', () {
    final List<String> candidates = lyricKeywordCandidates(
      title: '【4K修复/MV】直到永远 - Forever - 卢绍莹',
    );
    expect(candidates, contains('直到永远'));
    expect(candidates, contains('Forever'));
    expect(candidates, isNot(contains('4K修复')));
  });

  test('过滤噪声词与数字，去掉 UP 主名', () {
    final List<String> candidates = lyricKeywordCandidates(
      title: '《晴天》 周杰伦 无损音质 1080P',
      author: '周杰伦',
    );
    expect(candidates.first, '晴天');
    expect(candidates, isNot(contains('1080P')));
    expect(candidates, isNot(contains('无损音质')));
    expect(candidates, isNot(contains('周杰伦')));
  });

  test('空标题返回空列表', () {
    expect(lyricKeywordCandidates(title: '   '), isEmpty);
  });
}
