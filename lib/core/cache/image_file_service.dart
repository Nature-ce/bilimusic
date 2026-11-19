import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 部分音乐平台 CDN（例如网易云 `music.126.net`）会拒绝 Dart 默认 UA 并返回 403，
/// 拉取封面时统一带上浏览器 UA。
const String imageRequestUserAgent =
    'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

/// 带浏览器 UA 的图片下载服务，供 [AppImageCacheManager] 使用。
class ImageHttpFileService extends FileService {
  ImageHttpFileService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final Response<ResponseBody> response = await _dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: <String, String>{
          'user-agent': imageRequestUserAgent,
          ...?headers,
        },
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
    return _DioFileServiceResponse(response);
  }
}

class _DioFileServiceResponse implements FileServiceResponse {
  _DioFileServiceResponse(this._response);

  final Response<ResponseBody> _response;
  final DateTime _receivedTime = DateTime.now();

  @override
  Stream<List<int>> get content {
    return _response.data?.stream ?? const Stream<List<int>>.empty();
  }

  @override
  int? get contentLength {
    return _response.data?.contentLength ??
        int.tryParse(
          _response.headers.value(Headers.contentLengthHeader) ?? '',
        );
  }

  @override
  int get statusCode => _response.statusCode ?? 0;

  @override
  DateTime get validTill {
    Duration ageDuration = const Duration(days: 7);
    final String? controlHeader = _response.headers.value('cache-control');
    if (controlHeader != null) {
      for (final String setting in controlHeader.split(',')) {
        final String sanitized = setting.trim().toLowerCase();
        if (sanitized == 'no-cache') {
          ageDuration = Duration.zero;
        }
        if (sanitized.startsWith('max-age=')) {
          final int validSeconds = int.tryParse(sanitized.split('=')[1]) ?? 0;
          if (validSeconds > 0) {
            ageDuration = Duration(seconds: validSeconds);
          }
        }
      }
    }
    return _receivedTime.add(ageDuration);
  }

  @override
  String? get eTag => _response.headers.value('etag');

  @override
  String get fileExtension {
    final String contentType =
        _response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ?? '';
    if (contentType.contains('image/jpeg')) {
      return '.jpg';
    }
    if (contentType.contains('image/png')) {
      return '.png';
    }
    if (contentType.contains('image/webp')) {
      return '.webp';
    }
    if (contentType.contains('image/gif')) {
      return '.gif';
    }
    if (contentType.contains('image/avif')) {
      return '.avif';
    }
    final String path = _response.requestOptions.uri.path.toLowerCase();
    for (final String extension in <String>[
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
    ]) {
      if (path.endsWith(extension)) {
        return extension == '.jpeg' ? '.jpg' : extension;
      }
    }
    return '.jpg';
  }
}
