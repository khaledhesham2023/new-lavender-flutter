import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/core/push/device_token.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/shared/domain/repositories/auth_repository.dart';
import 'package:lavender/features/auth/presentation/otp/otp_cubit.dart';
import 'package:lavender/app/router/route_args.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lavender/features/auth/presentation/otp/otp_event.dart';

class _FakeAuthRepository implements AuthRepository {
  ApiResult<UserModel> verifyPhoneResult = const ApiSuccess(UserModel(id: 1));
  ApiResult<UserModel?> verifyForgetResult = const ApiSuccess(null);
  ApiResult<UserModel?> resendResult = const ApiSuccess(null);
  final List<AuthRequest> verifyPhoneRequests = [];
  final List<AuthRequest> verifyForgetRequests = [];
  final List<AuthRequest> resendRequests = [];

  @override
  Future<ApiResult<UserModel>> verifyPhone(AuthRequest request) async {
    verifyPhoneRequests.add(request);
    return verifyPhoneResult;
  }

  @override
  Future<ApiResult<UserModel?>> verifyForgetPassword(
    AuthRequest request,
  ) async {
    verifyForgetRequests.add(request);
    return verifyForgetResult;
  }

  @override
  Future<ApiResult<UserModel?>> resendCode(AuthRequest request) async {
    resendRequests.add(request);
    return resendResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(OtpCubit, _FakeAuthRepository, AppPrefs, SessionCubit)> _make(
  OtpDestination destination,
) async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final session = SessionCubit(prefs, UserStore(sp));
  final repo = _FakeAuthRepository();
  final cubit = OtpCubit(
    repo,
    session,
    DeviceTokenProvider(prefs),
    OtpArgs(
      phone: '512345678',
      phoneCode: '+966',
      fromDestination: destination,
    ),
  );
  return (cubit, repo, prefs, session);
}

void main() {
  const verified = UserModel(
    id: 5,
    name: 'Sara',
    phone: '512345678',
    token: 'tok',
    isVerified: true,
    lang: 'ar',
  );

  group('login / register', () {
    test('verified: sends device token, saves session, emits message', () async {
      final (cubit, repo, prefs, session) = await _make(OtpDestination.login);
      repo.verifyPhoneResult = const ApiSuccess(verified, message: 'Done!');

      await cubit.verify('1234');

      final req = repo.verifyPhoneRequests.single;
      expect(req.phone, '512345678');
      expect(req.phoneCode, '966'); // no '+'
      expect(req.otp, '1234');
      expect(req.deviceType, 'android');
      expect(req.deviceToken, isNotEmpty);
      expect(repo.verifyForgetRequests, isEmpty);

      expect(cubit.state.event, OtpEvent.verifiedWithMessage);
      expect(cubit.state.message, 'Done!');
      expect(session.state.isLoggedIn, isTrue);
      expect(prefs.isLoggedIn, isTrue);
      expect(prefs.bearerToken, 'Bearer tok');
    });

    test('not verified: session is not saved and no event is emitted', () async {
      final (cubit, repo, prefs, session) = await _make(
        OtpDestination.register,
      );
      repo.verifyPhoneResult = const ApiSuccess(
        UserModel(id: 5, isVerified: false),
      );

      await cubit.verify('1234');

      expect(cubit.state.event, OtpEvent.none);
      expect(cubit.state.isLoading, isFalse);
      expect(session.state.isLoggedIn, isFalse);
      expect(prefs.isLoggedIn, isFalse);
    });

    test('server error shows the inline invalid-code line, no toast', () async {
      final (cubit, repo, _, session) = await _make(OtpDestination.login);
      repo.verifyPhoneResult = const ServerFailure(422, 'bad');

      await cubit.verify('0000');

      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.codeError, isTrue);
      expect(cubit.state.failure, isNull);
      expect(session.state.isLoggedIn, isFalse);

      cubit.consumeEvent();
      expect(cubit.state.codeError, isTrue); // stays until the next attempt
    });

    test('connection error is a failure toast and keeps the line hidden', () async {
      final (cubit, repo, _, _) = await _make(OtpDestination.login);
      repo.verifyPhoneResult = const NetworkFailure();

      await cubit.verify('0000');

      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
      expect(cubit.state.codeError, isFalse);
    });

    test('a new verify clears the inline error', () async {
      final (cubit, repo, _, _) = await _make(OtpDestination.login);
      repo.verifyPhoneResult = const ServerFailure(422, 'bad');
      await cubit.verify('0000');
      expect(cubit.state.codeError, isTrue);

      repo.verifyPhoneResult = const ApiSuccess(verified);
      await cubit.verify('1234');
      expect(cubit.state.codeError, isFalse);
    });

    test('ignores a second verify while loading', () async {
      final (cubit, repo, _, _) = await _make(OtpDestination.login);

      final first = cubit.verify('1234');
      final second = cubit.verify('1234');
      await Future.wait([first, second]);

      expect(repo.verifyPhoneRequests, hasLength(1));
    });
  });

  group('reset password', () {
    test('verifyForgetPassword without device token, then new password', () async {
      final (cubit, repo, _, session) = await _make(
        OtpDestination.resetPassword,
      );

      await cubit.verify('4321');

      final req = repo.verifyForgetRequests.single;
      expect(req.phone, '512345678');
      expect(req.phoneCode, '966');
      expect(req.otp, '4321');
      expect(req.deviceToken, isNull);
      expect(repo.verifyPhoneRequests, isEmpty);

      expect(cubit.state.event, OtpEvent.navigateNewPassword);
      expect(cubit.state.otp, '4321');
      expect(session.state.isLoggedIn, isFalse);
    });

    test('server error shows the inline invalid-code line', () async {
      final (cubit, repo, _, _) = await _make(OtpDestination.resetPassword);
      repo.verifyForgetResult = const ServerFailure(400, 'bad');

      await cubit.verify('0000');

      expect(cubit.state.codeError, isTrue);
      expect(cubit.state.event, OtpEvent.none);
    });
  });
}
