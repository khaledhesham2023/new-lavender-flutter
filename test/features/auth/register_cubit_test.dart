import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/shared/domain/repositories/auth_repository.dart';
import 'package:lavender/features/auth/register/register_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  ApiResult<UserModel> registerResult = const ApiSuccess(
    UserModel(id: 1, phone: '512345678'),
  );
  final List<AuthRequest> registerRequests = [];

  @override
  Future<ApiResult<UserModel>> register(AuthRequest request) async {
    registerRequests.add(request);
    return registerResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('sends empty email as "", terms=1 and trimmed passwords', () async {
    final repo = _FakeAuthRepository();
    final cubit = RegisterCubit(repo);

    await cubit.submit(
      phone: '512345678',
      fullName: 'Sara Ali',
      email: '',
      password: ' password1 ',
      passwordConfirmation: 'password1 ',
    );

    final req = repo.registerRequests.single;
    expect(req.phone, '512345678');
    expect(req.phoneCode, '966'); // no '+'
    expect(req.fullName, 'Sara Ali');
    expect(req.email, '');
    expect(req.password, 'password1');
    expect(req.passwordConfirmation, 'password1');
    expect(req.termsAndConditions, 1);
    expect(req.toJson()['email'], '');
  });

  test('success navigates to OTP with the phone from the response', () async {
    final repo = _FakeAuthRepository()
      ..registerResult = const ApiSuccess(UserModel(id: 2, phone: '599999999'));
    final cubit = RegisterCubit(repo);

    await cubit.submit(
      phone: '512345678',
      fullName: 'Sara',
      email: 'a@b.com',
      password: 'password1',
      passwordConfirmation: 'password1',
    );

    expect(cubit.state.event, RegisterEvent.navigateOtp);
    expect(cubit.state.otpPhone, '599999999');
  });

  test('missing phone in the response gives an empty OTP phone', () async {
    final repo = _FakeAuthRepository()
      ..registerResult = const ApiSuccess(UserModel(id: 2));
    final cubit = RegisterCubit(repo);

    await cubit.submit(
      phone: '512345678',
      fullName: 'Sara',
      email: '',
      password: 'password1',
      passwordConfirmation: 'password1',
    );

    expect(cubit.state.otpPhone, '');
  });

  test('server failure is passed through', () async {
    final repo = _FakeAuthRepository()
      ..registerResult = const ServerFailure(422, 'phone taken');
    final cubit = RegisterCubit(repo);

    await cubit.submit(
      phone: '512345678',
      fullName: 'Sara',
      email: '',
      password: 'password1',
      passwordConfirmation: 'password1',
    );

    expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
    expect(cubit.state.event, RegisterEvent.none);
  });
}
