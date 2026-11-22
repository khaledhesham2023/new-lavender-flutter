import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/features/profile/data/repositories/profile_repository_impl.dart';

import '../../../../data/repositories/fake_api.dart';

void main() {
  test('getProfile → GET client/user, parses user', () async {
    final (api, a) = await makeApi(body: {'data': sampleUser});
    final r = await ProfileRepositoryImpl(api).getProfile();
    expect(a.method, 'GET');
    expect(a.path, 'client/user');
    expect((r as ApiSuccess<UserModel>).data.name, 'Sara');
  });

  test('getProfile failure passes through', () async {
    final (api, _) = await makeApi(body: {'message': 'unauth'}, status: 401);
    final r = await ProfileRepositoryImpl(api).getProfile();
    expect(r, isA<ServerFailure<UserModel>>());
    expect((r as ServerFailure).message, 'unauth');
  });

  test('updateProfile → POST update-profile with image', () async {
    final (api, a) = await makeApi(body: {'data': sampleUser});
    final r = await ProfileRepositoryImpl(api)
        .updateProfile(const AuthRequest(fullName: 'Sara', image: 'a.png'));
    expect(a.method, 'POST');
    expect(a.path, 'client/user/update-profile');
    expect(a.data, {'full_name': 'Sara', 'image': 'a.png'});
    expect((r as ApiSuccess<UserModel?>).data?.id, 5);
  });

  test('updatePhone body', () async {
    final (api, a) = await makeApi();
    final r = await ProfileRepositoryImpl(api).updatePhone('555', '966');
    expect(a.method, 'POST');
    expect(a.path, 'client/user/update-phone');
    expect(a.data, {'phone': '555', 'phone_code': '966'});
    expect(r, isA<ApiSuccess<void>>());
  });

  test('changeUserPassword body', () async {
    final (api, a) = await makeApi();
    await ProfileRepositoryImpl(api).changeUserPassword(
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
    final r = await ProfileRepositoryImpl(api).deleteAccount();
    expect(a.method, 'DELETE');
    expect(a.path, 'client/user');
    expect(r, isA<ApiSuccess<void>>());
  });

  test('changeLang sends lang as query', () async {
    final (api, a) = await makeApi();
    await ProfileRepositoryImpl(api).changeLang('en');
    expect(a.method, 'POST');
    expect(a.path, 'client/user/change-lang');
    expect(a.query, {'lang': 'en'});
    expect(a.data, isNull);
  });
}
