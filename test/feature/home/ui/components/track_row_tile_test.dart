import 'package:bilimusic/feature/home/ui/components/track_row_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('曲目行会把装饰字符还原成普通字符', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrackRowTile(
            rank: 1,
            title: '【𝐇𝐢-𝐑𝐞𝐬无损音质】🧡测试',
            artist: '𝐕𝐕音乐局',
            durationText: '03:21',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('【Hi-Res无损音质】测试'), findsOneWidget);
    expect(find.text('VV音乐局'), findsOneWidget);
    expect(find.textContaining('𝐇𝐢'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
