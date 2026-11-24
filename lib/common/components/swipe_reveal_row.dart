import 'package:flutter/material.dart';

/// 管理「哪一行处于滑开状态」：同一时间只允许一行展开。
class SwipeRevealController extends ChangeNotifier {
  Object? _openId;

  Object? get openId => _openId;

  bool isOpen(Object id) => identical(_openId, id);

  void open(Object id) {
    if (identical(_openId, id)) {
      return;
    }
    _openId = id;
    notifyListeners();
  }

  void close([Object? id]) {
    if (id != null && !identical(_openId, id)) {
      return;
    }
    if (_openId == null) {
      return;
    }
    _openId = null;
    notifyListeners();
  }
}

/// 向左滑出操作按钮的行：滑开露出右侧按钮，点按钮执行操作，点行内容自动收起。
///
/// 传入 [controller] 后，展开某行会收起其它行；[SwipeRevealController.close]
/// 也能把当前展开的行收回去（例如点击空白处、开始滚动）。
class SwipeRevealRow extends StatefulWidget {
  const SwipeRevealRow({
    super.key,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.actionIcon = Icons.delete_outline_rounded,
    this.actionWidth = 88,
    this.backgroundColor,
    this.controller,
    this.revealId,
  });

  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData actionIcon;
  final double actionWidth;
  final Color? backgroundColor;
  final SwipeRevealController? controller;
  final Object? revealId;

  @override
  State<SwipeRevealRow> createState() => _SwipeRevealRowState();
}

class _SwipeRevealRowState extends State<SwipeRevealRow> {
  static const Duration _snapDuration = Duration(milliseconds: 180);

  double _offset = 0;
  double _target = 0;
  bool _dragging = false;

  late final Object _id = widget.revealId ?? this;

  bool get _isOpen => _target < 0;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SwipeRevealRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final SwipeRevealController? controller = widget.controller;
    if (controller == null || controller.isOpen(_id)) {
      return;
    }
    if (_target == 0 && !_dragging) {
      return;
    }
    setState(() {
      _dragging = false;
      _offset = 0;
      _target = 0;
    });
  }

  void _handleDragStart(DragStartDetails details) {
    widget.controller?.close(_id);
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
    if (shouldOpen) {
      widget.controller?.open(_id);
    } else {
      widget.controller?.close(_id);
    }
  }

  void _close() {
    if (!_isOpen) {
      return;
    }
    setState(() => _target = 0);
    widget.controller?.close(_id);
  }

  void _runAction() {
    _close();
    widget.onAction();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color background = widget.backgroundColor ?? colorScheme.surface;
    const double cardRadius = 14;
    const double gap = 8;

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
                top: 4,
                bottom: 4,
                right: gap,
                width: widget.actionWidth - gap,
                child: Material(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(cardRadius),
                  clipBehavior: Clip.antiAlias,
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
                child: Padding(
                  padding: const EdgeInsets.only(right: gap),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cardRadius),
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
                  ),
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
