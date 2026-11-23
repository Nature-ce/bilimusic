enum PlayerChapterMarkerStyle {
  line,
  dot,
  segment,
  none;

  String get label => switch (this) {
    PlayerChapterMarkerStyle.line => '细线刻度',
    PlayerChapterMarkerStyle.dot => '圆点',
    PlayerChapterMarkerStyle.segment => '分段色块',
    PlayerChapterMarkerStyle.none => '不显示',
  };

  String get description => switch (this) {
    PlayerChapterMarkerStyle.line => '1px 竖线，最轻',
    PlayerChapterMarkerStyle.dot => '小圆点标记章节起点',
    PlayerChapterMarkerStyle.segment => '章节之间用色块区分',
    PlayerChapterMarkerStyle.none => '只要一条进度线',
  };

  static PlayerChapterMarkerStyle fromStorage(String? value) {
    for (final PlayerChapterMarkerStyle style
        in PlayerChapterMarkerStyle.values) {
      if (style.name == value) {
        return style;
      }
    }
    return PlayerChapterMarkerStyle.dot;
  }
}
