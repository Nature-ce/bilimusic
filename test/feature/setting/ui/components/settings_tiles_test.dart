import 'package:bilimusic/feature/setting/ui/components/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders grouped rows and forwards taps', (
    WidgetTester tester,
  ) async {
    int tapCount = 0;
    bool switchValue = false;
    String selectedVariant = 'green';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: <Widget>[
                  SettingsGroup(
                    title: '分组标题',
                    children: <Widget>[
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: '普通行',
                        subtitle: '行副标题',
                        value: '当前值',
                        onTap: () => tapCount += 1,
                      ),
                      SettingsSwitchTile(
                        icon: Icons.toggle_on_outlined,
                        title: '开关行',
                        value: switchValue,
                        onChanged: (bool value) {
                          setState(() {
                            switchValue = value;
                          });
                        },
                      ),
                      SettingsRadioTile(
                        title: '单选行',
                        selected: true,
                        onTap: () {},
                      ),
                      SettingsCheckTile(
                        title: '多选行',
                        value: '12 MB',
                        selected: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SettingsHighlightCard(
                    title: '共占用',
                    value: '158',
                    unit: 'MB',
                    footnote: '可随时清理',
                  ),
                  SettingsGroup(
                    title: '主题颜色',
                    children: <Widget>[
                      SettingsSwatchPicker(
                        options: const <SettingsSwatchOption>[
                          SettingsSwatchOption(
                            id: 'green',
                            label: '森林',
                            color: Color(0xFF2E7D5B),
                          ),
                          SettingsSwatchOption(
                            id: 'blue',
                            label: '海洋',
                            color: Color(0xFF2F5FB8),
                          ),
                        ],
                        selectedId: selectedVariant,
                        onSelected: (String id) {
                          setState(() {
                            selectedVariant = id;
                          });
                        },
                      ),
                    ],
                  ),
                  const SettingsKeycap(keys: <String>['Ctrl', '→']),
                  const SettingsKeycap(keys: <String>[]),
                  SettingsButtonRow(
                    children: <Widget>[
                      SettingsSecondaryButton(label: '测试连接', onPressed: () {}),
                      SettingsPrimaryButton(label: '保存配置', onPressed: () {}),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('分组标题'), findsOneWidget);
    expect(find.text('普通行'), findsOneWidget);
    expect(find.text('行副标题'), findsOneWidget);
    expect(find.text('当前值'), findsOneWidget);
    expect(find.text('共占用'), findsOneWidget);
    expect(find.text('158'), findsOneWidget);
    expect(find.text('可随时清理'), findsOneWidget);
    expect(find.text('Ctrl'), findsOneWidget);
    expect(find.text('→'), findsOneWidget);
    expect(find.text('未启用'), findsOneWidget);
    expect(find.text('测试连接'), findsOneWidget);
    expect(find.text('保存配置'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('普通行'));
    await tester.pump();
    expect(tapCount, 1);

    await tester.tap(find.text('开关行'));
    await tester.pump();
    expect(switchValue, isTrue);

    await tester.tap(find.text('海洋'));
    await tester.pump();
    expect(selectedVariant, 'blue');
  });

  testWidgets('primary button reports busy state and blocks taps', (
    WidgetTester tester,
  ) async {
    int presses = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              SettingsPrimaryButton(
                label: '清空缓存',
                onPressed: () => presses += 1,
              ),
              SettingsPrimaryButton(label: '清空中', onPressed: () {}, busy: true),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('清空缓存'));
    await tester.pump();
    expect(presses, 1);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
