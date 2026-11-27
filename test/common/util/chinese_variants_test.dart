import 'package:bilimusic/common/util/chinese_variants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('把常见繁体歌名转成简体', () {
    expect(toSimplified('時間線'), '时间线');
    expect(toSimplified('戀人'), '恋人');
    expect(toSimplified('說好的幸福呢'), '说好的幸福呢');
    expect(toSimplified('夢一場'), '梦一场');
    expect(toSimplified('關於愛'), '关于爱');
  });

  test('简体原样返回，未收录字符保留', () {
    expect(toSimplified('时间线'), '时间线');
    expect(toSimplified('周杰伦'), '周杰伦');
    expect(toSimplified('ABC 晴天'), 'ABC 晴天');
    expect(toSimplified(''), '');
    expect(toSimplified('𠮷'), '𠮷');
  });

  test('中英混排也逐字处理', () {
    expect(toSimplified('Love Me 戀人'), 'Love Me 恋人');
  });
}
