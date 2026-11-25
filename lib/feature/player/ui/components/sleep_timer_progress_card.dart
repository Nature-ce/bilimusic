import 'dart:async';

import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 睡眠定时进度卡：轨道 0~90 分钟，填充长度 = 剩余时间，画在节点上层。
///
/// 倒计时让填充从右往左缩，节点被填充边缘「切」掉，缩过去才整颗露出来。
class SleepTimerProgressCard extends ConsumerStatefulWidget {
  const SleepTimerProgressCard({super.key});

  @override
  ConsumerState<SleepTimerProgressCard> createState() =>
      _SleepTimerProgressCardState();
}

class _SleepTimerProgressCardState
    extends ConsumerState<SleepTimerProgressCard> {
  static const int maxMinutes = 90;
  static const List<int> nodeMinutes = <int>[0, 30, 60, 90];
  static const double _inset = 22;
  static const double _trackHeight = 46;
  static const double _nodeSize = 28;

  Timer? _ticker;
  int? _dragMinutes;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    // 每秒重建一次：剩余时间由 expiresAt - now 计算，天然跟着真实时钟走。
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_dragging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }

  Duration? _remainingOf(SleepTimerState timer) {
    final DateTime? expiresAt = timer.expiresAt;
    if (!timer.isActive || expiresAt == null) {
      return null;
    }
    final Duration left = expiresAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  int _minutesOf(Duration? left) {
    final int? drag = _dragMinutes;
    if (drag != null) {
      return drag;
    }
    if (left == null) {
      return 0;
    }
    return (left.inSeconds / 60).ceil().clamp(0, maxMinutes);
  }

  String _valueTextOf(Duration? left) {
    final int? drag = _dragMinutes;
    if (drag != null) {
      return drag <= 0 ? 'OFF' : '$drag 分';
    }
    if (left == null) {
      return 'OFF';
    }
    final int seconds = left.inSeconds.clamp(0, maxMinutes * 60);
    final String minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
    final String secondsPart = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesPart:$secondsPart';
  }

  void _updateDrag(double dx, double width) {
    final double usable = (width - _inset * 2).clamp(1.0, width);
    final double ratio = ((dx - _inset) / usable).clamp(0.0, 1.0);
    final int minutes = (ratio * maxMinutes).round();
    if (minutes != _dragMinutes) {
      setState(() => _dragMinutes = minutes);
    }
  }

  Future<void> _commitDrag() async {
    final int? minutes = _dragMinutes;
    if (minutes == null) {
      return;
    }
    setState(() => _dragMinutes = null);
    final SleepTimerController controller = ref.read(
      sleepTimerControllerProvider.notifier,
    );
    if (minutes <= 1) {
      controller.cancel();
      return;
    }
    controller.start(Duration(minutes: minutes));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SleepTimerState timer = ref.watch(sleepTimerControllerProvider);
    final Duration? remaining = _remainingOf(timer);
    final bool isActive = _dragMinutes != null || remaining != null;
    final int remainingMinutes = _minutesOf(remaining);

    return Semantics(
      label: isActive ? '睡眠定时剩余 ${_valueTextOf(remaining)}' : '睡眠定时未开启',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double usable = (width - _inset * 2).clamp(1.0, width);
          final double fillEnd =
              _inset + (remainingMinutes / maxMinutes) * usable;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '睡眠定时',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    _valueTextOf(remaining),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? colorScheme.primary
                          : Colors.white.withValues(alpha: 0.34),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                key: const Key('sleepTimerProgressTrack'),
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (DragStartDetails details) {
                  setState(() => _dragging = true);
                  _updateDrag(details.localPosition.dx, width);
                },
                onHorizontalDragUpdate: (DragUpdateDetails details) =>
                    _updateDrag(details.localPosition.dx, width),
                onHorizontalDragEnd: (DragEndDetails details) {
                  setState(() => _dragging = false);
                  _commitDrag();
                },
                onTapDown: (TapDownDetails details) =>
                    _updateDrag(details.localPosition.dx, width),
                onTapUp: (TapUpDetails details) => _commitDrag(),
                child: SizedBox(
                  height: _trackHeight + 20,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 20,
                        height: _trackHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // 每 5 分钟一条刻度（跳过 关/30/60/90 节点位置）：两个节点之间 5 条。
                      for (int minute = 5; minute < maxMinutes; minute += 5)
                        if (!nodeMinutes.contains(minute))
                          Positioned(
                            left: _inset + (minute / maxMinutes) * usable - 1,
                            top: 20 + (_trackHeight - 8) / 2,
                            width: 2,
                            height: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                      // 节点先画，填充后画：填充边缘会把节点切掉一部分。
                      for (final int minutes in nodeMinutes)
                        Positioned(
                          left:
                              _inset +
                              (minutes / maxMinutes) * usable -
                              _nodeSize / 2,
                          top: 20 + (_trackHeight - _nodeSize) / 2,
                          width: _nodeSize,
                          height: _nodeSize,
                          child: _SleepNode(
                            label: minutes == 0 ? '关' : '$minutes',
                            highlighted: isActive
                                ? minutes == remainingMinutes
                                : minutes == 0,
                            inactive: isActive && minutes != remainingMinutes,
                          ),
                        ),
                      // OFF 时不画填充：fillEnd 在 0 分钟时仍等于左侧留白。
                      if (isActive && fillEnd > 0)
                        Positioned(
                          left: 0,
                          top: 20,
                          width: fillEnd,
                          height: _trackHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      if (isActive)
                        Positioned(
                          left: (fillEnd - 1.5).clamp(0.0, width - 3),
                          top: 18,
                          width: 3,
                          height: _trackHeight + 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      if (_dragMinutes != null)
                        Positioned(
                          left: (fillEnd - 40).clamp(
                            0.0,
                            (width - 80).clamp(0.0, width),
                          ),
                          top: 0,
                          width: 80,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_dragMinutes!} 分',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SleepNode extends StatelessWidget {
  const _SleepNode({
    required this.label,
    required this.highlighted,
    required this.inactive,
  });

  final String label;
  final bool highlighted;
  final bool inactive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color borderColor = highlighted
        ? colorScheme.primary
        : Colors.white.withValues(alpha: inactive ? 0.16 : 0.3);
    final Color textColor = highlighted
        ? colorScheme.primary
        : Colors.white.withValues(alpha: inactive ? 0.4 : 0.78);
    final Color background = highlighted
        ? colorScheme.primary.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: highlighted ? 1.4 : 1),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
