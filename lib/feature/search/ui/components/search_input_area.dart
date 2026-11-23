import 'dart:math' as math;

import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/search_bar.dart';
import 'package:bilimusic/core/theme/app_design.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/search/domain/hot_search_item.dart';
import 'package:bilimusic/feature/search/logic/hot_search_controller.dart';
import 'package:bilimusic/feature/search/ui/components/highlight_text.dart';
import 'package:bilimusic/feature/search/ui/components/hot_search_section.dart';
import 'package:bilimusic/feature/search/ui/components/search_history_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _historyChipFontSize = 13;
const double _historyChipHorizontalPadding = 14;
const double _historyChipVerticalPadding = 7;
const double _historyToggleIconSize = 15;
const double _historyToggleGap = 2;
const double _historyToggleHorizontalPadding = 12;
const int _historyMaxLines = 3;

const TextStyle _historyChipTextStyle = TextStyle(
  fontSize: _historyChipFontSize,
  height: 1.25,
  fontWeight: FontWeight.w500,
);

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: CommonSearchInput(
        controller: controller,
        focusNode: focusNode,
        query: query,
        hintText: '搜索歌曲、歌手或视频',
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onClear: onClear,
      ),
    );
  }
}

class SearchIdleView extends StatelessWidget {
  const SearchIdleView({
    super.key,
    required this.isDesktop,
    required this.isShowingSuggestions,
    required this.query,
    required this.recentKeywords,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.onClearHistory,
    required this.onSelectKeyword,
  });

  final bool isDesktop;
  final bool isShowingSuggestions;
  final String query;
  final List<String> recentKeywords;
  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            if (!isShowingSuggestions)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, isDesktop ? 16 : 6, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 720 : double.infinity,
                      ),
                      child: SearchPanel(
                        recentKeywords: recentKeywords,
                        onClearHistory: onClearHistory,
                        onSelectKeyword: onSelectKeyword,
                      ),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: BottomPageSpacer()),
          ],
        ),
        if (isShowingSuggestions)
          Positioned.fill(
            child: SearchSuggestionOverlay(
              query: query,
              suggestions: suggestions,
              isLoadingSuggestions: isLoadingSuggestions,
              onSelectSuggestion: onSelectKeyword,
            ),
          ),
      ],
    );
  }
}

/// 搜索历史与热搜共用的一张卡片。
class SearchPanel extends ConsumerWidget {
  const SearchPanel({
    super.key,
    required this.recentKeywords,
    required this.onClearHistory,
    required this.onSelectKeyword,
  });

  final List<String> recentKeywords;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HotSearchItem> hotItems = ref.watch(hotSearchProvider);
    final bool hasHistory = recentKeywords.isNotEmpty;
    final bool hasHot = hotItems.isNotEmpty;
    if (!hasHistory && !hasHot) {
      return const SizedBox.shrink();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: appElevatedCardDecoration(context, radius: AppRadius.lg),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (hasHistory)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: SearchHistorySection(
                  recentKeywords: recentKeywords,
                  onClearHistory: onClearHistory,
                  onSelectKeyword: onSelectKeyword,
                ),
              ),
            if (hasHistory && hasHot) ...<Widget>[
              const SizedBox(height: 14),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ],
            if (hasHot)
              Padding(
                padding: EdgeInsets.fromLTRB(14, hasHistory ? 12 : 14, 14, 8),
                child: HotSearchSection(
                  items: hotItems,
                  onSelectKeyword: onSelectKeyword,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.recentKeywords,
    required this.onClearHistory,
    required this.onSelectKeyword,
  });

  final List<String> recentKeywords;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('搜索历史', style: AppTextStyles.sectionTitleFrom(colorScheme)),
            const Spacer(),
            _ClearHistoryButton(onTap: onClearHistory),
          ],
        ),
        const SizedBox(height: 12),
        _HistoryChipWrap(keywords: recentKeywords, onTap: onSelectKeyword),
      ],
    );
  }
}

class _ClearHistoryButton extends StatelessWidget {
  const _ClearHistoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.delete_outline_rounded,
                size: 13,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '清空',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryChipWrap extends StatefulWidget {
  const _HistoryChipWrap({required this.keywords, required this.onTap});

  final List<String> keywords;
  final ValueChanged<String> onTap;

  @override
  State<_HistoryChipWrap> createState() => _HistoryChipWrapState();
}

class _HistoryChipWrapState extends State<_HistoryChipWrap> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = DefaultTextStyle.of(
      context,
    ).style.merge(_historyChipTextStyle);
    final int total = widget.keywords.length;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final List<double> chipWidths = <double>[
          for (final String keyword in widget.keywords)
            math.min(
              maxWidth,
              _measureTextWidth(context, baseStyle, keyword) +
                  _historyChipHorizontalPadding * 2,
            ),
        ];
        final double toggleWidth = math.min(
          maxWidth,
          _measureTextWidth(
                context,
                baseStyle.copyWith(fontWeight: FontWeight.w600),
                _toggleLabel(total),
              ) +
              _historyToggleHorizontalPadding * 2 +
              _historyToggleGap +
              _historyToggleIconSize,
        );
        final HistoryChipLayout layout = resolveHistoryChipLayout(
          chipWidths: chipWidths,
          toggleWidth: toggleWidth,
          maxWidth: maxWidth,
          maxLines: _historyMaxLines,
          gap: historyChipGap,
        );
        final bool showToggle = layout.collapsed;
        final int visibleCount = showToggle && !_expanded
            ? layout.visibleCount
            : total;

        return Wrap(
          spacing: historyChipGap,
          runSpacing: historyChipGap,
          children: <Widget>[
            for (int index = 0; index < visibleCount; index++)
              _SearchHistoryChip(
                keyword: widget.keywords[index],
                onTap: () => widget.onTap(widget.keywords[index]),
              ),
            if (showToggle)
              _HistoryToggleChip(
                expanded: _expanded,
                total: total,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
          ],
        );
      },
    );
  }

  String _toggleLabel(int total) {
    return _expanded ? '收起' : '展开全部 $total 条';
  }

  double _measureTextWidth(BuildContext context, TextStyle style, String text) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout();
    final double width = painter.width;
    painter.dispose();
    return width;
  }
}

class _SearchHistoryChip extends StatelessWidget {
  const _SearchHistoryChip({required this.keyword, required this.onTap});

  final String keyword;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: appSurfaceContainerColor(context, alpha: 0.6),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _historyChipHorizontalPadding,
            vertical: _historyChipVerticalPadding,
          ),
          child: Text(
            keyword,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _historyChipTextStyle.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _HistoryToggleChip extends StatelessWidget {
  const _HistoryToggleChip({
    required this.expanded,
    required this.total,
    required this.onTap,
  });

  final bool expanded;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary.withValues(alpha: 0.1),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _historyToggleHorizontalPadding,
            vertical: _historyChipVerticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                expanded ? '收起' : '展开全部 $total 条',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _historyChipTextStyle.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: _historyToggleGap),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: _historyToggleIconSize,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchSuggestionOverlay extends StatelessWidget {
  const SearchSuggestionOverlay({
    super.key,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.query,
    required this.onSelectSuggestion,
  });

  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final String query;
  final ValueChanged<String> onSelectSuggestion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: Column(
        children: <Widget>[
          if (isLoadingSuggestions && suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '正在获取联想词',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: suggestions.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1,
                  indent: 14,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final String suggestion = suggestions[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelectSuggestion(suggestion),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: HighlightText(
                              text: suggestion,
                              highlight: query,
                              normalStyle: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                              highlightStyle: theme.textTheme.bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
