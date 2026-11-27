import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/chart_track_matcher.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:flutter_test/flutter_test.dart';

const MusicChartTrack _track = MusicChartTrack(
  chart: MusicChartCatalog.defaultChart,
  rank: 1,
  title: '晴天',
  artist: '周杰伦',
  coverUrl: '',
  durationSeconds: 269,
);

SearchResultItem _item({
  String title = '',
  String author = '',
  String duration = '00:00',
  String playCount = '',
}) {
  return SearchResultItem(
    aid: 1,
    bvid: 'BV1',
    typeId: 3,
    title: title,
    author: author,
    coverUrl: '',
    duration: duration,
    playCountText: playCount,
    danmakuCountText: '',
    publishTimeText: '',
    tagText: '',
  );
}

void main() {
  test('prefers the candidate containing title, artist and duration', () {
    final List<SearchResultItem> candidates = <SearchResultItem>[
      _item(title: '无关视频', duration: '04:29'),
      _item(title: '【4K】晴天 - 周杰伦 现场版', duration: '04:30'),
      _item(title: '晴天', author: '翻唱', duration: '03:10'),
    ];

    final SearchResultItem? match = ChartTrackMatcher.pickBest(
      track: _track,
      candidates: candidates,
    );

    expect(match, isNotNull);
    expect(match!.title, contains('晴天 - 周杰伦'));
  });

  test('keeps the first candidate on ties', () {
    final List<SearchResultItem> candidates = <SearchResultItem>[
      _item(title: '晴天', duration: '04:29'),
      _item(title: '晴天', duration: '04:29'),
    ];

    expect(
      ChartTrackMatcher.pickBest(track: _track, candidates: candidates)?.title,
      '晴天',
    );
  });

  test('returns null when nothing looks like the song', () {
    final List<SearchResultItem> candidates = <SearchResultItem>[
      _item(title: '篮球集锦', duration: '10:00'),
      _item(title: '游戏实况', duration: '20:00'),
    ];

    expect(
      ChartTrackMatcher.pickBest(track: _track, candidates: candidates),
      isNull,
    );
    expect(
      ChartTrackMatcher.pickBest(track: _track, candidates: const []),
      isNull,
    );
  });

  test('rejects an artist-only title when the duration is far off', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: [_item(title: '周杰伦金曲串烧', duration: '10:00')],
      ),
      isNull,
    );
    // 只有歌手命中、歌名不在标题里的视频（同一 UP 主的其他歌 / 金曲合辑）
    // 一律不认，哪怕时长刚好对上——这正是「推荐《光年之外》却播成《雾里》」
    // 那类误匹配的成因。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: [_item(title: '周杰伦金曲串烧', duration: '04:31')],
      ),
      isNull,
    );
  });

  test('generic short titles need artist or exact duration to match', () {
    const MusicChartTrack genericTrack = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 3,
      title: '催眠曲',
      artist: '婴儿沉睡',
      coverUrl: '',
      durationSeconds: 211,
    );

    // 标题里出现「催眠曲」但歌手完全不搭、时长也对不上的合集，不该算命中。
    expect(
      ChartTrackMatcher.pickBest(
        track: genericTrack,
        candidates: <SearchResultItem>[
          _item(title: '28天失眠音疗｜助眠放松神器', duration: '03:30'),
        ],
      ),
      isNull,
    );

    // 歌名和歌手都在标题里就仍然能命中。
    expect(
      ChartTrackMatcher.pickBest(
        track: genericTrack,
        candidates: <SearchResultItem>[
          _item(title: '催眠曲｜婴儿沉睡｜白噪音', duration: '03:31'),
        ],
      ),
      isNotNull,
    );
  });
  test('rejects short clips even when title and artist match', () {
    // B 站上常见的几十秒剪辑版：标题、歌手都对，但不该进播放列表。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦 剪辑版', duration: '00:25'),
        ],
      ),
      isNull,
    );
  });

  test('ignores the ratio gate when the track duration looks like a clip', () {
    // 榜单接口给「最初的记忆」返回的时长是 00:29，真实完整版约 4 分钟：
    // 不能因为比例差太多就判为「太长」。
    const MusicChartTrack clipDurationTrack = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 2,
      title: '最初的记忆',
      artist: '火鸡',
      coverUrl: '',
      durationSeconds: 29,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: clipDurationTrack,
        candidates: <SearchResultItem>[
          _item(title: '最初的记忆 - 火鸡', duration: '04:00'),
        ],
      ),
      isNotNull,
    );

    // 但真正的几十秒片段依然要被挡掉。
    expect(
      ChartTrackMatcher.pickBest(
        track: clipDurationTrack,
        candidates: <SearchResultItem>[
          _item(title: '最初的记忆 - 火鸡', duration: '00:25'),
        ],
      ),
      isNull,
    );
  });
  test(
    'prefers a full song over a same-name short cover when duration is unreliable',
    () {
      const MusicChartTrack clipDurationTrack = MusicChartTrack(
        chart: MusicChartCatalog.defaultChart,
        rank: 2,
        title: '最初的记忆',
        artist: '火鸡',
        coverUrl: '',
        durationSeconds: 29,
      );

      final SearchResultItem? match = ChartTrackMatcher.pickBest(
        track: clipDurationTrack,
        candidates: <SearchResultItem>[
          _item(
            title: '火鸡 - 最初的记忆 (男生版)(原唱:徐佳莹)「我很安静…',
            duration: '01:06',
            playCount: '3000',
          ),
          _item(
            title: '在百万豪装录音棚大声听 徐佳莹《最初的记忆》',
            duration: '04:15',
            playCount: '5049000',
          ),
        ],
      );

      expect(match, isNotNull);
      expect(match!.duration, '04:15');
    },
  );

  test('falls back to a clip only when no full version is available', () {
    const MusicChartTrack clipDurationTrack = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 2,
      title: '最初的记忆',
      artist: '火鸡',
      coverUrl: '',
      durationSeconds: 29,
    );

    final SearchResultItem? fallback = ChartTrackMatcher.pickBest(
      track: clipDurationTrack,
      candidates: <SearchResultItem>[
        _item(title: '火鸡 - 最初的记忆', duration: '01:06'),
      ],
    );

    // 没有完整版时仍然给出这条，但完整版一旦出现就会优先（见上一条用例）。
    expect(fallback?.duration, '01:06');
  });
  test('rejects candidates far shorter than the track', () {
    // 原曲 4:29，候选只有 1 分钟 → 明显是片段。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '01:00'),
        ],
      ),
      isNull,
    );
  });

  test('still accepts a slightly shorter but complete version', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '04:20'),
        ],
      ),
      isNotNull,
    );
  });

  test('unknown track duration falls back to an absolute minimum', () {
    const MusicChartTrack unknownDuration = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 1,
      title: '晴天',
      artist: '周杰伦',
      coverUrl: '',
      durationSeconds: 0,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: unknownDuration,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '00:30'),
        ],
      ),
      isNull,
    );
    expect(
      ChartTrackMatcher.pickBest(
        track: unknownDuration,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '04:29'),
        ],
      ),
      isNotNull,
    );
  });

  test('keeps matching when the duration is unknown', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '00:00'),
        ],
      ),
      isNotNull,
    );
  });

  test('rejects a 2-minute cut of a 3-minute song', () {
    // 原策略会收下；新策略按时长占比直接淘汰。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '03:00'),
        ],
      ),
      isNull,
    );
  });

  test('rejects a candidate much longer than the song', () {
    // 4:29 的歌匹配到 6:30 的拼接视频。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '06:30'),
        ],
      ),
      isNull,
    );
  });

  test('prefers the upload whose duration is closest', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '04:03'),
          _item(title: '晴天 - 周杰伦', duration: '04:27'),
        ],
      )?.duration,
      '04:27',
    );
  });

  test('prefers the more popular upload when scores tie', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦', duration: '04:29', playCount: '5097'),
          _item(title: '晴天 - 周杰伦', duration: '04:29', playCount: '218.4万'),
        ],
      )?.playCountText,
      '218.4万',
    );
  });

  test('prefers the complete version over a compilation-looking title', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 - 周杰伦 合集', duration: '04:29'),
          _item(title: '晴天 - 周杰伦 完整版', duration: '04:29'),
        ],
      )?.title,
      contains('完整版'),
    );
  });

  test('parses durations and normalizes text', () {
    expect(ChartTrackMatcher.parseDurationSeconds('04:29'), 269);
    expect(ChartTrackMatcher.parseDurationSeconds('1:02:03'), 3723);
    expect(ChartTrackMatcher.parseDurationSeconds(''), 0);
    expect(ChartTrackMatcher.parseDurationSeconds('abc'), 0);
    expect(ChartTrackMatcher.normalize('【4K】晴天 - 周杰伦'), '4k晴天周杰伦');
  });

  test('rejects non-music videos that merely share a short title', () {
    const MusicChartTrack shortTitleTrack = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 1,
      title: '你的',
      artist: 'DouDou',
      coverUrl: '',
      durationSeconds: 163,
    );

    // 标题里带「你的」，但其实是游戏视频、UP 主也不是歌手。
    expect(
      ChartTrackMatcher.pickBest(
        track: shortTitleTrack,
        candidates: <SearchResultItem>[
          _item(title: '你的名字 游戏实况 第八期', author: '某个游戏up', duration: '02:43'),
        ],
      ),
      isNull,
    );

    // 歌手命中、时长也对得上，但没有命中原歌名 → 不认。
    expect(
      ChartTrackMatcher.pickBest(
        track: shortTitleTrack,
        candidates: <SearchResultItem>[
          _item(title: '另一首歌', author: 'DouDou', duration: '02:43'),
        ],
      ),
      isNull,
    );

    // 歌名 + 歌手都在标题里才认。
    expect(
      ChartTrackMatcher.pickBest(
        track: shortTitleTrack,
        candidates: <SearchResultItem>[
          _item(title: '你的 - DouDou 完整版', author: '音乐搬运工', duration: '02:43'),
        ],
      )?.title,
      contains('你的'),
    );
  });

  test(
    'title fallback picks a complete song when the artist is a cover act',
    () {
      const MusicChartTrack coverTrack = MusicChartTrack(
        chart: MusicChartCatalog.defaultChart,
        rank: 1,
        title: '光年之外',
        artist: '翻唱小哥',
        coverUrl: '',
        durationSeconds: 166,
      );

      final SearchResultItem? picked = ChartTrackMatcher.pickTitleFallback(
        track: coverTrack,
        candidates: <SearchResultItem>[
          _item(title: '光年之外 - 翻唱小哥', author: '翻唱小哥', duration: '02:46'),
          _item(
            title: '光年之外 官方MV - 邓紫棋',
            author: '邓紫棋',
            duration: '03:56',
            playCount: '3200万',
          ),
          _item(title: '光年之外 十小时循环', author: '某合集', duration: '9:59:59'),
        ],
      );

      expect(picked?.title, contains('官方MV'));
    },
  );

  test('繁体标题也能匹配到简体歌名', () {
    const MusicChartTrack track = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 4,
      title: '时间线',
      artist: '于冬然',
      coverUrl: '',
      durationSeconds: 189,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: track,
        candidates: <SearchResultItem>[
          _item(title: '于冬然 - 時間線', author: '心若薄荷', duration: '03:11'),
        ],
      )?.title,
      contains('時間線'),
    );
  });

  test('三个字的歌名也能走按歌名兜底', () {
    const MusicChartTrack track = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 4,
      title: '时间线',
      artist: '于冬然',
      coverUrl: '',
      durationSeconds: 189,
    );

    final SearchResultItem? picked = ChartTrackMatcher.pickTitleFallback(
      track: track,
      candidates: <SearchResultItem>[
        _item(title: '时间线 官方MV 完整版', author: '某搬运', duration: '03:12'),
      ],
    );

    expect(picked, isNotNull);
  });
}
