/// 把歌名 / 歌手名归一成可比较的 key：去掉标点、括号、空白和大小写。
///
/// 注意括号里的内容要保留——中文歌名常常就写在《》里
/// （`【Hi-Res】|《于是》` 归一成 `hires于是`），删掉就对不上了。
String normalizeRadarKey(String value) {
  return value.toLowerCase().replaceAll(
    RegExp(r'''[\s\-_/\\.，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》·•—–]'''),
    '',
  );
}

String radarTrackKey({required String title, required String artist}) {
  return '${normalizeRadarKey(title)}|${normalizeRadarKey(artist)}';
}
