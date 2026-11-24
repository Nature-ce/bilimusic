String? relativeUpdatedLabel(DateTime? updatedAt, {DateTime? now}) {
  if (updatedAt == null) {
    return null;
  }
  final DateTime reference = now ?? DateTime.now();
  final DateTime today = DateTime(
    reference.year,
    reference.month,
    reference.day,
  );
  final DateTime updatedDay = DateTime(
    updatedAt.year,
    updatedAt.month,
    updatedAt.day,
  );
  final int days = today.difference(updatedDay).inDays;
  if (days <= 0) {
    return '今天更新';
  }
  if (days == 1) {
    return '昨天更新';
  }
  if (days < 7) {
    return '$days 天前';
  }
  return '${days ~/ 7} 周前';
}
