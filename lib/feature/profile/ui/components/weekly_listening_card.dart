import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/statistics/domain/daily_listening.dart';
import 'package:flutter/material.dart';

const List<String> _weekdayLabels = <String>['一', '二', '三', '四', '五', '六', '日'];

class WeeklyListeningCard extends StatelessWidget {
  const WeeklyListeningCard({
    super.key,
    required this.summary,
    required this.onReportTap,
  });

  final WeeklyListeningSummary summary;
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasData = summary.hasData;
    final String listenedLabel = hasData
        ? '本周听了 ${summary.listenedText}'
        : '本周听了 0 分钟';

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
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  listenedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: onReportTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      '查看报告 ›',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!hasData) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '本周还没听歌',
              style: AppTextStyles.meta(
                theme,
                fontSize: 12,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 12),
          _WeeklyListeningBars(days: summary.days),
        ],
      ),
    );
  }
}

class _WeeklyListeningBars extends StatelessWidget {
  const _WeeklyListeningBars({required this.days});

  static const double _barAreaHeight = 60;
  static const double _barWidth = 30;
  static const double _minBarHeight = 4;

  final List<DailyListening> days;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int maxListenedMs = _maxListenedMs();
    return Row(
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
                      key: ValueKey<String>('weekly-listening-bar-$index'),
                      width: _barWidth,
                      height: _barHeight(_listenedMsAt(index), maxListenedMs),
                      decoration: BoxDecoration(
                        color: _isPeak(_listenedMsAt(index), maxListenedMs)
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
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  DailyListening _dayAt(int index) {
    if (index < 0 || index >= days.length) {
      return const DailyListening();
    }
    return days[index];
  }

  int _listenedMsAt(int index) => _dayAt(index).listenedMs;

  int _maxListenedMs() {
    int maxValue = 0;
    for (int index = 0; index < _weekdayLabels.length; index += 1) {
      final int listenedMs = _listenedMsAt(index);
      if (listenedMs > maxValue) {
        maxValue = listenedMs;
      }
    }
    return maxValue;
  }

  bool _isPeak(int listenedMs, int maxListenedMs) {
    return listenedMs > 0 && listenedMs == maxListenedMs;
  }

  double _barHeight(int listenedMs, int maxListenedMs) {
    if (listenedMs <= 0 || maxListenedMs <= 0) {
      return 0;
    }
    final double height = listenedMs / maxListenedMs * _barAreaHeight;
    return height < _minBarHeight ? _minBarHeight : height;
  }
}
