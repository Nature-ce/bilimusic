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
  String tagText = '',
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
    tagText: tagText,
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

  test('英文歌：变音符号与全角不影响匹配', () {
    const MusicChartTrack track = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 1,
      title: 'Halo',
      artist: 'Beyoncé',
      coverUrl: '',
      durationSeconds: 261,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: track,
        candidates: <SearchResultItem>[
          _item(
            title: 'Beyonce - Halo 官方MV',
            author: '某音乐搬运',
            duration: '04:21',
          ),
        ],
      ),
      isNotNull,
    );
  });

  test('日文歌：半角片假名歌手名也能匹配', () {
    const MusicChartTrack track = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 1,
      title: 'LOSER',
      artist: 'キタニタツヤ',
      coverUrl: '',
      durationSeconds: 203,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: track,
        candidates: <SearchResultItem>[
          _item(title: 'ｷﾀﾆﾀﾂﾔ - LOSER', author: '文火', duration: '03:23'),
        ],
      ),
      isNotNull,
    );
  });

  test('教学视频即使带歌名和歌手也不认', () {
    // 「5分钟教你弹《晴天》」04:50，原曲 04:29 —— 时长比例 1.08，
    // 时长闸门挡不住，只能靠教学词拦。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '5分钟教你弹《晴天》副歌 周杰伦', duration: '04:50'),
        ],
      ),
      isNull,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '【吉他指弹教学】晴天 - 周杰伦', duration: '04:30'),
        ],
      ),
      isNull,
    );

    // 原曲时长未知时，15 分钟的教学视频以前一路放行，现在两道闸门都拦。
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
          _item(title: '零基础吉他教学《晴天》周杰伦', duration: '15:20'),
        ],
      ),
      isNull,
    );
  });

  test('教学视频与正版 MV 同列时选正版', () {
    final SearchResultItem? match = ChartTrackMatcher.pickBest(
      track: _track,
      candidates: <SearchResultItem>[
        _item(title: '零基础吉他教学《晴天》周杰伦', duration: '04:30', playCount: '500万'),
        _item(title: '晴天 - 周杰伦 官方MV', duration: '04:29', playCount: '1万'),
      ],
    );

    expect(match?.title, contains('官方MV'));
  });

  test('歌名自带教学类词不影响匹配', () {
    // 刘若英《练习》：歌名本身带「练习」，不能被当成教学视频拒掉。
    const MusicChartTrack practiceTrack = MusicChartTrack(
      chart: MusicChartCatalog.defaultChart,
      rank: 1,
      title: '练习',
      artist: '刘若英',
      coverUrl: '',
      durationSeconds: 265,
    );

    expect(
      ChartTrackMatcher.pickBest(
        track: practiceTrack,
        candidates: <SearchResultItem>[
          _item(title: '刘若英 - 练习', author: '音乐搬运工', duration: '04:25'),
        ],
      ),
      isNotNull,
    );

    // 但《练习》的教学视频仍然要拒：去掉歌名和歌手后剩下「吉他教学」。
    expect(
      ChartTrackMatcher.pickBest(
        track: practiceTrack,
        candidates: <SearchResultItem>[
          _item(title: '《练习》吉他教学 刘若英', duration: '04:25'),
        ],
      ),
      isNull,
    );
  });

  test('非音乐内容不再享受「歌手命中」豁免', () {
    // 标题里歌名、歌手都在，但其实是游戏实况 —— 以前会放行。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 游戏实况 周杰伦', duration: '04:29'),
        ],
      ),
      isNull,
    );
  });

  test('游戏主题曲的正式 MV 不被误杀', () {
    // 「游戏」只是降权词：游戏主题曲 / 英雄联盟主题曲的正式投稿照样能匹配。
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天 英雄联盟游戏主题曲 官方MV 周杰伦', duration: '04:29'),
        ],
      ),
      isNotNull,
    );
  });

  test('原曲时长未知时过长的候选被拒', () {
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
          _item(title: '晴天 - 周杰伦', duration: '15:00'),
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

  test('同分时优先音乐分区的候选', () {
    final SearchResultItem? match = ChartTrackMatcher.pickBest(
      track: _track,
      candidates: <SearchResultItem>[
        _item(
          title: '晴天 - 周杰伦',
          duration: '04:29',
          playCount: '300万',
          tagText: '日常',
        ),
        _item(
          title: '晴天 - 周杰伦',
          duration: '04:29',
          playCount: '5000',
          tagText: '音乐',
        ),
      ],
    );

    expect(match?.tagText, '音乐');
  });

  test('演唱会现场等内容不受教学词影响', () {
    expect(
      ChartTrackMatcher.pickBest(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '周杰伦《晴天》演唱会现场', duration: '04:30'),
        ],
      ),
      isNotNull,
    );
  });

  test('诊断：候选全被时长闸门拒掉时返回 true', () {
    // 榜单时长脏（4:29 的歌，候选全是 12 分钟教学/合集）——这种「匹配不到」
    // 不该写进负缓存，否则本来能匹配的歌会被锁住。
    expect(
      ChartTrackMatcher.onlyDurationRejected(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天合集', duration: '12:00'),
          _item(title: '晴天片段', duration: '00:30'),
        ],
      ),
      isTrue,
    );

    // 有一条候选时长可用，就不算「全被时长拒掉」。
    expect(
      ChartTrackMatcher.onlyDurationRejected(
        track: _track,
        candidates: <SearchResultItem>[
          _item(title: '晴天合集', duration: '12:00'),
          _item(title: '完全无关的视频', duration: '04:29'),
        ],
      ),
      isFalse,
    );

    expect(
      ChartTrackMatcher.onlyDurationRejected(
        track: _track,
        candidates: const <SearchResultItem>[],
      ),
      isFalse,
    );
  });
}
