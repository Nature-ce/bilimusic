import 'package:flutter/material.dart';

/// 跟手横滑的分页容器：手指水平移动多少，页面就平移多少，松手后按速度或
/// 距离吸附到上一页 / 下一页。
///
/// 没有用 [PageView]：它在吸附动画（ballistic activity）期间会给页面内容套上
/// IgnorePointer，刚切完页马上上下滑会被吞掉，表现为「滑不动、卡一下」。
/// 这里只做位移变换，任何时候都不拦截指针。
class PlayerPagePager extends StatefulWidget {
  const PlayerPagePager({
    super.key,
    required this.index,
    required this.pageCount,
    required this.onIndexChanged,
    required this.buildPage,
  });

  final int index;
  final int pageCount;
  final ValueChanged<int> onIndexChanged;
  final Widget Function(BuildContext context, int index) buildPage;

  @override
  State<PlayerPagePager> createState() => _PlayerPagePagerState();
}

class _PlayerPagePagerState extends State<PlayerPagePager>
    with SingleTickerProviderStateMixin {
  static const double _flingVelocity = 350;
  static const Duration _snapDuration = Duration(milliseconds: 280);

  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: _snapDuration,
  )..addListener(_handleSnapTick);

  final ValueNotifier<double> _position = ValueNotifier<double>(0);

  late Set<int> _built = <int>{widget.index};
  int _dragStartIndex = 0;
  double _snapFrom = 0;
  double _snapTo = 0;
  double _viewportWidth = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _position.value = widget.index.toDouble();
    _dragStartIndex = widget.index;
    _snap.addStatusListener(_handleSnapStatus);
  }

  @override
  void didUpdateWidget(covariant PlayerPagePager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && !_dragging && !_snap.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _dragging || _snap.isAnimating) {
          return;
        }
        _position.value = widget.index.toDouble();
        if (_built.length != 1 || !_built.contains(widget.index)) {
          setState(() => _built = <int>{widget.index});
        }
      });
    }
  }

  @override
  void dispose() {
    _snap.dispose();
    _position.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _snap.stop();
    _dragging = true;
    _dragStartIndex = widget.index;
    setState(() => _built = <int>{widget.index});
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _viewportWidth <= 0) {
      return;
    }
    final double previous = _position.value;
    final double next = (previous - details.delta.dx / _viewportWidth).clamp(
      0.0,
      (widget.pageCount - 1).toDouble(),
    );
    if (next == previous) {
      return;
    }
    _position.value = next;
    final int neighbor = next > previous
        ? _dragStartIndex + 1
        : _dragStartIndex - 1;
    if (neighbor >= 0 &&
        neighbor < widget.pageCount &&
        !_built.contains(neighbor)) {
      setState(() => _built = <int>{..._built, neighbor});
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    final double velocity = details.primaryVelocity ?? 0;
    final int target = velocity.abs() >= _flingVelocity
        ? _dragStartIndex + (velocity < 0 ? 1 : -1)
        : _position.value.round();
    _animateTo(target.clamp(0, widget.pageCount - 1));
  }

  void _handleDragCancel() {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    _animateTo(_position.value.round().clamp(0, widget.pageCount - 1));
  }

  void _animateTo(int target) {
    _snapFrom = _position.value;
    _snapTo = target.toDouble();
    if ((_snapTo - _snapFrom).abs() < 0.001) {
      _finishSnap(target);
      return;
    }
    _snap.forward(from: 0);
  }

  void _handleSnapTick() {
    _position.value =
        _snapFrom +
        (_snapTo - _snapFrom) * Curves.easeOutCubic.transform(_snap.value);
  }

  void _handleSnapStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _finishSnap(_snapTo.round());
    }
  }

  void _finishSnap(int target) {
    _snap.stop();
    _position.value = target.toDouble();
    if (_built.length != 1 || !_built.contains(target)) {
      setState(() => _built = <int>{target});
    }
    if (target != widget.index) {
      widget.onIndexChanged(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _viewportWidth = constraints.maxWidth;
        final List<int> pages = _built.toList()..sort();
        return ClipRect(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            onHorizontalDragCancel: _handleDragCancel,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                for (final int page in pages) _buildPage(page),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(int page) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _position,
        child: widget.buildPage(context, page),
        builder: (BuildContext context, Widget? child) {
          final double dx = (page - _position.value) * _viewportWidth;
          if (dx.abs() > _viewportWidth) {
            return const SizedBox.expand();
          }
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
      ),
    );
  }
}
