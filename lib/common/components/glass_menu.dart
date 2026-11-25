import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class GlassMenuEntry<T> {
  const GlassMenuEntry({
    required this.value,
    required this.icon,
    required this.label,
    this.danger = false,
  });

  final T value;
  final IconData icon;
  final String label;
  final bool danger;
}

/// 锚定在控件附近的玻璃操作菜单，替代 [PopupMenuButton] 的实底菜单。
Future<T?> showGlassMenu<T>({
  required BuildContext context,
  required Offset globalPosition,
  required List<GlassMenuEntry<T>> entries,
  double width = 208,
  GlassTone tone = GlassTone.frost,
}) {
  if (entries.isEmpty) {
    return Future<T?>.value();
  }
  const double itemHeight = 46;
  final double height = entries.length * itemHeight + 16;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '操作菜单',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          final Size screen = MediaQuery.sizeOf(dialogContext);
          final double left = (globalPosition.dx - width + 12).clamp(
            12,
            screen.width - width - 12,
          );
          final bool openBelow =
              globalPosition.dy + 12 + height <= screen.height - 24;
          final double top = openBelow
              ? globalPosition.dy + 12
              : (globalPosition.dy - height - 12).clamp(
                  12,
                  screen.height - height - 12,
                );

          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: width,
                child: GlassPanel(
                  tone: tone == GlassTone.smoke ? GlassTone.smoke : null,
                  settings: tone == GlassTone.smoke
                      ? null
                      : appFrostGlassSettings(dialogContext),
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: 18,
                    side: BorderSide(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.outline.withValues(alpha: 0.18),
                      width: 0.8,
                    ),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Theme(
                      data: tone == GlassTone.smoke
                          ? glassSurfaceTheme(dialogContext)
                          : Theme.of(dialogContext),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (final GlassMenuEntry<T> entry in entries)
                              _GlassMenuItem<T>(
                                entry: entry,
                                onTap: () => Navigator.of(
                                  dialogContext,
                                ).pop(entry.value),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<double> curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              alignment: Alignment.topRight,
              child: child,
            ),
          );
        },
  );
}

class _GlassMenuItem<T> extends StatelessWidget {
  const _GlassMenuItem({required this.entry, required this.onTap});

  final GlassMenuEntry<T> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foreground = entry.danger
        ? colorScheme.error
        : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Icon(entry.icon, size: 20, color: foreground),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
