import 'package:bilimusic/common/components/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

VideoCard _card({required bool showPlayOverlay}) {
  return VideoCard(
    showPlayOverlay: showPlayOverlay,
    data: const VideoCardData(
      title: '测试视频',
      coverUrl: '',
      primaryMeta: 'UP主',
      secondaryMeta: '播放 1 万',
    ),
    onTap: () {},
  );
}

Future<void> _pump(WidgetTester tester, VideoCard card) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: Scaffold(body: card)),
    ),
  );
}

void main() {
  testWidgets('默认在封面左下角显示播放角标', (WidgetTester tester) async {
    await _pump(tester, _card(showPlayOverlay: true));

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('showPlayOverlay 关闭后不再显示播放角标', (WidgetTester tester) async {
    await _pump(tester, _card(showPlayOverlay: false));

    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.text('测试视频'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
