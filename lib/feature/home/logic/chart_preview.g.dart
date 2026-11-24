// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_preview.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 榜单本身没有封面图，用榜单里第 1 首有效封面顶替。
///
/// `fetchTracks` 有内存缓存，网格是懒加载的，滑到哪张才请求哪张榜单，
/// 之后进入榜单详情还能直接复用这份缓存。

@ProviderFor(chartPreviewCover)
final chartPreviewCoverProvider = ChartPreviewCoverFamily._();

/// 榜单本身没有封面图，用榜单里第 1 首有效封面顶替。
///
/// `fetchTracks` 有内存缓存，网格是懒加载的，滑到哪张才请求哪张榜单，
/// 之后进入榜单详情还能直接复用这份缓存。

final class ChartPreviewCoverProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 榜单本身没有封面图，用榜单里第 1 首有效封面顶替。
  ///
  /// `fetchTracks` 有内存缓存，网格是懒加载的，滑到哪张才请求哪张榜单，
  /// 之后进入榜单详情还能直接复用这份缓存。
  ChartPreviewCoverProvider._({
    required ChartPreviewCoverFamily super.from,
    required MusicChart super.argument,
  }) : super(
         retry: null,
         name: r'chartPreviewCoverProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chartPreviewCoverHash();

  @override
  String toString() {
    return r'chartPreviewCoverProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as MusicChart;
    return chartPreviewCover(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChartPreviewCoverProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chartPreviewCoverHash() => r'5df00b1ab4060792eb6dd5a674f876396c3a0ac7';

/// 榜单本身没有封面图，用榜单里第 1 首有效封面顶替。
///
/// `fetchTracks` 有内存缓存，网格是懒加载的，滑到哪张才请求哪张榜单，
/// 之后进入榜单详情还能直接复用这份缓存。

final class ChartPreviewCoverFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, MusicChart> {
  ChartPreviewCoverFamily._()
    : super(
        retry: null,
        name: r'chartPreviewCoverProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// 榜单本身没有封面图，用榜单里第 1 首有效封面顶替。
  ///
  /// `fetchTracks` 有内存缓存，网格是懒加载的，滑到哪张才请求哪张榜单，
  /// 之后进入榜单详情还能直接复用这份缓存。

  ChartPreviewCoverProvider call(MusicChart chart) =>
      ChartPreviewCoverProvider._(argument: chart, from: this);

  @override
  String toString() => r'chartPreviewCoverProvider';
}
