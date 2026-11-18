import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_logger.dart';

void main() {
  test('logs request and response and redacts secrets', () async {
    final logs = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/'))
      ..interceptors.add(ApiLogger(sink: logs.add))
      ..httpClientAdapter = _FakeAdapter();

    await dio.post<dynamic>(
      'login',
      data: {'phone': '512345678', 'password': 'secret1'},
      options: Options(headers: {'Authorization': 'Bearer abc'}),
    );

    final all = logs.join('\n');
    expect(all, contains('--> POST https://example.com/login'));
    expect(all, contains('<-- 200 POST https://example.com/login'));
    expect(all, contains('512345678'));
    expect(all, isNot(contains('secret1')));
    expect(all, isNot(contains('Bearer abc')));
    expect(all, isNot(contains('tok-123')));
    expect(all, contains('ok'));
  });
}

class _FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"message":"ok","token":"tok-123"}',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  @override
  void close({bool force = false}) {}
}
