import 'package:bilimusic/feature/search/domain/hot_search_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hot_search_controller.g.dart';

@Riverpod(keepAlive: true)
class HotSearchController extends _$HotSearchController {
  @override
  Future<List<HotSearchItem>> build() {
    return ref.read(biliSearchRepositoryProvider).fetchHotSearch();
  }

  Future<void> retry() async {
    state = const AsyncLoading<List<HotSearchItem>>();
    state = await AsyncValue.guard<List<HotSearchItem>>(
      () => ref.read(biliSearchRepositoryProvider).fetchHotSearch(),
    );
  }
}
