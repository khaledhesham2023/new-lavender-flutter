import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/setting.dart';
import 'package:lavender/data/repositories/general_repository.dart';

import 'fake_api.dart';

void main() {
  test('uploadImage posts multipart "file" with query, returns data', () async {
    final dir = Directory.systemTemp.createTempSync('t08_');
    addTearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows may still hold the multipart file handle.
      }
    });
    final file = File('${dir.path}/pic.png')..writeAsBytesSync([1, 2, 3]);

    final (api, a) = await makeApi(body: {'data': 'stored/pic.png'});
    final r = await GeneralRepository(api).uploadImage(file.path);

    expect(a.method, 'POST');
    expect(a.path, 'general/attachments');
    expect(a.query, {'model': 'users', 'attachment_type': 'image'});
    final form = a.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'pic.png');
    expect((r as ApiSuccess<String>).data, 'stored/pic.png');
  });

  test('uploadImage failure passes through', () async {
    final (api, _) = await makeApi(body: {'message': 'big'}, status: 422);
    final r = await GeneralRepository(api).uploadImage('missing.png');
    // A missing file never reaches the server; either way it is a failure.
    expect(r, isA<ApiFailure<String>>());
  });

  test('uploadImage server error passes through', () async {
    final dir = Directory.systemTemp.createTempSync('t08_');
    addTearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows may still hold the multipart file handle.
      }
    });
    final file = File('${dir.path}/pic.png')..writeAsBytesSync([1]);
    final (api, _) = await makeApi(body: {'message': 'big'}, status: 422);
    final r = await GeneralRepository(api).uploadImage(file.path);
    expect(r, isA<ServerFailure<String>>());
    expect((r as ServerFailure).message, 'big');
  });

  test('getSettings → GET general/settings', () async {
    final (api, a) = await makeApi(
      body: {
        'data': {'allow_notification': 1, 'whats_app_number': '123'},
      },
    );
    final r = await GeneralRepository(api).getSettings();
    expect(a.method, 'GET');
    expect(a.path, 'general/settings');
    final s = (r as ApiSuccess<SettingModel>).data;
    expect(s.allowNotification, true);
    expect(s.whatsAppNumber, '123');
  });

  test('getSettings failure passes through', () async {
    final (api, _) = await makeApi(body: {'message': 'x'}, status: 500);
    final r = await GeneralRepository(api).getSettings();
    expect(r, isA<ServerFailure<SettingModel>>());
  });
}
