import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/data/repositories/auth_repository.dart';

import 'fake_api.dart';

void main() {
  const req = AuthRequest(phone: '555', password: 'pw', otp: '1234');

  final userEndpoints =
      <String, (String, Future<ApiResult<Object?>> Function(AuthRepository))>{
        'login': ('client/login', (r) => r.login(req)),
        'register': ('client/register', (r) => r.register(req)),
        'verifyPhone': ('client/verify', (r) => r.verifyPhone(req)),
        'resendCode': ('client/resend', (r) => r.resendCode(req)),
        'resetPassword': ('client/password/reset', (r) => r.resetPassword(req)),
        'verifyForgetPassword': (
          'client/password/verify',
          (r) => r.verifyForgetPassword(req),
        ),
        'verifyChangedPhone': (
          'client/user/verify',
          (r) => r.verifyChangedPhone(req),
        ),
      };

  for (final e in userEndpoints.entries) {
    group(e.key, () {
      test('POST ${e.value.$1}, body keys, parses user', () async {
        final (api, a) = await makeApi(
          body: {'data': sampleUser, 'message': 'done'},
        );
        final r = await e.value.$2(AuthRepository(api));
        expect(a.method, 'POST');
        expect(a.path, e.value.$1);
        expect(a.data, {'phone': '555', 'password': 'pw', 'otp': '1234'});
        expect(r, isA<ApiSuccess<Object?>>());
        final user = (r as ApiSuccess<Object?>).data as UserModel;
        expect(user.id, 5);
        expect(user.token, 'tok');
        expect(r.message, 'done');
      });

      test('failure passes through', () async {
        final (api, _) = await makeApi(body: {'message': 'bad'}, status: 422);
        final r = await e.value.$2(AuthRepository(api));
        expect(r, isA<ServerFailure<Object?>>());
        expect((r as ServerFailure).code, 422);
        expect(r.message, 'bad');
      });
    });
  }

  test('login with missing data is a failure, not a throw', () async {
    final (api, _) = await makeApi(body: {'message': 'x'});
    expect(await AuthRepository(api).login(req), isA<UnknownFailure>());
  });

  test('optional-user endpoints accept missing data', () async {
    final (api, _) = await makeApi(body: {'message': 'sent'});
    final r = await AuthRepository(api).resendCode(req);
    expect(r, isA<ApiSuccess<UserModel?>>());
    expect((r as ApiSuccess<UserModel?>).data, isNull);
    expect(r.message, 'sent');
  });

  test('register sends snake_case keys', () async {
    final (api, a) = await makeApi(body: {'data': sampleUser});
    await AuthRepository(api).register(
      const AuthRequest(
        fullName: 'Sara',
        phoneCode: '966',
        passwordConfirmation: 'pw',
        termsAndConditions: 1,
      ),
    );
    expect(a.data, {
      'full_name': 'Sara',
      'phone_code': '966',
      'password_confirmation': 'pw',
      'terms_and_conditions': 1,
    });
  });

  test('changePassword → POST client/password/change', () async {
    final (api, a) = await makeApi();
    final r = await AuthRepository(api).changePassword(req);
    expect(a.method, 'POST');
    expect(a.path, 'client/password/change');
    expect(r, isA<ApiSuccess<void>>());
  });

  test('logout sends device_token body', () async {
    final (api, a) = await makeApi();
    final r = await AuthRepository(api).logout('dev123');
    expect(a.method, 'POST');
    expect(a.path, 'client/logout');
    expect(a.data, {'device_token': 'dev123'});
    expect(r, isA<ApiSuccess<void>>());
  });

  test('logout failure passes through', () async {
    final (api, _) = await makeApi(body: {'message': 'no'}, status: 401);
    final r = await AuthRepository(api).logout(null);
    expect(r, isA<ServerFailure<void>>());
  });
}
