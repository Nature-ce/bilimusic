import 'package:bilimusic/common/components/page_app_bar.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/display/player_chapter_marker_style_logic.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_markers.dart';
import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressBarSettingsPage extends ConsumerWidget {
  const ProgressBarSettingsPage({super.key});

  static const List<PlaybackChapter> _previewChapters = <PlaybackChapter>[
    PlaybackChapter(start: Duration.zero, title: ''),
    PlaybackChapter(start: Duration(seconds: 25), title: ''),
    PlaybackChapter(start: Duration(seconds: 50), title: ''),
    PlaybackChapter(start: Duration(seconds: 75), title: ''),
  ];
  static const Duration _previewTotal = Duration(seconds: 100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerChapterMarkerStyle style = ref.watch(
      playerChapterMarkerStyleLogicProvider,
    );

    return Scaffold(
      appBar: PageAppBar(title: const Text('进度条设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: <Widget>[
          SettingsGroup(
            title: '章节分隔样式',
            children: <Widget>[
              for (final PlayerChapterMarkerStyle option
                  in PlayerChapterMarkerStyle.values)
                SettingsRadioTile(
                  icon: _styleIcon(option),
                  tint: _styleTint(option),
                  title: option.label,
                  subtitle: option.description,
                  selected: style == option,
                  onTap: () {
                    ref
                        .read(playerChapterMarkerStyleLogicProvider.notifier)
                        .setStyle(option);
                  },
                ),
            ],
          ),
          const SettingsSectionLabel('预览'),
          _PreviewCard(style: style),
          const SettingsSectionLabel('说明'),
          SettingsInfoNote(text: '章节来自分 P 或视频内置章节。拖动进度条时，章节刻度会轻微放大提示可跳转。'),
        ],
      ),
    );
  }

  IconData _styleIcon(PlayerChapterMarkerStyle style) {
    return switch (style) {
      PlayerChapterMarkerStyle.line => Icons.vertical_align_center_rounded,
      PlayerChapterMarkerStyle.dot => Icons.fiber_manual_record_rounded,
    };
  }

  SettingsTint _styleTint(PlayerChapterMarkerStyle style) {
    return switch (style) {
      PlayerChapterMarkerStyle.line => SettingsTint.green,
      PlayerChapterMarkerStyle.dot => SettingsTint.blue,
    };
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.style});

  final PlayerChapterMarkerStyle style;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final int chapterCount =
        ProgressBarSettingsPage._previewChapters.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        color: appCardSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.38,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ChapterMarkers(
                      chapters: ProgressBarSettingsPage._previewChapters,
                      total: ProgressBarSettingsPage._previewTotal,
                      style: style,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _LegendText('00:00'),
              _LegendText('章节 $chapterCount 段'),
              _LegendText(
                _formatDuration(ProgressBarSettingsPage._previewTotal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _LegendText extends StatelessWidget {
  const _LegendText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
