import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/data/repositories/auth_repository.dart';
import 'package:lavender/data/repositories/profile_repository.dart';
import 'package:lavender/features/profile/change_password/change_password_cubit.dart';
import 'package:lavender/features/profile/forget_password_for_edit/forget_password_for_edit_cubit.dart';
import 'package:lavender/app/router/route_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfileRepository implements ProfileRepository {
  ApiResult<void> changeResult = const ApiSuccess(null);
  final List<AuthRequest> changes = [];

  @override
  Future<ApiResult<void>> changeUserPassword(AuthRequest request) async {
    changes.add(request);
    return changeResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  ApiResult<UserModel?> resetResult = const ApiSuccess(null);
  ApiResult<void> changeResult = const ApiSuccess(null);
  ApiResult<void> logoutResult = const ApiSuccess(null);
  final List<AuthRequest> resets = [];
  final List<AuthRequest> changes = [];
  final List<String?> logouts = [];

  @override
  Future<ApiResult<UserModel?>> resetPassword(AuthRequest request) async {
    resets.add(request);
    return resetResult;
  }

  @override
  Future<ApiResult<void>> changePassword(AuthRequest request) async {
    changes.add(request);
    return changeResult;
  }

  @override
  Future<ApiResult<void>> logout(String? deviceToken) async {
    logouts.add(deviceToken);
    return logoutResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(AppPrefs, SessionCubit)> _session() async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  await prefs.setDeviceToken('device-1');
  final session = SessionCubit(prefs, UserStore(sp));
  await session.onAuthenticated(
    const UserModel(id: 1, name: 'Old', phone: '500000000', token: 't'),
  );
  return (prefs, session);
}

void main() {
  group('ChangePasswordCubit', () {
    late _FakeProfileRepository profile;
    late _FakeAuthRepository auth;
    late ChangePasswordCubit cubit;

    setUp(() {
      profile = _FakeProfileRepository();
      auth = _FakeAuthRepository();
      cubit = ChangePasswordCubit(
        profile,
        auth,
        const ChangePasswordArgs(phone: '512345678', code: '+966'),
      );
    });

    test('submit sends the three passwords and reports success', () async {
      await cubit.submit('old-pass1', 'new-pass1', 'new-pass1');
      final sent = profile.changes.single;
      expect(sent.currentPassword, 'old-pass1');
      expect(sent.password, 'new-pass1');
      expect(sent.passwordConfirmation, 'new-pass1');
      expect(cubit.state.event, ChangePasswordEvent.changed);
      expect(cubit.state.saving, isFalse);
    });

    test('a server failure (wrong current password) is reported', () async {
      profile.changeResult = const ServerFailure(422, 'wrong password');
      await cubit.submit('bad', 'new-pass1', 'new-pass1');
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
      expect(cubit.state.event, ChangePasswordEvent.none);
    });

    test('forgotPassword strips the + from the phone code', () async {
      await cubit.forgotPassword();
      final sent = auth.resets.single;
      expect(sent.phone, '512345678');
      expect(sent.phoneCode, '966');
      expect(cubit.state.event, ChangePasswordEvent.codeSent);
    });

    test('forgotPassword failure is reported', () async {
      auth.resetResult = const NetworkFailure();
      await cubit.forgotPassword();
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
    });

    test('consumeEvent resets the one-shot state', () async {
      await cubit.submit('a', 'b', 'b');
      cubit.consumeEvent();
      expect(cubit.state, const ChangePasswordState());
    });
  });

  group('ForgetPasswordForEditCubit', () {
    late _FakeAuthRepository auth;
    late AppPrefs prefs;
    late SessionCubit session;
    late ForgetPasswordForEditCubit cubit;

    setUp(() async {
      auth = _FakeAuthRepository();
      (prefs, session) = await _session();
      cubit = ForgetPasswordForEditCubit(
        auth,
        session,
        prefs,
        const NewPasswordArgs(
          phone: '512345678',
          phoneCode: '+966',
          otp: '1234',
        ),
      );
    });

    test('submit sends phone, code without +, otp and both passwords', () async {
      await cubit.submit('new-pass1', 'new-pass1');
      final sent = auth.changes.single;
      expect(sent.phone, '512345678');
      expect(sent.phoneCode, '966');
      expect(sent.otp, '1234');
      expect(sent.password, 'new-pass1');
      expect(sent.passwordConfirmation, 'new-pass1');
      expect(cubit.state.event, ForgetPasswordForEditEvent.changed);
    });

    test('submit failure is reported without an event', () async {
      auth.changeResult = const ServerFailure(422, 'bad code');
      await cubit.submit('new-pass1', 'new-pass1');
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
      expect(cubit.state.event, ForgetPasswordForEditEvent.none);
    });

    test('logout sends the device token and clears the session', () async {
      await cubit.logout();
      expect(auth.logouts, ['device-1']);
      expect(cubit.state.event, ForgetPasswordForEditEvent.loggedOut);
      expect(session.state.isLoggedIn, isFalse);
    });

    test('a failed logout keeps the session', () async {
      auth.logoutResult = const NetworkFailure();
      await cubit.logout();
      expect(cubit.state.event, ForgetPasswordForEditEvent.logoutFailed);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
      expect(session.state.isLoggedIn, isTrue);
    });
  });
}
