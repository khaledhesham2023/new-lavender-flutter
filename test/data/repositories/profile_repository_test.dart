import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/enums/enums.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/about.dart';
import 'package:lavender/data/models/responses/report.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/data/repositories/profile_repository.dart';

import 'fake_api.dart';

void main() {
  test('getProfile → GET client/user, parses user', () async {
    final (api, a) = await makeApi(body: {'data': sampleUser});
    final r = await ProfileRepository(api).getProfile();
    expect(a.method, 'GET');
    expect(a.path, 'client/user');
    expect((r as ApiSuccess<UserModel>).data.name, 'Sara');
  });

  test('getProfile failure passes through', () async {
    final (api, _) = await makeApi(body: {'message': 'unauth'}, status: 401);
    final r = await ProfileRepository(api).getProfile();
    expect(r, isA<ServerFailure<UserModel>>());
    expect((r as ServerFailure).message, 'unauth');
  });

  test('updateProfile → POST update-profile with image', () async {
    final (api, a) = await makeApi(body: {'data': sampleUser});
    final r = await ProfileRepository(api)
        .updateProfile(const AuthRequest(fullName: 'Sara', image: 'a.png'));
    expect(a.method, 'POST');
    expect(a.path, 'client/user/update-profile');
    expect(a.data, {'full_name': 'Sara', 'image': 'a.png'});
    expect((r as ApiSuccess<UserModel?>).data?.id, 5);
  });

  test('updatePhone body', () async {
    final (api, a) = await makeApi();
    final r = await ProfileRepository(api).updatePhone('555', '966');
    expect(a.method, 'POST');
    expect(a.path, 'client/user/update-phone');
    expect(a.data, {'phone': '555', 'phone_code': '966'});
    expect(r, isA<ApiSuccess<void>>());
  });

  test('changeUserPassword body', () async {
    final (api, a) = await makeApi();
    await ProfileRepository(api).changeUserPassword(
      const AuthRequest(
        currentPassword: 'old',
        password: 'new',
        passwordConfirmation: 'new',
      ),
    );
    expect(a.path, 'client/user/change-password');
    expect(a.data, {
      'current_password': 'old',
      'password': 'new',
      'password_confirmation': 'new',
    });
  });

  test('deleteAccount → DELETE client/user', () async {
    final (api, a) = await makeApi();
    final r = await ProfileRepository(api).deleteAccount();
    expect(a.method, 'DELETE');
    expect(a.path, 'client/user');
    expect(r, isA<ApiSuccess<void>>());
  });

  test('contactUs uses query params and no body', () async {
    final (api, a) = await makeApi(body: {'message': 'thanks'});
    final r = await ProfileRepository(api)
        .contactUs(fullName: 'Sara', title: 'Hi', content: 'Hello');
    expect(a.method, 'POST');
    expect(a.path, 'client/contact');
    expect(a.query, {'full_name': 'Sara', 'title': 'Hi', 'content': 'Hello'});
    expect(a.data, isNull);
    expect((r as ApiSuccess<void>).message, 'thanks');
  });

  test('about pages hit their own paths and parse AboutModel', () async {
    final (api, a) = await makeApi(
      body: {
        'data': {'id': 1, 'name': '<p>x</p>'},
      },
    );
    final repo = ProfileRepository(api);
    final calls = {
      'client/about': repo.aboutUs,
      'client/about-app': repo.aboutApp,
      'client/term': repo.terms,
      'client/policy': repo.policy,
    };
    for (final e in calls.entries) {
      final r = await e.value();
      expect(a.method, 'GET');
      expect(a.path, e.key);
      expect((r as ApiSuccess<AboutModel>).data.name, '<p>x</p>');
    }
  });

  test('changeLang sends lang as query', () async {
    final (api, a) = await makeApi();
    await ProfileRepository(api).changeLang('en');
    expect(a.method, 'POST');
    expect(a.path, 'client/user/change-lang');
    expect(a.query, {'lang': 'en'});
    expect(a.data, isNull);
  });

  test('getReports sends type and parses days', () async {
    final (api, a) = await makeApi(
      body: {
        'data': [
          {
            'date': '2024-01-01',
            'reports': [
              {'id': 1, 'title': 'T'},
            ],
          },
        ],
      },
    );
    final r = await ProfileRepository(api).getReports(ReportType.laboratory);
    expect(a.method, 'GET');
    expect(a.path, 'client/my-reports');
    expect(a.query, {'type': 'laboratory'});
    final days = (r as ApiSuccess<List<DayReportsModel>>).data;
    expect(days.single.reports.single.id, 1);
  });

  test('getReports with empty or missing data returns []', () async {
    for (final body in [
      {'data': []},
      {'message': 'none'},
    ]) {
      final (api, _) = await makeApi(body: body);
      final r = await ProfileRepository(api).getReports(ReportType.radiology);
      expect(r, isA<ApiSuccess<List<DayReportsModel>>>());
      expect((r as ApiSuccess<List<DayReportsModel>>).data, isEmpty);
    }
  });
}
