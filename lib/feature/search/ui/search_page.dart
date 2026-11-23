import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/screen_util.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:bilimusic/feature/search/ui/components/search_input_area.dart';
import 'package:bilimusic/feature/search/ui/components/search_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) {
      return;
    }

    setState(() {});
    if (_focusNode.hasFocus) {
      ref
          .read(searchPageControllerProvider.notifier)
          .loadSuggestions(ref.read(searchPageControllerProvider).query);
    }
  }

  Future<void> _submitSearch(
    SearchPageController controller, [
    String? value,
  ]) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await controller.submitSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    final SearchState state = ref.watch(searchPageControllerProvider);
    final SearchPageController controller = ref.read(
      searchPageControllerProvider.notifier,
    );
    final bool isDesktop = ScreenUtil.shouldUseDesktopShell(context);
    final String trimmedQuery = state.query.trim();
    final bool isShowingSuggestions =
        !isDesktop && _focusNode.hasFocus && trimmedQuery.isNotEmpty;
    final bool shouldCloseSuggestions =
        isShowingSuggestions && state.submittedQuery?.isNotEmpty == true;

    _syncSearchText(state.query);

    return PopScope<Object?>(
      canPop: !shouldCloseSuggestions,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && shouldCloseSuggestions) {
          _focusNode.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              if (!isDesktop)
                SearchInputBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  query: state.query,
                  onChanged: controller.updateQuery,
                  onSubmitted: () => _submitSearch(controller),
                  onClear: () {
                    _controller.clear();
                    controller.clearQuery();
                  },
                ),
              Expanded(
                child:
                    !isShowingSuggestions &&
                        state.submittedQuery?.isNotEmpty == true
                    ? SearchResultsView(
                        state: state,
                        onLoadMore: controller.loadNextPage,
                        onChangeSort: controller.changeSort,
                        onPlayItem: (SearchResultItem item) async {
                          await PlayerUtil.playItemAndOpenPlayer(
                            context,
                            ref,
                            item: item.toPlayableItem(),
                            sourceLabel: '搜索结果',
                          );
                        },
                        onPlayNext: (SearchResultItem item) async {
                          final PlayableItem resolvedItem = await ref
                              .read(biliPlayerRepositoryProvider)
                              .resolvePreferredPart(
                                item.toPlayableItem(),
                                preferredPage: 1,
                              );
                          await ref
                              .read(playerControllerProvider.notifier)
                              .playNext(resolvedItem);
                        },
                        onEnqueue: (SearchResultItem item) async {
                          final PlayableItem resolvedItem = await ref
                              .read(biliPlayerRepositoryProvider)
                              .resolvePreferredPart(
                                item.toPlayableItem(),
                                preferredPage: 1,
                              );
                          await ref
                              .read(playerControllerProvider.notifier)
                              .enqueue(<PlayableItem>[resolvedItem]);
                        },
                        onTapUser: (SearchUserItem item) {
                          context.push('/up/${item.mid}');
                        },
                      )
                    : SearchIdleView(
                        isDesktop: isDesktop,
                        isShowingSuggestions: isShowingSuggestions,
                        query: trimmedQuery,
                        recentKeywords: state.recentKeywords,
                        suggestions: state.suggestions,
                        isLoadingSuggestions: state.isLoadingSuggestions,
                        onClearHistory: controller.clearHistory,
                        onSelectKeyword: (String value) {
                          _submitSearch(controller, value);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncSearchText(String query) {
    if (_controller.text == query) {
      return;
    }
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }
}
