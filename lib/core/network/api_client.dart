import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../config/env.dart';
import '../storage/app_prefs.dart';
import 'api_result.dart';

typedef JsonParser<T> = T Function(dynamic json);

/// Encodes [q] as a query string: values are percent-encoded, keys are kept
/// as-is so `sub_specialty[0]` keeps its brackets. Null values are dropped.
String buildQuery(Map<String, Object?> q) => q.entries
    .where((e) => e.value != null)
    .map((e) => '${e.key}=${Uri.encodeQueryComponent('${e.value}')}')
    .join('&');

/// Single HTTP entry point. Never throws: every outcome is an [ApiResult].
class ApiClient {
  ApiClient(this._prefs, {Dio? dio, String? baseUrl}) : _dio = dio ?? Dio() {
    final base = baseUrl ?? Env.baseUrl;
    assert(base.isEmpty || base.endsWith('/'), 'baseUrl must end with "/"');
    _dio.options
      ..baseUrl = base
      ..connectTimeout = _timeout
      ..receiveTimeout = _timeout
      ..sendTimeout = _timeout
      ..responseType = ResponseType.json
      ..validateStatus = (_) => true;
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _addHeaders));
    if (kDebugMode) {
      _dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  static const _timeout = Duration(seconds: 30);

  final AppPrefs _prefs;
  final Dio _dio;

  void _addHeaders(RequestOptions o, RequestInterceptorHandler handler) {
    final lang = _prefs.languageCode;
    o.headers['Accept'] = 'application/json';
    if (o.data is! FormData) o.headers['Content-Type'] = 'application/json';
    o.headers['lang'] = lang;
    o.headers['Accept-Language'] = lang;
    o.headers['os'] = 'android';
    o.headers['type'] = 'android';
    final token = _prefs.bearerToken;
    if (token != null) o.headers['Authorization'] = token;
    handler.next(o);
  }

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    String? rawQuery,
    required JsonParser<T> parse,
  }) =>
      _handle(
        () => _dio.get<dynamic>(
          _withRaw(path, rawQuery),
          queryParameters: _clean(query),
        ),
        parse,
      );

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required JsonParser<T> parse,
  }) =>
      _handle(
        () => _dio.post<dynamic>(
          path,
          data: body,
          queryParameters: _clean(query),
        ),
        parse,
      );

  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    required JsonParser<T> parse,
  }) =>
      _handle(
        () => _dio.delete<dynamic>(path, queryParameters: _clean(query)),
        parse,
      );

  Future<ApiResult<T>> upload<T>(
    String path, {
    required String filePath,
    required String field,
    Map<String, dynamic>? query,
    required JsonParser<T> parse,
  }) =>
      _handle(() async {
        final form = FormData.fromMap({
          field: await MultipartFile.fromFile(
            filePath,
            filename: p.basename(filePath),
          ),
        });
        return _dio.post<dynamic>(
          path,
          data: form,
          queryParameters: _clean(query),
        );
      }, parse);

  static String _withRaw(String path, String? raw) =>
      (raw == null || raw.isEmpty) ? path : '$path?$raw';

  static Map<String, dynamic>? _clean(Map<String, dynamic>? q) =>
      q == null ? null : (Map.of(q)..removeWhere((_, v) => v == null));

  Future<ApiResult<T>> _handle<T>(
    Future<Response<dynamic>> Function() call,
    JsonParser<T> parse,
  ) async {
    try {
      final res = await call();
      final status = res.statusCode ?? 0;
      final body = res.data;
      if (status >= 200 && status < 300) {
        if (body is! Map) return const UnknownFailure();
        try {
          return ApiSuccess(
            parse(body),
            message: body['message']?.toString() ?? '',
          );
        } catch (e) {
          return UnknownFailure(e.toString());
        }
      }
      if (body is Map) {
        return ServerFailure(status, body['message']?.toString() ?? '');
      }
      return const UnknownFailure();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkFailure();
        case DioExceptionType.cancel:
          return const UnknownFailure('cancelled');
        default:
          return e.error is SocketException
              ? const NetworkFailure()
              : UnknownFailure(e.message ?? '');
      }
    } on SocketException {
      return const NetworkFailure();
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
