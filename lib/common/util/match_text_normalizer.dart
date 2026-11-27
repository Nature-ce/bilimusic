import 'package:bilimusic/common/util/chinese_variants.dart';
import 'package:bilimusic/common/util/display_text.dart';

/// 匹配归一里被忽略的字符：空格与常见中英标点。
final RegExp matchingIgnoredCharacters = RegExp(
  r'''[\s\-_/\\.。，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]''',
);

const Map<String, String> _halfwidthKatakanaPairs = <String, String>{
  'ｳﾞ': 'ヴ',
  'ｶﾞ': 'ガ',
  'ｷﾞ': 'ギ',
  'ｸﾞ': 'グ',
  'ｹﾞ': 'ゲ',
  'ｺﾞ': 'ゴ',
  'ｻﾞ': 'ザ',
  'ｼﾞ': 'ジ',
  'ｽﾞ': 'ズ',
  'ｾﾞ': 'ゼ',
  'ｿﾞ': 'ゾ',
  'ﾀﾞ': 'ダ',
  'ﾁﾞ': 'ヂ',
  'ﾂﾞ': 'ヅ',
  'ﾃﾞ': 'デ',
  'ﾄﾞ': 'ド',
  'ﾊﾞ': 'バ',
  'ﾋﾞ': 'ビ',
  'ﾌﾞ': 'ブ',
  'ﾍﾞ': 'ベ',
  'ﾎﾞ': 'ボ',
  'ﾊﾟ': 'パ',
  'ﾋﾟ': 'ピ',
  'ﾌﾟ': 'プ',
  'ﾍﾟ': 'ペ',
  'ﾎﾟ': 'ポ',
};

const Map<String, String> _halfwidthKatakanaSingles = <String, String>{
  '｡': '。',
  '｢': '「',
  '｣': '」',
  '､': '、',
  '･': '・',
  'ｦ': 'ヲ',
  'ｧ': 'ァ',
  'ｨ': 'ィ',
  'ｩ': 'ゥ',
  'ｪ': 'ェ',
  'ｫ': 'ォ',
  'ｬ': 'ャ',
  'ｭ': 'ュ',
  'ｮ': 'ョ',
  'ｯ': 'ッ',
  'ｰ': 'ー',
  'ｱ': 'ア',
  'ｲ': 'イ',
  'ｳ': 'ウ',
  'ｴ': 'エ',
  'ｵ': 'オ',
  'ｶ': 'カ',
  'ｷ': 'キ',
  'ｸ': 'ク',
  'ｹ': 'ケ',
  'ｺ': 'コ',
  'ｻ': 'サ',
  'ｼ': 'シ',
  'ｽ': 'ス',
  'ｾ': 'セ',
  'ｿ': 'ソ',
  'ﾀ': 'タ',
  'ﾁ': 'チ',
  'ﾂ': 'ツ',
  'ﾃ': 'テ',
  'ﾄ': 'ト',
  'ﾅ': 'ナ',
  'ﾆ': 'ニ',
  'ﾇ': 'ヌ',
  'ﾈ': 'ネ',
  'ﾉ': 'ノ',
  'ﾊ': 'ハ',
  'ﾋ': 'ヒ',
  'ﾌ': 'フ',
  'ﾍ': 'ヘ',
  'ﾎ': 'ホ',
  'ﾏ': 'マ',
  'ﾐ': 'ミ',
  'ﾑ': 'ム',
  'ﾒ': 'メ',
  'ﾓ': 'モ',
  'ﾔ': 'ヤ',
  'ﾕ': 'ユ',
  'ﾖ': 'ヨ',
  'ﾗ': 'ラ',
  'ﾘ': 'リ',
  'ﾙ': 'ル',
  'ﾚ': 'レ',
  'ﾛ': 'ロ',
  'ﾜ': 'ワ',
  'ﾝ': 'ン',
  'ﾞ': '',
  'ﾟ': '',
};

const Map<String, String> _diacritics = <String, String>{
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'ā': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ė': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ø': 'o',
  'ō': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ñ': 'n',
  'ç': 'c',
  'č': 'c',
  'š': 's',
  'ž': 'z',
  'ğ': 'g',
  'ş': 's',
  'ı': 'i',
  'ł': 'l',
  'đ': 'd',
  'ß': 'ss',
  'æ': 'ae',
  'œ': 'oe',
  'þ': 'th',
};

final RegExp _halfwidthKatakanaRange = RegExp(r'[\uFF61-\uFF9F]');
final RegExp _partAbbreviation = RegExp(
  r'\bpt\.?\s*(\d)',
  caseSensitive: false,
);
final RegExp _volumeAbbreviation = RegExp(
  r'\bvol\.?\s*(\d)',
  caseSensitive: false,
);

/// 匹配用的归一：把「同一首歌的不同写法」压成同一个字符串。
///
/// 覆盖：全角/装饰花体字母、半角片假名、变音符号、`&` 与 `and`、
/// `Pt.2` 与 `Part 2`、繁简，最后统一小写并去掉标点空格。
String normalizeForMatching(String value) {
  if (value.trim().isEmpty) {
    return '';
  }
  String text = normalizeDisplayText(value);
  text = _convertHalfwidthKatakana(text);
  text = _stripDiacritics(text);
  text = text.replaceAll('&', ' and ');
  text = text.replaceAllMapped(
    _partAbbreviation,
    (Match match) => 'part${match.group(1)}',
  );
  text = text.replaceAllMapped(
    _volumeAbbreviation,
    (Match match) => 'volume${match.group(1)}',
  );
  text = toSimplified(text);
  return text.toLowerCase().replaceAll(matchingIgnoredCharacters, '');
}

String _convertHalfwidthKatakana(String value) {
  if (!_halfwidthKatakanaRange.hasMatch(value)) {
    return value;
  }
  String text = value;
  for (final MapEntry<String, String> entry
      in _halfwidthKatakanaPairs.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }
  final StringBuffer buffer = StringBuffer();
  for (final String char in text.split('')) {
    buffer.write(_halfwidthKatakanaSingles[char] ?? char);
  }
  return buffer.toString();
}

String _stripDiacritics(String value) {
  final StringBuffer buffer = StringBuffer();
  for (final String char in value.split('')) {
    buffer.write(_diacritics[char.toLowerCase()] ?? char);
  }
  return buffer.toString();
}
