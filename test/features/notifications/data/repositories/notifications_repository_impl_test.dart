import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:lavender/features/notifications/domain/entities/notifications_page.dart';

import '../../../../data/repositories/fake_api.dart';

void main() {
  test('getPage sends page and parses items + meta', () async {
    final (api, a) = await makeApi(
      body: {
        'data': [
          {'id': 'u1', 'title': 'A', 'is_readed': 0},
          {'id': 'u2', 'title': 'B', 'is_readed': 1},
        ],
        'meta': {'current_page': 2, 'last_page': 5},
      },
    );
    final r = await NotificationsRepositoryImpl(api).getPage(2);
    expect(a.method, 'GET');
    expect(a.path, 'client/notifications');
    expect(a.query, {'page': 2});
    final p = (r as ApiSuccess<NotificationsPage>).data;
    expect(p.items.map((e) => e.id), ['u1', 'u2']);
    expect(p.items.first.isReaded, false);
    expect(p.isLast, false);
    expect(p.lastPage, 5);
  });

  test('empty page is last; missing meta is fine', () async {
    final (api, _) = await makeApi(body: {'data': []});
    final r = await NotificationsRepositoryImpl(api).getPage(3);
    final p = (r as ApiSuccess<NotificationsPage>).data;
    expect(p.items, isEmpty);
    expect(p.isLast, true);
    expect(p.lastPage, isNull);
  });

  test('getPage failure passes through', () async {
    final (api, _) = await makeApi(body: {'message': 'no'}, status: 401);
    final r = await NotificationsRepositoryImpl(api).getPage(1);
    expect(r, isA<ServerFailure<NotificationsPage>>());
  });

  test('delete → DELETE client/notifications/{id}', () async {
    final (api, a) = await makeApi();
    final r = await NotificationsRepositoryImpl(api).delete('abc');
    expect(a.method, 'DELETE');
    expect(a.path, 'client/notifications/abc');
    expect(r, isA<ApiSuccess<void>>());
  });

  test('markRead → GET client/notifications/read/{id}', () async {
    final (api, a) = await makeApi();
    await NotificationsRepositoryImpl(api).markRead('abc');
    expect(a.method, 'GET');
    expect(a.path, 'client/notifications/read/abc');
  });

  test('readAll → GET client/notifications/read-all', () async {
    final (api, a) = await makeApi();
    await NotificationsRepositoryImpl(api).readAll();
    expect(a.method, 'GET');
    expect(a.path, 'client/notifications/read-all');
  });

  test('toggleAllow posts with _method=PUT and returns the flag', () async {
    final (api, a) = await makeApi(
      body: {
        'data': {'allow_notification': 1},
      },
    );
    final r = await NotificationsRepositoryImpl(api).toggleAllow();
    expect(a.method, 'POST');
    expect(a.path, 'client/user/allow-notifications');
    expect(a.query, {'_method': 'PUT'});
    expect((r as ApiSuccess<bool>).data, true);
  });

  test('toggleAllow false and failure', () async {
    final (api, _) = await makeApi(
      body: {
        'data': {'allow_notification': 0},
      },
    );
    final r = await NotificationsRepositoryImpl(api).toggleAllow();
    expect((r as ApiSuccess<bool>).data, false);

    final (api2, _) = await makeApi(body: {'message': 'x'}, status: 500);
    expect(
      await NotificationsRepositoryImpl(api2).toggleAllow(),
      isA<ServerFailure<bool>>(),
    );
  });
}
