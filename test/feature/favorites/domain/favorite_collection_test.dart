import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy collection JSON parses with local defaults', () {
    final FavoriteCollection collection =
        FavoriteCollection.fromJson(<String, dynamic>{
          'id': 'legacy',
          'name': '旧歌单',
          'createdAt': '2026-01-01T00:00:00.000',
          'updatedAt': '2026-01-01T00:00:00.000',
        });
    expect(collection.id, 'legacy');
    expect(collection.name, '旧歌单');
    expect(collection.isLocal, isTrue);
    expect(collection.isSystem, isFalse);
    expect(FavoriteCollection.liked().isSystem, isTrue);
  });

  test('contextualize assigns the target collection id', () {
    const PlayableItem source = PlayableItem(
      aid: 1,
      bvid: 'BV1',
      cid: 10,
      page: 2,
      title: 'Title',
      author: 'Author',
      coverUrl: 'Cover',
      collectionId: 'source',
    );
    final FavoriteEntry entry = FavoriteEntry.fromPlayableItem(source);
    final FavoriteCollection first = FavoriteCollection(
      id: 'first',
      name: 'First',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final FavoriteCollection second = first.copyWith(id: 'second');
    expect(first.contextualize(source), source.copyWith(collectionId: 'first'));
    final PlayableItem firstItem = entry.toPlayableItem(collection: first);
    final PlayableItem secondItem = entry.toPlayableItem(collection: second);
    expect(firstItem, first.contextualize(source));
    expect(secondItem, second.contextualize(source));
    expect(firstItem.collectionId, first.id);
    expect(secondItem.collectionId, second.id);
    expect(firstItem.stableId, source.stableId);
    expect(secondItem.contentId, source.contentId);
    expect(entry.toPlayableItem().collectionId, isNull);
  });

  test('collection JSON rounds trips and copies preserve fields', () {
    final FavoriteCollection collection = FavoriteCollection(
      id: 'remote:9',
      name: '听书',
      source: FavoriteCollectionSource.remote,
      remoteId: '9',
      coverUrl: 'https://example.com/cover.jpg',
      itemCount: 3,
      isManagedByApp: true,
      lastSyncedAt: DateTime(2026, 2, 3, 4, 5, 6),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026, 1, 2),
    );
    expect(FavoriteCollection.fromJson(collection.toJson()), collection);
    final FavoriteCollection renamed = collection.copyWith(name: '听声');
    expect(renamed.name, '听声');
    expect(renamed.id, collection.id);
    expect(renamed.remoteId, collection.remoteId);
    expect(renamed.coverUrl, collection.coverUrl);
    expect(renamed.itemCount, collection.itemCount);
    expect(renamed.isManagedByApp, isTrue);
    expect(renamed.lastSyncedAt, collection.lastSyncedAt);
    expect(renamed.createdAt, collection.createdAt);
  });
}
