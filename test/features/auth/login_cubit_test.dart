import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/push/device_token.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/shared/domain/repositories/auth_repository.dart';
import 'package:lavender/features/auth/login/login_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  ApiResult<UserModel> loginResult = const ApiSuccess(UserModel(id: 1));
  ApiResult<UserModel?> resendResult = const ApiSuccess(null);
  final List<AuthRequest> loginRequests = [];
  final List<AuthRequest> resendRequests = [];

  @override
  Future<ApiResult<UserModel>> login(AuthRequest request) async {
    loginRequests.add(request);
    return loginResult;
  }

  @override
  Future<ApiResult<UserModel?>> resendCode(AuthRequest request) async {
    resendRequests.add(request);
    return resendResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(LoginCubit, _FakeAuthRepository, AppPrefs, SessionCubit)> _make({
  Map<String, Object> initial = const {},
}) async {
  SharedPreferences.setMockInitialValues(initial);
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final session = SessionCubit(prefs, UserStore(sp));
  final repo = _FakeAuthRepository();
  final cubit = LoginCubit(repo, session, DeviceTokenProvider(prefs));
  return (cubit, repo, prefs, session);
}

void main() {
  const verified = UserModel(
    id: 5,
    name: 'Sara',
    phone: '512345678',
    phoneCode: '966',
    lang: 'en',
    token: 'abc',
    isVerified: true,
  );

  test('verified login saves the session and navigates home', () async {
    final (cubit, repo, prefs, session) = await _make(
      initial: {AppPrefs.keyDeviceToken: 'fcm-1'},
    );
    repo.loginResult = const ApiSuccess(verified);

    await cubit.submit('512345678', 'password1');

    expect(cubit.state.event, LoginEvent.navigateHome);
    expect(session.state.isLoggedIn, true);
    expect(prefs.isLoggedIn, true);
    expect(prefs.bearerToken, 'Bearer abc');
    expect(repo.resendRequests, isEmpty);

    final req = repo.loginRequests.single;
    expect(req.phone, '512345678');
    expect(req.phoneCode, '966'); // no '+'
    expect(req.deviceToken, 'fcm-1');
    expect(req.deviceType, 'android');
    expect(req.password, 'password1');
  });

  test('unverified login navigates to OTP without resending', () async {
    final (cubit, repo, _, session) = await _make();
    repo.loginResult = const ApiSuccess(UserModel(id: 6, phone: '511111111'));

    await cubit.submit('512345678', 'password1');

    expect(session.state.isLoggedIn, false);
    expect(repo.resendRequests, isEmpty); // backend resend is broken: not called
    expect(cubit.state.event, LoginEvent.navigateOtp);
    expect(cubit.state.otpPhone, '511111111');
  });

  test('unverified login without server phone falls back to the typed one', () async {
    final (cubit, repo, _, _) = await _make();
    repo.loginResult = const ApiSuccess(UserModel(id: 6));

    await cubit.submit('512345678', 'password1');

    expect(repo.resendRequests, isEmpty);
    expect(cubit.state.event, LoginEvent.navigateOtp);
    expect(cubit.state.otpPhone, '512345678');
  });

  test('server failure is passed through and nothing is saved', () async {
    final (cubit, repo, prefs, session) = await _make();
    repo.loginResult = const ServerFailure(401, 'Wrong password');

    await cubit.submit('512345678', 'password1');

    expect(cubit.state.status, ViewStatus.failure);
    final failure = cubit.state.failure! as ServerFailure<dynamic>;
    expect(failure.message, 'Wrong password');
    expect(session.state.isLoggedIn, false);
    expect(prefs.isLoggedIn, false);
    expect(repo.resendRequests, isEmpty);
  });

  test('consumeEvent resets the one-shot state', () async {
    final (cubit, repo, _, _) = await _make();
    repo.loginResult = const ApiSuccess(verified);
    await cubit.submit('512345678', 'password1');

    cubit.consumeEvent();

    expect(cubit.state, const LoginState());
  });
}
