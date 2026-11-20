import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:flutter/material.dart';

/// 弹出音质选择弹层，返回用户选中的 qualityId（未选择则返回 null）。
Future<int?> showPlayerQualitySheet({
  required BuildContext context,
  required List<AudioQualityOption> qualities,
}) {
  if (qualities.isEmpty) {
    return Future<int?>.value();
  }

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (BuildContext context) {
      return PlayerQualitySheet(qualities: qualities);
    },
  );
}

class PlayerQualitySheet extends StatelessWidget {
  const PlayerQualitySheet({super.key, required this.qualities});

  final List<AudioQualityOption> qualities;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.primary;

    return GlassSheetPanel(
      tone: GlassTone.smoke,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final AudioQualityOption option in qualities)
                _QualityOptionTile(option: option, accentColor: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityOptionTile extends StatelessWidget {
  const _QualityOptionTile({required this.option, required this.accentColor});

  final AudioQualityOption option;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isSelected = option.isSelected;
    final BorderRadius borderRadius = BorderRadius.circular(AppRadius.lg);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Material(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => Navigator.of(context).pop(option.qualityId),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: GlassTone.smoke.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isSelected)
                  Icon(Icons.check_rounded, color: accentColor, size: 22)
                else
                  Icon(
                    Icons.play_arrow_rounded,
                    color: GlassTone.smoke.secondaryText,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
