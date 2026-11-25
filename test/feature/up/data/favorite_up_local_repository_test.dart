import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/up/data/favorite_up_local_repository.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

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

UpProfile _profile({
  int mid = 777,
  String name = '影视飓风法务部',
  String avatarUrl = 'https://i0.hdslb.com/a.jpg@240w_240h',
}) {
  return UpProfile(
    mid: mid,
    name: name,
    avatarUrl: avatarUrl,
    followerCount: 17000,
  );
}

void main() {
  late Directory directory;
  late Box<FavoriteUp> box;
  late FavoriteUpLocalRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('favorite_up_repo_test');
    Hive.init(directory.path);
    final FavoriteUpAdapter adapter = FavoriteUpAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
    box = await Hive.openBox<FavoriteUp>(favoriteUpsBoxName);
    repository = FavoriteUpLocalRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('自增 key 写入的旧记录也能按 mid 找到', () async {
    await box.add(_up(mid: 777));

    final FavoriteUp? found = repository.find(777);

    expect(found, isNotNull);
    expect(found!.mid, 777);
  });

  test('头像 URL 参数不同时按名字兜底命中', () async {
    await box.put(777, _up(mid: 777));

    final FavoriteUp? found = repository.find(
      777,
      profile: _profile(avatarUrl: 'https://i0.hdslb.com/b.jpg'),
    );

    expect(found, isNotNull);
    expect(found!.name, '影视飓风法务部');
  });

  test('删除按记录存在性而不是 key，脏数据也能删掉', () async {
    await box.add(_up(mid: 777));
    await box.put(9, _up(mid: 9, name: '别的 UP 主'));

    final int removed = await repository.deleteMatching(
      mid: 777,
      name: '影视飓风法务部',
    );

    expect(removed, 1);
    expect(repository.load().map((FavoriteUp up) => up.name), <String>[
      '别的 UP 主',
    ]);
  });

  test('保存同名记录时不会再多存一份', () async {
    await box.add(_up(mid: 777));

    await repository.save(
      _up(
        mid: 888,
        avatarUrl: 'https://i0.hdslb.com/c.jpg',
        favoritedAtEpochMs: 5000,
      ),
    );

    final List<FavoriteUp> loaded = repository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.mid, 888);
  });
}
