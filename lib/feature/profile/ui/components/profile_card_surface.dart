import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

const double _cardRadius = 16;

BoxDecoration _cardDecoration(
  BuildContext context, {
  double radius = _cardRadius,
}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: appCardSurfaceColor(context),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      width: 1,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: appShadowColor(context),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class ProfileCardSurface extends StatelessWidget {
  const ProfileCardSurface({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPressStart,
    this.padding = EdgeInsets.zero,
    this.radius = _cardRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<LongPressStartDetails>? onLongPressStart;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: _cardDecoration(context, radius: radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onLongPressStart: onLongPressStart,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
