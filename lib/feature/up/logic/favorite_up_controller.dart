import 'package:bilimusic/feature/up/data/favorite_up_local_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_up_controller.g.dart';

@Riverpod(keepAlive: true)
class FavoriteUpController extends _$FavoriteUpController {
  late final FavoriteUpLocalRepository _repository = ref.read(
    favoriteUpLocalRepositoryProvider,
  );

  @override
  List<FavoriteUp> build() {
    return _repository.load();
  }

  Future<void> initialize() async {
    state = _repository.load();
  }

  bool isFavorited(int mid) {
    return state.any((FavoriteUp up) => up.mid == mid);
  }

  /// 按「mid 或 名字+头像」判断，兼容历史脏数据里 mid 对不上的记录。
  bool isProfileFavorited(UpProfile profile) {
    final String identity = favoriteUpIdentityKey(
      name: profile.name,
      avatarUrl: profile.avatarUrl,
    );
    return state.any(
      (FavoriteUp up) =>
          up.mid == profile.mid ||
          favoriteUpIdentityKey(name: up.name, avatarUrl: up.avatarUrl) ==
              identity ||
          (profile.name.trim().isNotEmpty &&
              up.name.trim() == profile.name.trim()),
    );
  }

  Future<bool> toggle(UpProfile profile) async {
    final FavoriteUp? previous = _repository.find(
      profile.mid,
      profile: profile,
    );
    if (previous != null) {
      // 把指向同一个 UP 的记录一次删干净：历史脏数据里 mid / 头像可能都对不上。
      await _repository.deleteMatching(mid: profile.mid, name: profile.name);
      await _repository.deleteMatching(mid: previous.mid, name: previous.name);
      state = await _repository.delete(previous.mid);
      return false;
    }

    state = await _repository.save(FavoriteUp.fromProfile(profile));
    return true;
  }

  Future<void> remove(int mid) async {
    state = await _repository.delete(mid);
  }
}
