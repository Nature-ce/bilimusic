import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1test',
  title: '测试标题',
  author: '测试UP主',
  coverUrl: '',
  description: '这是一段简介',
);

Future<void> _pumpMetaPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const PlayerMetaSheet(state: PlayerState(), item: _item),
              PlayerStatsGrid(item: _item, activeColor: Colors.green),
              const PlayerDescriptionCard(description: '这是一段简介'),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('播放信息页三块卡片都换成灰白磨砂玻璃', (WidgetTester tester) async {
    await _pumpMetaPage(tester);

    expect(find.byType(GlassContainer), findsNWidgets(3));
    for (final GlassContainer glass in tester.widgetList<GlassContainer>(
      find.byType(GlassContainer),
    )) {
      expect(glass.settings?.glassColor, GlassTone.frost.settings.glassColor);
    }
  });

  testWidgets('玻璃卡片上的文字改成深色', (WidgetTester tester) async {
    await _pumpMetaPage(tester);

    for (final String label in <String>['播放信息', '简介']) {
      final Text text = tester.widget<Text>(find.text(label));
      expect(text.style?.color, GlassTone.frost.primaryText, reason: label);
    }

    for (final String label in <String>['UP主', '标题', '播放']) {
      final Text text = tester.widget<Text>(find.text(label));
      expect(text.style?.color, GlassTone.frost.secondaryText, reason: label);
    }

    final Text value = tester.widget<Text>(find.text('测试UP主'));
    expect(value.style?.color, GlassTone.frost.primaryText);
  });

  testWidgets('统计项仍然铺成两列网格', (WidgetTester tester) async {
    await _pumpMetaPage(tester);

    final Finder grid = find.byType(GridView);
    expect(grid, findsOneWidget);
    expect(
      tester.widget<GridView>(grid).gridDelegate,
      isA<SliverGridDelegateWithFixedCrossAxisCount>(),
    );
  });
}
