import 'package:bilimusic/core/theme/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('motion tokens stay ordered and use content-aware curves', () {
    expect(
      AppMotion.fast.inMilliseconds,
      lessThan(AppMotion.base.inMilliseconds),
    );
    expect(
      AppMotion.base.inMilliseconds,
      lessThan(AppMotion.slow.inMilliseconds),
    );
    expect(AppMotion.standard, isNot(AppMotion.emphasized));
  });

  testWidgets('motion resolves to zero when the system disables animations', (
    WidgetTester tester,
  ) async {
    late Duration normal;
    late Duration reduced;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            normal = AppMotion.resolve(context, AppMotion.slow);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(normal, AppMotion.slow);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              reduced = AppMotion.resolve(context, AppMotion.slow);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(reduced, Duration.zero);
  });

  test('meta text never drops below the 12px readable floor', () {
    final ThemeData theme = ThemeData.light();
    expect(AppTextStyles.meta(theme).fontSize, greaterThanOrEqualTo(12));
    expect(AppTextStyles.listTitle(theme).fontSize, greaterThanOrEqualTo(12));
    expect(
      AppTextStyles.sectionTitle(theme).fontSize,
      greaterThanOrEqualTo(14),
    );
    expect(AppTextStyles.pageTitle(theme).fontSize, greaterThanOrEqualTo(18));
  });

  test('icon tap targets meet the 44dp mobile floor', () {
    expect(AppSizes.minIconTapTarget, greaterThanOrEqualTo(44));
    expect(AppSizes.minTapTarget, greaterThanOrEqualTo(44));
  });
}
