import 'package:bilimusic/feature/up/data/favorite_up_local_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:flutter_test/flutter_test.dart';

FavoriteUp _up({
  required int mid,
  String name = '影视飓风法务部',
  String avatarUrl = 'https://i0.hdslb.com/a.jpg',
  int favoritedAtEpochMs = 1000,
}) {
  return FavoriteUp(
    mid: mid,
    name: name,
    avatarUrl: avatarUrl,
    favoritedAtEpochMs: favoritedAtEpochMs,
    updatedAtEpochMs: favoritedAtEpochMs,
  );
}

void main() {
  test('同一 UP 主存了两份时只保留最新的一条', () {
    final List<FavoriteUp> result = dedupeFavoriteUps(<FavoriteUp>[
      _up(mid: 7, favoritedAtEpochMs: 1000),
      _up(mid: 9, favoritedAtEpochMs: 2000),
    ]);

    expect(result.map((FavoriteUp up) => up.mid), <int>[9]);
  });

  test('同 mid 的重复记录也会被去掉', () {
    final List<FavoriteUp> result = dedupeFavoriteUps(<FavoriteUp>[
      _up(mid: 7, favoritedAtEpochMs: 1000),
      _up(mid: 7, favoritedAtEpochMs: 2000),
    ]);

    expect(result, hasLength(1));
    expect(result.single.favoritedAtEpochMs, 2000);
  });

  test('mid 无效的脏数据不显示', () {
    final List<FavoriteUp> result = dedupeFavoriteUps(<FavoriteUp>[
      _up(mid: 0),
      _up(mid: -3),
      _up(mid: 12),
    ]);

    expect(result.map((FavoriteUp up) => up.mid), <int>[12]);
  });

  test('不同 UP 主各留一条', () {
    final List<FavoriteUp> result = dedupeFavoriteUps(<FavoriteUp>[
      _up(mid: 1, name: '甲'),
      _up(mid: 2, name: '乙'),
      _up(mid: 3, name: '甲', favoritedAtEpochMs: 3000),
    ]);

    expect(result.map((FavoriteUp up) => up.mid), <int>[3, 2]);
  });
}
