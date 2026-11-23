import 'package:bilimusic/feature/search/ui/components/search_history_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const double maxWidth = 328;
  const double toggleWidth = 120;

  HistoryChipLayout resolve(
    List<double> chipWidths, {
    int maxLines = 3,
    double width = maxWidth,
  }) {
    return resolveHistoryChipLayout(
      chipWidths: chipWidths,
      toggleWidth: toggleWidth,
      maxWidth: width,
      maxLines: maxLines,
    );
  }

  test('returns an empty layout for no keywords', () {
    final HistoryChipLayout layout = resolve(const <double>[]);

    expect(layout.visibleCount, 0);
    expect(layout.collapsed, isFalse);
  });

  test('keeps everything visible when the chips fit', () {
    final HistoryChipLayout layout = resolve(const <double>[80, 80, 80]);

    expect(layout.visibleCount, 3);
    expect(layout.collapsed, isFalse);
  });

  test('collapses the chips that overflow the third line', () {
    final List<double> widths = List<double>.filled(20, 80);

    final HistoryChipLayout layout = resolve(widths);

    expect(layout.collapsed, isTrue);
    expect(layout.visibleCount, lessThan(20));
    expect(layout.visibleCount, 8);
  });

  test('keeps nine chips visible when they fill three lines exactly', () {
    final HistoryChipLayout layout = resolve(List<double>.filled(9, 80));

    expect(layout.collapsed, isFalse);
    expect(layout.visibleCount, 9);
  });

  test('reserves room for the toggle chip on the last line', () {
    final HistoryChipLayout layout = resolve(List<double>.filled(10, 80));

    expect(layout.collapsed, isTrue);
    expect(layout.visibleCount, 8);
  });

  test('respects the line limit for narrow containers', () {
    final List<double> widths = List<double>.filled(6, 100);

    final HistoryChipLayout layout = resolve(widths, width: 120);

    expect(layout.collapsed, isTrue);
    expect(layout.visibleCount, 2);
  });

  test(
    'keeps a single clamped chip visible when it matches the line width',
    () {
      final HistoryChipLayout layout = resolve(const <double>[
        328,
        328,
        328,
        328,
      ]);

      expect(layout.collapsed, isTrue);
      expect(layout.visibleCount, 2);
    },
  );
}
