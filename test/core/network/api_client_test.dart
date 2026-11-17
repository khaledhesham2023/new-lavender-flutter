import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_client.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions o) respond;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? body,
      Future<void>? cancel) {
    last = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? body, int status) => ResponseBody.fromString(
      body is String ? body : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

Future<(ApiClient, _FakeAdapter)> _make(
  Future<ResponseBody> Function(RequestOptions o) respond, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = AppPrefs(await SharedPreferences.getInstance());
  final adapter = _FakeAdapter(respond);
  final dio = Dio()..httpClientAdapter = adapter;
  return (ApiClient(p, dio: dio, baseUrl: 'https://x.test/api/'), adapter);
}

void main() {
  test('headers without token', () async {
    final (c, a) = await _make((_) async => _json({'data': 1}, 200));
    await c.get<int>('a', parse: (j) => j['data'] as int);
    final h = a.last!.headers;
    expect(h['Accept'], 'application/json');
    expect(h['Content-Type'], 'application/json');
    expect(h['lang'], 'ar');
    expect(h['Accept-Language'], 'ar');
    expect(h['os'], 'android');
    expect(h['type'], 'android');
    expect(h.containsKey('Authorization'), false);
  });

  test('headers with token and language', () async {
    final (c, a) = await _make(
      (_) async => _json({'data': 1}, 200),
      prefs: {
        AppPrefs.keyBearerToken: 'Bearer abc',
        AppPrefs.keyLanguage: 'en',
      },
    );
    await c.get<int>('a', parse: (j) => 1);
    expect(a.last!.headers['Authorization'], 'Bearer abc');
    expect(a.last!.headers['lang'], 'en');
  });

  test('200 parses whole body and message', () async {
    final (c, _) = await _make(
        (_) async => _json({'data': 7, 'message': 'ok'}, 200));
    final r = await c.get<int>('a', parse: (j) => j['data'] as int);
    expect(r, isA<ApiSuccess<int>>());
    expect((r as ApiSuccess<int>).data, 7);
    expect(r.message, 'ok');
  });

  test('200 with null body -> UnknownFailure', () async {
    final (c, _) = await _make((_) async => _json('null', 200));
    expect(await c.get<int>('a', parse: (j) => 1), isA<UnknownFailure<int>>());
  });

  test('parse throwing -> UnknownFailure', () async {
    final (c, _) = await _make((_) async => _json({'a': 1}, 200));
    final r = await c.get<int>('a', parse: (j) => throw StateError('bad'));
    expect(r, isA<UnknownFailure<int>>());
  });

  test('422 -> ServerFailure', () async {
    final (c, _) =
        await _make((_) async => _json({'message': 'invalid'}, 422));
    final r = await c.post<void>('a', parse: (_) {});
    expect(r, isA<ServerFailure<void>>());
    expect((r as ServerFailure<void>).code, 422);
    expect(r.message, 'invalid');
  });

  test('500 html body -> UnknownFailure', () async {
    final (c, _) = await _make((_) async => ResponseBody.fromString(
          '<html>err</html>',
          500,
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        ));
    expect(await c.get<int>('a', parse: (j) => 1), isA<UnknownFailure<int>>());
  });

  test('timeout -> NetworkFailure', () async {
    final (c, _) = await _make((o) async => throw DioException(
        requestOptions: o, type: DioExceptionType.connectionTimeout));
    expect(await c.get<int>('a', parse: (j) => 1), isA<NetworkFailure<int>>());
  });

  test('null query values dropped', () async {
    final (c, a) = await _make((_) async => _json({}, 200));
    await c.get<int>('a', query: {'x': 1, 'y': null}, parse: (j) => 1);
    expect(a.last!.uri.queryParameters, {'x': '1'});
  });

  test('buildQuery keeps brackets and drops nulls', () {
    expect(
      buildQuery({'sub_specialty[0]': 3, 'gender': 'male', 'z': null}),
      'sub_specialty[0]=3&gender=male',
    );
    expect(buildQuery({'k': 'a b'}), 'k=a+b');
  });

  test('rawQuery is appended and decodes to bracketed keys', () async {
    final (c, a) = await _make((_) async => _json({}, 200));
    await c.get<int>('a',
        rawQuery: buildQuery({'sub_specialty[0]': 3}), parse: (j) => 1);
    // Dart's Uri may percent-encode brackets on the wire; servers decode them.
    expect(a.last!.uri.queryParameters, {'sub_specialty[0]': '3'});
  });
}
