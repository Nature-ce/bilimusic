import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/search/ui/components/highlight_text.dart';
import 'package:bilimusic/feature/search/ui/components/hot_search_section.dart';
import 'package:flutter/material.dart';

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onCancel,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final VoidCallback onCancel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasFocus = focusNode.hasFocus;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.only(left: 14, right: 4),
              decoration: BoxDecoration(
                color: appCardSurfaceColor(context),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colorScheme.primary.withValues(
                    alpha: hasFocus ? 0.72 : 0.42,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: colorScheme.primary,
                      textInputAction: TextInputAction.search,
                      onChanged: onChanged,
                      onSubmitted: (_) => onSubmitted(),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: '搜索歌曲、歌手或视频',
                        hintStyle: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.85,
                          ),
                        ),
                        filled: false,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),
                  if (query.isNotEmpty)
                    InkResponse(
                      onTap: onClear,
                      radius: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 17,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onCancel,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
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
    final bool hasHistory = recentKeywords.isNotEmpty;

    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            if (!isShowingSuggestions && hasHistory)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, isDesktop ? 16 : 6, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: SearchHistorySection(
                    recentKeywords: recentKeywords,
                    onClearHistory: onClearHistory,
                    onSelectKeyword: onSelectKeyword,
                  ),
                ),
              ),
            if (!isShowingSuggestions)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  isDesktop ? 20 : (hasHistory ? 22 : 8),
                  16,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: HotSearchSection(onSelectKeyword: onSelectKeyword),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '搜索历史',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onClearHistory,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  '清空',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentKeywords.map((String keyword) {
            return _SearchHistoryChip(
              keyword: keyword,
              onTap: () => onSelectKeyword(keyword),
            );
          }).toList(),
        ),
      ],
    );
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
      color: appSurfaceContainerColor(context, alpha: 0.5),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            keyword,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
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
