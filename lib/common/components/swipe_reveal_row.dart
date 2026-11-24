import 'package:flutter/material.dart';

/// 向左滑出操作按钮的行：滑开露出右侧按钮，点按钮执行操作，点行内容自动收起。
class SwipeRevealRow extends StatefulWidget {
  const SwipeRevealRow({
    super.key,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.actionIcon = Icons.delete_outline_rounded,
    this.actionWidth = 88,
    this.backgroundColor,
  });

  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData actionIcon;
  final double actionWidth;
  final Color? backgroundColor;

  @override
  State<SwipeRevealRow> createState() => _SwipeRevealRowState();
}

class _SwipeRevealRowState extends State<SwipeRevealRow> {
  static const Duration _snapDuration = Duration(milliseconds: 180);

  double _offset = 0;
  double _target = 0;
  bool _dragging = false;

  bool get _isOpen => _target < 0;

  void _handleDragStart(DragStartDetails details) {
    setState(() => _dragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(-widget.actionWidth, 0.0);
      _target = _offset;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    final bool shouldOpen = velocity < -220
        ? true
        : velocity > 220
        ? false
        : _offset.abs() > widget.actionWidth / 2;
    setState(() {
      _dragging = false;
      _target = shouldOpen ? -widget.actionWidth : 0;
    });
  }

  void _close() {
    if (!_isOpen) {
      return;
    }
    setState(() => _target = 0);
  }

  void _runAction() {
    _close();
    widget.onAction();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color background =
        widget.backgroundColor ?? theme.scaffoldBackgroundColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _offset, end: _target),
        duration: _dragging ? Duration.zero : _snapDuration,
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? child) {
          return Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: widget.actionWidth,
                child: Material(
                  color: colorScheme.error,
                  child: InkWell(
                    onTap: _runAction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          widget.actionIcon,
                          size: 20,
                          color: colorScheme.onError,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.actionLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(value, 0),
                child: Material(
                  color: background,
                  child: _isOpen
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _close,
                          child: child,
                        )
                      : child,
                ),
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
