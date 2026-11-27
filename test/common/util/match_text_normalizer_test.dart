import 'package:bilimusic/common/util/match_text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('全角字母数字归一成半角', () {
    expect(normalizeForMatching('ＡＢＣ １２３'), 'abc123');
    expect(normalizeForMatching('ＡＢＣ'), normalizeForMatching('ABC'));
  });

  test('装饰花体字母归一成普通字母', () {
    expect(normalizeForMatching('𝐀𝐁𝐂'), 'abc');
    expect(normalizeForMatching('𝐀𝐁𝐂'), normalizeForMatching('abc'));
  });

  test('半角片假名归一成全角（含浊音）', () {
    expect(normalizeForMatching('ｷﾀﾆﾀﾂﾔ'), normalizeForMatching('キタニタツヤ'));
    expect(normalizeForMatching('ｶﾞｷﾞｸﾞ'), normalizeForMatching('ガギグ'));
    expect(normalizeForMatching('ﾊﾟﾋﾟﾌﾟ'), normalizeForMatching('パピプ'));
  });

  test('& 与 and 视为同一写法', () {
    expect(
      normalizeForMatching('Simon & Garfunkel'),
      normalizeForMatching('Simon and Garfunkel'),
    );
  });

  test('Pt.2 与 Part 2 视为同一写法', () {
    expect(
      normalizeForMatching('Song Pt.2'),
      normalizeForMatching('Song Part 2'),
    );
    expect(
      normalizeForMatching('Album Vol.1'),
      normalizeForMatching('Album Volume1'),
    );
  });

  test('变音符号被去掉', () {
    expect(normalizeForMatching('Beyoncé'), normalizeForMatching('Beyonce'));
    expect(
      normalizeForMatching('Motörhead'),
      normalizeForMatching('Motorhead'),
    );
  });

  test('大小写与标点仍然不敏感', () {
    expect(
      normalizeForMatching("Don't Stop"),
      normalizeForMatching('DONT STOP'),
    );
    expect(normalizeForMatching('Say So'), 'sayso');
  });

  test('繁简归一仍然生效', () {
    expect(normalizeForMatching('時間線'), normalizeForMatching('时间线'));
  });

  test('空字符串与纯标点返回空', () {
    expect(normalizeForMatching('   '), '');
    expect(normalizeForMatching('《》'), '');
  });
}
