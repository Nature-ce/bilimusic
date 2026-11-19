import 'dart:typed_data';

import 'package:bilimusic/core/cache/image_file_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.contentType});

  final String contentType;
  Map<String, dynamic>? lastHeaders;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastHeaders = options.headers;
    return ResponseBody.fromBytes(
      <int>[1, 2, 3],
      200,
      headers: <String, List<String>>{
        'content-type': <String>[contentType],
        'content-length': <String>['3'],
        'cache-control': <String>['public, max-age=600'],
        'etag': <String>['"abc"'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Setup {
  const _Setup({required this.service, required this.adapter});

  final ImageHttpFileService service;
  final _FakeAdapter adapter;
}

_Setup _createService({required String contentType}) {
  final Dio dio = Dio();
  final _FakeAdapter adapter = _FakeAdapter(contentType: contentType);
  dio.httpClientAdapter = adapter;
  return _Setup(
    service: ImageHttpFileService(dio: dio),
    adapter: adapter,
  );
}

void main() {
  test('sends a browser user agent so music CDNs do not reject it', () async {
    final _Setup setup = _createService(contentType: 'image/jpeg');

    await setup.service.get('https://p1.music.126.net/abc==/1.jpg');

    expect(setup.adapter.lastHeaders?['user-agent'], imageRequestUserAgent);
    expect(imageRequestUserAgent, contains('Mozilla/5.0'));
    expect(imageRequestUserAgent, isNot(contains('Dart')));
  });

  test('parses status, length, cache metadata and jpeg extension', () async {
    final _Setup setup = _createService(
      contentType: 'image/jpeg; charset=utf-8',
    );

    final FileServiceResponse response = await setup.service.get(
      'https://p1.music.126.net/abc==/1.jpg',
    );

    expect(response.statusCode, 200);
    expect(response.contentLength, 3);
    expect(response.fileExtension, '.jpg');
    expect(response.eTag, '"abc"');
    expect(response.validTill.isAfter(DateTime.now()), isTrue);
    expect(
      await response.content.expand((List<int> chunk) => chunk).toList(),
      <int>[1, 2, 3],
    );
  });

  test('derives the extension from content type or url', () async {
    final _Setup pngSetup = _createService(contentType: 'image/png');
    final FileServiceResponse png = await pngSetup.service.get(
      'https://example.com/a.bin',
    );
    expect(png.fileExtension, '.png');

    final _Setup unknownSetup = _createService(
      contentType: 'application/octet-stream',
    );
    final FileServiceResponse webp = await unknownSetup.service.get(
      'https://example.com/cover.webp?x=1',
    );
    expect(webp.fileExtension, '.webp');
  });
}
