/// 从 B 站视频标题里提取可用于歌词搜索的关键词候选。
///
/// UP 主经常在歌名前後（甚至中间）加字，例如
/// `“直到永远”【Forever-The Little Dippers】`，
/// 直接拿整条标题或元数据里的错误歌名去搜都会跑偏。
/// 这里把引号 / 括号里的内容、分隔符切开的片段都提出来，
/// 过滤掉 MV、无损、翻唱这类噪声词，括号里的内容排在前面（多半是正式歌名）。
List<String> lyricKeywordCandidates({required String title, String? author}) {
  final String trimmed = title.trim();
  if (trimmed.isEmpty) {
    return const <String>[];
  }
  final String normalizedAuthor = (author ?? '').trim().toLowerCase();
  final List<String> quoted = <String>[];
  final List<String> plain = <String>[];

  final RegExp quotedPattern = RegExp(r'[“"「『《【\[]([^”"」』》\]】]+)[”"」』》\]】]');
  for (final RegExpMatch match in quotedPattern.allMatches(trimmed)) {
    _addSegments(match.group(1) ?? '', quoted, normalizedAuthor);
  }
  _addSegments(trimmed.replaceAll(quotedPattern, ' '), plain, normalizedAuthor);

  final List<String> ordered = <String>[...quoted, ...plain];
  final List<String> result = <String>[];
  for (final String candidate in ordered) {
    if (!result.contains(candidate)) {
      result.add(candidate);
    }
    if (result.length >= 5) {
      break;
    }
  }
  return result;
}

const List<String> _noiseWords = <String>[
  'mv',
  'official',
  '官方',
  '高清',
  '1080p',
  '4k',
  '8k',
  '无损',
  'hires',
  'hi-res',
  '完整版',
  '动态歌词',
  '歌词版',
  '歌词',
  '纯享',
  '收藏',
  '搬运',
  '翻唱',
  'cover',
  'live',
  '现场',
  'audio',
  '高音质',
  '试听',
  '无损音质',
  '纯音乐',
  '伴奏',
  '合集',
  '串烧',
];

void _addSegments(String text, List<String> sink, String normalizedAuthor) {
  for (final String raw in text.split(RegExp(r'[|丨/\\\-—–·•：:\s]+'))) {
    final String candidate = raw.trim().replaceAll(RegExp(r'^[\s\-_]+'), '');
    if (candidate.isEmpty) {
      continue;
    }
    final String lower = candidate.toLowerCase();
    if (lower == normalizedAuthor) {
      continue;
    }
    if (_noiseWords.any((String noise) => lower.contains(noise))) {
      continue;
    }
    if (candidate.length < 2) {
      continue;
    }
    if (RegExp(r'^[\d\s.]+$').hasMatch(candidate)) {
      continue;
    }
    if (!sink.contains(candidate)) {
      sink.add(candidate);
    }
  }
}
