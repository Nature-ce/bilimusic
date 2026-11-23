import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection playback mappings carry collection context', () {
    final DateTime now = DateTime(2026);
    final FavoriteEntry entry = FavoriteEntry(
      itemId: 'bvid:BV1:cid:10',
      aid: 1,
      bvid: 'BV1',
      title: 'original title',
      author: 'UP',
      coverUrl: 'original cover',
      cid: 10,
      page: 2,
      pageTitle: 'part two',
      createdAt: now,
      updatedAt: now,
    );
    final FavoriteCollection collection = FavoriteCollection(
      id: 'collection',
      name: 'collection',
      createdAt: now,
      updatedAt: now,
    );
    final item = entry.toPlayableItem(collection: collection);
    expect(item.collectionId, collection.id);
    expect(item.stableId, entry.toPlayableItem().stableId);
    expect(item.contentId, entry.contentId);
    expect(item.title, entry.title);
    expect(item.coverUrl, entry.coverUrl);
    expect(item.page, 2);
    expect(item.pageTitle, 'part two');
  });
}
