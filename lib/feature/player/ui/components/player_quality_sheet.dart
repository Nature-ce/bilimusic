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
    // 播放页是深色语境：挂上烟熏玻璃用的深色主题，文字/图标都从 colorScheme 取，
    // 这样换主题色或深浅模式时会跟着变。
    return Theme(
      data: glassSurfaceTheme(context),
      child: Builder(
        builder: (BuildContext sheetContext) {
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
                      _QualityOptionTile(option: option),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QualityOptionTile extends StatelessWidget {
  const _QualityOptionTile({required this.option});

  final AudioQualityOption option;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isSelected = option.isSelected;
    final BorderRadius borderRadius = BorderRadius.circular(AppRadius.lg);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.14)
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
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  )
                else
                  Icon(
                    Icons.play_arrow_rounded,
                    color: colorScheme.onSurfaceVariant,
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
