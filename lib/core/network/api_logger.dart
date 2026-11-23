import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';

class ApiLogger extends Interceptor {
  ApiLogger({void Function(String message)? sink})
    : _sink = sink ?? ((m) => dev.log(m, name: 'API'));

  final void Function(String message) _sink;

  static const _redactedKeys = {
    'password',
    'password_confirmation',
    'current_password',
    'authorization',
    'device_token',
    'token',
  };
  static const _startKey = 'api_log_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final o = options;
    o.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    _sink(
      [
        '--> ${o.method} ${o.uri}',
        'Headers: ${_pretty(o.headers)}',
        if (o.data != null) 'Body: ${_pretty(_bodyOf(o.data))}',
      ].join('\n'),
    );
    handler.next(o);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final r = response;
    _sink(
      [
        '<-- ${r.statusCode} ${r.requestOptions.method} ${r.requestOptions.uri} (${_ms(r.requestOptions)}ms)',
        'Response: ${_pretty(r.data)}',
      ].join('\n'),
    );
    handler.next(r);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final e = err;
    _sink(
      [
        '<-- ERROR ${e.type.name} ${e.requestOptions.method} ${e.requestOptions.uri} (${_ms(e.requestOptions)}ms)',
        if (e.message != null) 'Message: ${e.message}',
        if (e.response?.data != null) 'Response: ${_pretty(e.response!.data)}',
      ].join('\n'),
    );
    handler.next(e);
  }

  int _ms(RequestOptions o) {
    final start = o.extra[_startKey];
    return start is int ? DateTime.now().millisecondsSinceEpoch - start : -1;
  }

  dynamic _bodyOf(dynamic data) {
    if (data is FormData) {
      return {
        for (final f in data.fields) f.key: f.value,
        for (final f in data.files) f.key: '<file ${f.value.filename}>',
      };
    }
    return data;
  }

  String _pretty(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(_redact(data));
    } catch (_) {
      return '$data';
    }
  }

  dynamic _redact(dynamic v) {
    if (v is Map) {
      return {
        for (final e in v.entries)
          '${e.key}': _redactedKeys.contains('${e.key}'.toLowerCase())
              ? '***'
              : _redact(e.value),
      };
    }
    if (v is List) return v.map(_redact).toList();
    return v;
  }
}
