import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/player/domain/player_playback_speed.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/domain/queue_source.dart';
import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:bilimusic/feature/radar/logic/radar_refresh_requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 睡眠定时滑杆的档位：0 = 关，之后每 5 分钟一档，最多 120 分钟。
const int kSleepTimerMaxMinutes = 120;

/// 刻度尺两端留白（逻辑像素）：避免首尾标签贴到卡片边缘。
const double kScaleRulerEdgeInset = 16;
const int kSleepTimerStepMinutes = 5;

List<int> get _sleepTimerStops => <int>[
  for (
    int minutes = 0;
    minutes <= kSleepTimerMaxMinutes;
    minutes += kSleepTimerStepMinutes
  )
    minutes,
];

const Set<int> _sleepTimerLabelMinutes = <int>{0, 30, 60, 90, 120};

Future<void> showPlayerSettingsSheet({
  required BuildContext context,
  required VoidCallback? onOpenExternal,
}) {
  return showAppHalfSheet<void>(
    context: context,
    tone: GlassTone.smoke,
    maxHeightFactor: 0.72,
    builder: (BuildContext sheetContext) =>
        PlayerSettingsSheetContent(onOpenExternal: onOpenExternal),
  );
}

/// 播放页「播放设置」面板：睡眠定时（可拖动刻度）+ 倍速播放 + 外部应用打开。
class PlayerSettingsSheetContent extends ConsumerWidget {
  const PlayerSettingsSheetContent({super.key, required this.onOpenExternal});

  final VoidCallback? onOpenExternal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final SleepTimerState sleepTimer = ref.watch(sleepTimerControllerProvider);
    final String? queueSourceLabel = ref
        .watch(playerControllerProvider)
        .queueSourceLabel;
    final double speed = ref.watch(playerControllerProvider).speed;

    final List<int> sleepStops = _sleepTimerStops;
    final int activeSleepMinutes = sleepTimer.isActive
        ? (sleepTimer.duration?.inMinutes ?? 0).clamp(0, kSleepTimerMaxMinutes)
        : 0;
    final int sleepIndex = _nearestIndex(
      sleepStops.map((int value) => value.toDouble()).toList(growable: false),
      activeSleepMinutes.toDouble(),
    );

    final int speedIndex = _nearestIndex(kPlayerPlaybackSpeeds, speed);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
            child: Text(
              '播放设置',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _CardHead(
                  title: '睡眠定时',
                  value: sleepTimer.isActive
                      ? '${sleepStops[sleepIndex]} 分钟'
                      : 'OFF',
                  valueActive: sleepTimer.isActive,
                ),
                ScaleRuler(
                  scaleKey: const Key('sleepTimerScale'),
                  stops: sleepStops
                      .map((int minutes) => minutes.toDouble())
                      .toList(growable: false),
                  labels: <int, String>{
                    for (int index = 0; index < sleepStops.length; index += 1)
                      if (_sleepTimerLabelMinutes.contains(sleepStops[index]))
                        index: sleepStops[index] == 0
                            ? '关'
                            : '${sleepStops[index]}',
                  },
                  selectedIndex: sleepIndex,
                  valueText: sleepStops[sleepIndex] == 0
                      ? '关'
                      : '${sleepStops[sleepIndex]} 分钟',
                  onSelected: (int index) {
                    final int minutes = sleepStops[index];
                    final SleepTimerController controller = ref.read(
                      sleepTimerControllerProvider.notifier,
                    );
                    if (minutes <= 0) {
                      controller.cancel();
                    } else {
                      controller.start(Duration(minutes: minutes));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _CardHead(
                  title: '倍速播放',
                  value: formatPlaybackSpeed(kPlayerPlaybackSpeeds[speedIndex]),
                  valueActive: true,
                ),
                ScaleRuler(
                  scaleKey: const Key('playbackSpeedScale'),
                  stops: kPlayerPlaybackSpeeds,
                  labels: <int, String>{
                    // 51 档太密：每 0.5x（10 档）标一个数字。
                    for (
                      int index = 0;
                      index < kPlayerPlaybackSpeeds.length;
                      index += 10
                    )
                      index: formatPlaybackSpeed(kPlayerPlaybackSpeeds[index]),
                  },
                  selectedIndex: speedIndex,
                  valueText: formatPlaybackSpeed(
                    kPlayerPlaybackSpeeds[speedIndex],
                  ),
                  onSelected: (int index) {
                    ref
                        .read(playerControllerProvider.notifier)
                        .setSpeed(kPlayerPlaybackSpeeds[index]);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                if (isAutoFeedQueue(queueSourceLabel))
                  _SettingsActionRow(
                    rowKey: const Key('radarRefreshSettingsEntry'),
                    icon: Icons.radar_rounded,
                    title: '换一批推荐',
                    subtitle: '按最近的收听重新算一批',
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(radarRefreshRequestsProvider.notifier).request();
                    },
                  ),
                if (isAutoFeedQueue(queueSourceLabel))
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                _SettingsActionRow(
                  icon: Icons.open_in_new_rounded,
                  title: '外部应用打开',
                  onTap: onOpenExternal == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onOpenExternal!();
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _nearestIndex(List<double> stops, double value) {
    if (stops.isEmpty) {
      return 0;
    }
    int best = 0;
    double bestDistance = (stops.first - value).abs();
    for (int index = 1; index < stops.length; index += 1) {
      final double distance = (stops[index] - value).abs();
      if (distance < bestDistance) {
        best = index;
        bestDistance = distance;
      }
    }
    return best;
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(15, 14, 15, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _CardHead extends StatelessWidget {
  const _CardHead({
    required this.title,
    required this.value,
    required this.valueActive,
  });

  final String title;
  final String value;
  final bool valueActive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueActive
                ? theme.colorScheme.primary
                : Colors.white.withValues(alpha: 0.34),
          ),
        ),
      ],
    );
  }
}

/// 带刻度的横向尺：点按或拖动选中最近的一档，选中刻度高亮并在上方浮出当前值。
class ScaleRuler extends StatelessWidget {
  const ScaleRuler({
    super.key,
    required this.scaleKey,
    required this.stops,
    required this.labels,
    required this.selectedIndex,
    required this.valueText,
    required this.onSelected,
  });

  final Key scaleKey;
  final List<double> stops;
  final Map<int, String> labels;
  final int selectedIndex;

  /// 仅用于无障碍朗读；界面上数值只显示在卡片右上角。
  final String valueText;
  final ValueChanged<int> onSelected;

  static const double _rulerHeight = 52;

  double _trackWidth(double width) =>
      (width - kScaleRulerEdgeInset * 2).clamp(1.0, width);

  void _handlePosition(double dx, double width) {
    if (stops.length < 2 || width <= 0) {
      return;
    }
    final double ratio = ((dx - kScaleRulerEdgeInset) / _trackWidth(width))
        .clamp(0.0, 1.0);
    final int index = (ratio * (stops.length - 1)).round();
    if (index != selectedIndex) {
      onSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double trackWidth = _trackWidth(width);
        final double ratio = stops.length < 2
            ? 0
            : selectedIndex / (stops.length - 1);

        return Semantics(
          label: valueText,
          child: GestureDetector(
            key: scaleKey,
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails details) =>
                _handlePosition(details.localPosition.dx, width),
            onHorizontalDragUpdate: (DragUpdateDetails details) =>
                _handlePosition(details.localPosition.dx, width),
            child: SizedBox(
              height: _rulerHeight,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ScaleTicksPainter(
                        stopCount: stops.length,
                        labeled: labels.keys.toSet(),
                        selectedIndex: selectedIndex,
                        accent: colorScheme.primary,
                        edgeInset: kScaleRulerEdgeInset,
                      ),
                    ),
                  ),
                  for (final MapEntry<int, String> label in labels.entries)
                    Positioned(
                      left:
                          (kScaleRulerEdgeInset +
                                  label.key / (stops.length - 1) * trackWidth -
                                  24)
                              .clamp(0.0, (width - 48).clamp(0.0, width)),
                      width: 48,
                      bottom: 24,
                      child: Text(
                        label.value,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: label.key == selectedIndex
                              ? colorScheme.primary
                              : Colors.white.withValues(alpha: 0.42),
                        ),
                      ),
                    ),
                  Positioned(
                    left: (kScaleRulerEdgeInset + ratio * trackWidth - 1).clamp(
                      0.0,
                      width - 2,
                    ),
                    bottom: 0,
                    width: 2,
                    height: 30,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (kScaleRulerEdgeInset + ratio * trackWidth - 4).clamp(
                      0.0,
                      width - 8,
                    ),
                    bottom: 34,
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScaleTicksPainter extends CustomPainter {
  const _ScaleTicksPainter({
    required this.stopCount,
    required this.labeled,
    required this.selectedIndex,
    required this.accent,
    required this.edgeInset,
  });

  final int stopCount;
  final Set<int> labeled;
  final int selectedIndex;
  final Color accent;
  final double edgeInset;

  @override
  void paint(Canvas canvas, Size size) {
    if (stopCount < 2 || size.width <= 0) {
      return;
    }
    final Paint paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final double trackWidth = (size.width - edgeInset * 2).clamp(
      1.0,
      size.width,
    );
    final double step = trackWidth / (stopCount - 1);
    for (int index = 0; index < stopCount; index += 1) {
      final bool selected = index == selectedIndex;
      final bool major = labeled.contains(index);
      final double height = selected ? 30 : (major ? 22 : 12);
      paint.color = selected
          ? accent
          : Colors.white.withValues(alpha: major ? 0.5 : 0.28);
      final double x = edgeInset + index * step;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScaleTicksPainter oldDelegate) {
    return oldDelegate.stopCount != stopCount ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.labeled != labeled ||
        oldDelegate.accent != accent ||
        oldDelegate.edgeInset != edgeInset;
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    this.rowKey,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final Key? rowKey;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return InkWell(
      key: rowKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}
