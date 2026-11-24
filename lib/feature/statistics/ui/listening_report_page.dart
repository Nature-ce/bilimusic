import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/display_text.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:bilimusic/feature/statistics/domain/listening_report.dart';
import 'package:bilimusic/feature/statistics/logic/listening_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<String> _weekdayLabels = <String>['一', '二', '三', '四', '五', '六', '日'];

class ListeningReportPage extends ConsumerWidget {
  const ListeningReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ListeningReport report = ref.watch(listeningReportProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const PageAppBar(title: Text('听歌报告')),
      body: report.hasData
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: <Widget>[
                _ReportHero(report: report),
                const SizedBox(height: 12),
                _ReportMetrics(report: report),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: report.topSongsAreCumulative ? '常听的歌' : '本周最常听',
                  trailing: report.topSongs.isEmpty
                      ? null
                      : report.topSongsAreCumulative
                      ? '累计播放'
                      : '按收听时长排序',
                ),
                const SizedBox(height: 8),
                _TopSongsSection(
                  songs: report.topSongs,
                  cumulative: report.topSongsAreCumulative,
                ),
                const SizedBox(height: 20),
                const _SectionTitle(title: '近两周对比'),
                const SizedBox(height: 8),
                _WeekComparison(report: report),
                const SizedBox(height: 18),
                Text(
                  '统计来自本机播放记录，未播放完整的内容也会计入收听时长。',
                  style: AppTextStyles.meta(Theme.of(context), fontSize: 10.5),
                ),
              ],
            )
          : StatusView(
              icon: Icons.insights_rounded,
              iconColor: colorScheme.primary,
              title: '还没有听歌数据',
              description: '先听几首歌，这里会生成本周的分析报告。',
            ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.report});

  final ListeningReport report;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.16),
            colorScheme.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '本周听歌',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                report.weekRangeLabel,
                style: AppTextStyles.meta(theme, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.listenedText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: colorScheme.onSurface,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${report.weekSongs} 首 · ${report.comparisonLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.meta(
              theme,
              fontSize: 12,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          _WeeklyBars(report: report),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.report});

  static const double _barAreaHeight = 64;
  static const double _barWidth = 30;
  static const double _minBarHeight = 4;

  final ListeningReport report;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final int maxListenedMs = report.maxDayListenedMs;
    final int peakIndex = report.peakDayIndex;
    final int todayIndex = report.elapsedDays - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (int index = 0; index < _weekdayLabels.length; index += 1)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: _barAreaHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: _barWidth,
                      height: _barHeightAt(index, maxListenedMs),
                      decoration: BoxDecoration(
                        color: index == peakIndex
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _weekdayLabels[index],
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: index == todayIndex
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: index == todayIndex
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  DailyListening _dayAt(int index) {
    if (index < 0 || index >= report.days.length) {
      return const DailyListening();
    }
    return report.days[index];
  }

  double _barHeightAt(int index, int maxListenedMs) {
    final int listenedMs = _dayAt(index).listenedMs;
    if (listenedMs <= 0 || maxListenedMs <= 0) {
      return 0;
    }
    final double height = listenedMs / maxListenedMs * _barAreaHeight;
    return height < _minBarHeight ? _minBarHeight : height;
  }
}

class _ReportMetrics extends StatelessWidget {
  const _ReportMetrics({required this.report});

  final ListeningReport report;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 10;
        final double itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            SizedBox(
              width: itemWidth,
              child: _ReportMetricTile(
                label: '听歌天数',
                value: '${report.listenedDays}/${report.elapsedDays} 天',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _ReportMetricTile(
                label: '连续听歌',
                value: '${report.streakDays} 天',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _ReportMetricTile(
                label: '日均时长',
                value: report.averageDailyText,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _ReportMetricTile(
                label: '本周新增',
                value: '${report.newSongCount} 首',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReportMetricTile extends StatelessWidget {
  const _ReportMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.meta(theme, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSongsSection extends StatelessWidget {
  const _TopSongsSection({required this.songs, required this.cumulative});

  final List<ListeningReportSong> songs;
  final bool cumulative;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Text(
        '还没有播放过的歌',
        style: AppTextStyles.meta(Theme.of(context), fontSize: 12),
      );
    }

    return Column(
      children: <Widget>[
        for (int index = 0; index < songs.length; index += 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TopSongRow(
              rank: index + 1,
              song: songs[index],
              cumulative: cumulative,
            ),
          ),
      ],
    );
  }
}

class _TopSongRow extends StatelessWidget {
  const _TopSongRow({
    required this.rank,
    required this.song,
    required this.cumulative,
  });

  final int rank;
  final ListeningReportSong song;
  final bool cumulative;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String title = normalizeDisplayText(song.title.trim());
    final String author = normalizeDisplayText(song.author.trim());

    return Row(
      children: <Widget>[
        SizedBox(
          width: 18,
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: rank <= 3
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        CommonCachedImage(
          imageUrl: song.coverUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          fallbackIcon: Icons.music_note_rounded,
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title.isEmpty ? '未命名内容' : title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                author.isEmpty ? '未知来源' : author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meta(theme, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          cumulative
              ? '累计 ${song.plays} 次 · ${formatListenedMinutes(song.listenedMs)}'
              : '${song.plays} 次 · ${formatListenedMinutes(song.listenedMs)}',
          style: AppTextStyles.meta(
            theme,
            fontSize: 11,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _WeekComparison extends StatelessWidget {
  const _WeekComparison({required this.report});

  final ListeningReport report;

  @override
  Widget build(BuildContext context) {
    final int maxListenedMs = report.weekListenedMs > report.lastWeekListenedMs
        ? report.weekListenedMs
        : report.lastWeekListenedMs;
    return Column(
      children: <Widget>[
        _ComparisonRow(
          label: '本周',
          listenedMs: report.weekListenedMs,
          maxListenedMs: maxListenedMs,
          listenedText: report.listenedText,
          highlighted: true,
        ),
        const SizedBox(height: 10),
        _ComparisonRow(
          label: '上周',
          listenedMs: report.lastWeekListenedMs,
          maxListenedMs: maxListenedMs,
          listenedText: report.lastWeekListenedText,
          highlighted: false,
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.listenedMs,
    required this.maxListenedMs,
    required this.listenedText,
    required this.highlighted,
  });

  final String label;
  final int listenedMs;
  final int maxListenedMs;
  final String listenedText;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double fraction = maxListenedMs <= 0
        ? 0
        : (listenedMs / maxListenedMs).clamp(0.0, 1.0);

    return Row(
      children: <Widget>[
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: highlighted
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              height: 10,
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: highlighted
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const SizedBox(height: 10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 88,
          child: Text(
            listenedText,
            textAlign: TextAlign.right,
            style: AppTextStyles.meta(
              theme,
              fontSize: 11,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitleFrom(theme.colorScheme),
          ),
        ),
        if (trailing != null)
          Text(trailing!, style: AppTextStyles.meta(theme, fontSize: 11)),
      ],
    );
  }
}
