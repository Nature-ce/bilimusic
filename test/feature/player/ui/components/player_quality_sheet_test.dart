import 'package:bilimusic/common/components/glass_panel.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/ui/components/player_quality_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

const List<AudioQualityOption> _qualities = <AudioQualityOption>[
  AudioQualityOption(
    qualityId: 192000,
    bandwidth: 192000,
    label: '192K',
    isSelected: true,
  ),
  AudioQualityOption(qualityId: 132000, bandwidth: 132000, label: '132K'),
  AudioQualityOption(qualityId: 64000, bandwidth: 64000, label: '64K'),
];

class _SheetHarness {
  int? picked;
  bool requested = false;
}

Future<_SheetHarness> _pumpSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _SheetHarness harness = _SheetHarness();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: FilledButton(
                onPressed: () async {
                  harness.requested = true;
                  harness.picked = await showPlayerQualitySheet(
                    context: context,
                    qualities: _qualities,
                  );
                },
                child: const Text('打开音质'),
              ),
            );
          },
        ),
      ),
    ),
  );
  return harness;
}

void main() {
  testWidgets('音质弹层用烟熏黑玻璃 + 白色文字', (WidgetTester tester) async {
    await _pumpSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('打开音质'));
    await tester.pumpAndSettle();

    final GlassContainer glass = tester.widget<GlassContainer>(
      find.byType(GlassContainer).first,
    );
    expect(glass.settings?.glassColor, GlassTone.smoke.settings.glassColor);

    for (final String label in <String>['192K', '132K', '64K']) {
      final Text text = tester.widget<Text>(find.text(label));
      expect(text.style?.color, GlassTone.smoke.primaryText, reason: label);
    }

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNWidgets(2));
  });

  testWidgets('点音质选项回传对应 qualityId', (WidgetTester tester) async {
    final _SheetHarness harness = await _pumpSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('打开音质'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('132K'));
    await tester.pumpAndSettle();

    expect(harness.picked, 132000);
    expect(find.byType(GlassContainer), findsNothing);
  });

  testWidgets('没有音质可选时不弹层', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: FilledButton(
                  onPressed: () => showPlayerQualitySheet(
                    context: context,
                    qualities: const <AudioQualityOption>[],
                  ),
                  child: const Text('打开音质'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开音质'));
    await tester.pumpAndSettle();

    expect(find.byType(GlassContainer), findsNothing);
  });
}
