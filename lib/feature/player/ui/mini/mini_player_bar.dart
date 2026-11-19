import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:flutter/material.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.state,
    required this.onTap,
    required this.onTogglePlayback,
  });

  final PlayerState state;
  final VoidCallback onTap;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: appShadowColor(context),
                blurRadius: 14,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: MiniPlayerContent(
            state: state,
            onTogglePlayback: onTogglePlayback,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 1,
            ),
          ),
        ),
      ),
    );
  }
}
