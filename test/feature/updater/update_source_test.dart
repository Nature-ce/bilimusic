import 'dart:convert';
import 'dart:typed_data';

import 'package:bilimusic/feature/updater/data/update_repository.dart';
import 'package:bilimusic/feature/updater/domain/update_release.dart';
import 'package:bilimusic/feature/updater/domain/update_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _releaseBody(String tagName) {
  return ResponseBody.fromString(
    jsonEncode(<String, dynamic>{
      'tag_name': tagName,
      'name': 'bili-music $tagName',
      'body': '',
      'html_url':
          'https://github.com/Nature-ce/bilimusic/releases/tag/$tagName',
      'assets': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'bili-music-$tagName-arm64-v8a.apk',
          'browser_download_url': 'https://example.com/$tagName.apk',
          'size': 100,
        },
      ],
    }),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

Dio _dioWithHandler(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  return Dio(BaseOptions(responseType: ResponseType.json))
    ..httpClientAdapter = _FakeAdapter(handler);
}

void main() {
  test(
    'falls back to the upstream repository when the fork lookup fails',
    () async {
      final Dio dio = _dioWithHandler((RequestOptions options) async {
        if (options.uri.toString().contains(UpdateSource.fork.repo)) {
          return ResponseBody.fromString('not found', 404);
        }
        return _releaseBody('v9.9.9');
      });

      final UpdateRelease release = await UpdateRepository(
        dio: dio,
      ).fetchLatestRelease();

      expect(release.tagName, 'v9.9.9');
      expect(release.assets.single.name, 'bili-music-v9.9.9-arm64-v8a.apk');
    },
  );

  test('uses the fork release when it is reachable', () async {
    final List<String> requestedUrls = <String>[];
    final Dio dio = _dioWithHandler((RequestOptions options) async {
      requestedUrls.add(options.uri.toString());
      return _releaseBody('v1.14.0');
    });

    final UpdateRelease release = await UpdateRepository(
      dio: dio,
    ).fetchLatestRelease();

    expect(release.tagName, 'v1.14.0');
    expect(requestedUrls.single, contains(UpdateSource.fork.repo));
  });

  test('does not fall back when the upstream source is selected', () async {
    final List<String> requestedUrls = <String>[];
    final Dio dio = _dioWithHandler((RequestOptions options) async {
      requestedUrls.add(options.uri.toString());
      return ResponseBody.fromString('boom', 500);
    });

    await expectLater(
      UpdateRepository(
        dio: dio,
      ).fetchLatestRelease(source: UpdateSource.upstream),
      throwsA(isA<DioException>()),
    );
    expect(requestedUrls, hasLength(1));
    expect(requestedUrls.single, contains(UpdateSource.upstream.repo));
  });
}
