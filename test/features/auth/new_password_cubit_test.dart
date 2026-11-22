import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/shared/domain/repositories/auth_repository.dart';
import 'package:lavender/features/auth/forget_password/forget_password_cubit.dart';
import 'package:lavender/features/auth/new_password/new_password_cubit.dart';
import 'package:lavender/app/router/route_args.dart';

class _FakeAuthRepository implements AuthRepository {
  ApiResult<void> changeResult = const ApiSuccess(null);
  final List<AuthRequest> changeRequests = [];
  final List<AuthRequest> resetRequests = [];

  @override
  Future<ApiResult<void>> changePassword(AuthRequest request) async {
    changeRequests.add(request);
    return changeResult;
  }

  @override
  Future<ApiResult<UserModel?>> resetPassword(AuthRequest request) async {
    resetRequests.add(request);
    return const ApiSuccess(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const args = NewPasswordArgs(phone: '512345678', phoneCode: '+966', otp: '1234');

  test('change password sends phone, 966 code, trimmed passwords and otp', () async {
    final repo = _FakeAuthRepository();
    final cubit = NewPasswordCubit(repo, args);

    await cubit.submit(' secret123 ', 'secret123 ');

    expect(repo.changeRequests.single.toJson(), {
      'phone': '512345678',
      'phone_code': '966',
      'password': 'secret123',
      'password_confirmation': 'secret123',
      'otp': '1234',
    });
    expect(cubit.state.event, NewPasswordEvent.navigateSuccess);
    await cubit.close();
  });

  test('change password failure keeps the failure and no event', () async {
    final repo = _FakeAuthRepository()
      ..changeResult = const ServerFailure(422, 'bad otp');
    final cubit = NewPasswordCubit(repo, args);

    await cubit.submit('secret123', 'secret123');

    expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
    expect(cubit.state.event, NewPasswordEvent.none);
    await cubit.close();
  });

  test('reset password sends phone with 966 code and asks for OTP screen', () async {
    final repo = _FakeAuthRepository();
    final cubit = ForgetPasswordCubit(repo);

    await cubit.submit('512345678');

    expect(repo.resetRequests.single.toJson(), {
      'phone': '512345678',
      'phone_code': '966',
    });
    expect(cubit.state.event, ForgetPasswordEvent.navigateOtp);
    await cubit.close();
  });
}
