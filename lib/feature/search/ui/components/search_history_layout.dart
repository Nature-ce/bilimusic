/// 历史标签在限定行数内的排布结果。
class HistoryChipLayout {
  const HistoryChipLayout({
    required this.visibleCount,
    required this.collapsed,
  });

  /// 收起状态下可以完整展示的标签数量。
  final int visibleCount;

  /// 是否还有标签被收起来（需要「展开」入口）。
  final bool collapsed;
}

const double historyChipGap = 8;

/// 按标签宽度模拟换行，算出在 [maxLines] 行内能放下多少标签。
///
/// 收起时末尾还要塞一个「展开」按钮，所以 [toggleWidth] 会和最后一个标签一起参与排布。
/// 标签宽度由调用方用 TextPainter 量好传入，这里只做纯数学计算，方便单测。
HistoryChipLayout resolveHistoryChipLayout({
  required List<double> chipWidths,
  required double toggleWidth,
  required double maxWidth,
  required int maxLines,
  double gap = historyChipGap,
}) {
  final int total = chipWidths.length;
  if (total == 0) {
    return const HistoryChipLayout(visibleCount: 0, collapsed: false);
  }

  if (_packs(
    chipWidths: chipWidths,
    count: total,
    toggleWidth: null,
    maxWidth: maxWidth,
    maxLines: maxLines,
    gap: gap,
  )) {
    return HistoryChipLayout(visibleCount: total, collapsed: false);
  }

  for (int visible = total - 1; visible >= 1; visible--) {
    if (_packs(
      chipWidths: chipWidths,
      count: visible,
      toggleWidth: toggleWidth,
      maxWidth: maxWidth,
      maxLines: maxLines,
      gap: gap,
    )) {
      return HistoryChipLayout(visibleCount: visible, collapsed: true);
    }
  }

  return const HistoryChipLayout(visibleCount: 0, collapsed: true);
}

bool _packs({
  required List<double> chipWidths,
  required int count,
  required double? toggleWidth,
  required double maxWidth,
  required int maxLines,
  required double gap,
}) {
  if (maxWidth <= 0 || maxLines <= 0) {
    return false;
  }
  if (toggleWidth != null && toggleWidth > maxWidth) {
    return false;
  }

  double lineWidth = 0;
  int line = 1;

  for (int index = 0; index < count; index++) {
    final double width = chipWidths[index];
    if (width > maxWidth) {
      return false;
    }
    if (lineWidth == 0) {
      lineWidth = width;
    } else if (lineWidth + gap + width <= maxWidth) {
      lineWidth += gap + width;
    } else {
      line += 1;
      if (line > maxLines) {
        return false;
      }
      lineWidth = width;
    }
  }

  if (toggleWidth == null || lineWidth == 0) {
    return true;
  }
  if (lineWidth + gap + toggleWidth <= maxWidth) {
    return true;
  }

  return line + 1 <= maxLines;
}
