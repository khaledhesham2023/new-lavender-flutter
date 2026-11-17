import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lavender/core/network/api_client.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records the last request and answers with a canned JSON response.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.body, this.status);

  Object? body;
  int status;
  RequestOptions? last;

  String get method => last!.method;
  String get path => last!.path;
  Map<String, dynamic> get query => last!.queryParameters;
  dynamic get data => last!.data;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<(ApiClient, FakeAdapter)> makeApi({
  Object? body = const {'data': null, 'message': 'ok'},
  int status = 200,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = AppPrefs(await SharedPreferences.getInstance());
  final adapter = FakeAdapter(body, status);
  final dio = Dio()..httpClientAdapter = adapter;
  return (ApiClient(prefs, dio: dio, baseUrl: 'https://x.test/api/'), adapter);
}

const sampleUser = {'id': 5, 'name': 'Sara', 'phone': '555', 'token': 'tok'};
