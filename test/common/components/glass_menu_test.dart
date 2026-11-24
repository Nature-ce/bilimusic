import 'package:bilimusic/common/components/glass_menu.dart';
import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('玻璃菜单位于锚点附近，点击条目返回所选值', (WidgetTester tester) async {
    late Future<String?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: FilledButton(
                onPressed: () {
                  result = showGlassMenu<String>(
                    context: context,
                    globalPosition: const Offset(200, 300),
                    entries: const <GlassMenuEntry<String>>[
                      GlassMenuEntry<String>(
                        value: 'playNext',
                        icon: Icons.skip_next_rounded,
                        label: '下一首播放',
                      ),
                      GlassMenuEntry<String>(
                        value: 'enqueue',
                        icon: Icons.queue_music_rounded,
                        label: '加入队列',
                      ),
                    ],
                  );
                },
                child: const Text('打开菜单'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开菜单'));
    await tester.pumpAndSettle();

    expect(find.byType(GlassPanel), findsWidgets);
    // 和首页播放列表面板同一档白雾玻璃。
    final GlassContainer glass = tester.widget<GlassContainer>(
      find.byType(GlassContainer).first,
    );
    expect(
      glass.settings?.glassColor,
      appFrostGlassSettings(tester.element(find.text('下一首播放'))).glassColor,
    );
    expect(find.text('下一首播放'), findsOneWidget);
    expect(find.text('加入队列'), findsOneWidget);

    await tester.tap(find.text('加入队列'));
    await tester.pumpAndSettle();

    expect(await result, 'enqueue');
    expect(find.text('加入队列'), findsNothing);
  });

  testWidgets('条目为空时不弹菜单', (WidgetTester tester) async {
    late Future<String?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: FilledButton(
                onPressed: () {
                  result = showGlassMenu<String>(
                    context: context,
                    globalPosition: Offset.zero,
                    entries: const <GlassMenuEntry<String>>[],
                  );
                },
                child: const Text('打开菜单'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开菜单'));
    await tester.pumpAndSettle();

    expect(await result, isNull);
    expect(find.byType(GlassPanel), findsNothing);
  });

  testWidgets('危险条目使用错误色', (WidgetTester tester) async {
    late Future<String?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: FilledButton(
                onPressed: () {
                  result = showGlassMenu<String>(
                    context: context,
                    globalPosition: const Offset(160, 240),
                    entries: const <GlassMenuEntry<String>>[
                      GlassMenuEntry<String>(
                        value: 'delete',
                        icon: Icons.delete_outline_rounded,
                        label: '删除',
                        danger: true,
                      ),
                    ],
                  );
                },
                child: const Text('打开菜单'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开菜单'));
    await tester.pumpAndSettle();

    final Color errorColor = Theme.of(
      tester.element(find.text('删除')),
    ).colorScheme.error;
    final Icon icon = tester.widget<Icon>(
      find.byIcon(Icons.delete_outline_rounded),
    );
    expect(icon.color, errorColor);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(await result, 'delete');
  });
}
