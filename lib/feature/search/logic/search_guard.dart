import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_guard.g.dart';

/// B 站搜索接口的全局熔断状态。
///
/// 高频搜索会触发风控，此时接口对同一 IP 往往返回「成功但结果为空」，
/// 连普通搜索页都会显示「没有找到相关视频」。这里把状态集中起来：
/// 匹配器上报限流、搜索页据此给出明确提示，并统一冷却，避免继续硬搜。
@Riverpod(keepAlive: true)
class SearchGuard extends _$SearchGuard {
  DateTime? _cooldownUntil;

  @override
  Duration build() => Duration.zero;

  /// 当前是否还在冷却中；返回剩余时长，零表示可用。
  Duration get remaining {
    final DateTime? until = _cooldownUntil;
    if (until == null) {
      return Duration.zero;
    }
    final Duration left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  bool get isBlocked => remaining > Duration.zero;

  void markLimited(Duration cooldown) {
    final DateTime until = DateTime.now().add(cooldown);
    final DateTime? current = _cooldownUntil;
    if (current != null && current.isAfter(until)) {
      return;
    }
    _cooldownUntil = until;
    state = cooldown;
  }

  void markHealthy() {
    if (_cooldownUntil == null) {
      return;
    }
    _cooldownUntil = null;
    state = Duration.zero;
  }
}
