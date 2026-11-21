import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';

import '../config/env.dart';
import '../push/device_info.dart';
import '../storage/app_prefs.dart';
import 'api_logger.dart';
import 'api_result.dart';
import 'lavender_api.dart';

typedef JsonParser<T> = T Function(dynamic json);

/// Single HTTP entry point. Holds the Dio setup (headers, timeouts, logging)
/// and the generated Retrofit [service]; [call] never throws: every outcome
/// is an [ApiResult].
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
    if (kDebugMode) _dio.interceptors.add(ApiLogger());
    service = LavenderApi(_dio);
  }

  static const _timeout = Duration(seconds: 30);

  final AppPrefs _prefs;
  final Dio _dio;

  /// The generated Retrofit interface with every endpoint.
  late final LavenderApi service;

  void _addHeaders(RequestOptions o, RequestInterceptorHandler handler) {
    final lang = _prefs.languageCode;
    o.headers['Accept'] = 'application/json';
    if (o.data is! FormData) o.headers['Content-Type'] = 'application/json';
    o.headers['lang'] = lang;
    o.headers['Accept-Language'] = lang;
    o.headers['os'] = deviceType;
    o.headers['type'] = deviceType;
    final token = _prefs.bearerToken;
    if (token != null) o.headers['Authorization'] = token;
    handler.next(o);
  }

  /// Runs one [service] call and maps the outcome:
  /// 2xx with a JSON object -> [ApiSuccess] (via [parse]); any other status ->
  /// [ServerFailure] when the body has a message map; connection problems ->
  /// [NetworkFailure]; everything else -> [UnknownFailure].
  Future<ApiResult<T>> call<T>(
    Future<HttpResponse<dynamic>> Function(LavenderApi api) request, {
    required JsonParser<T> parse,
  }) async {
    try {
      final res = (await request(service)).response;
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
