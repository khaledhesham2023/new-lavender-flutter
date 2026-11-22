import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/shared/domain/repositories/auth_repository.dart';
import 'package:lavender/features/profile/domain/repositories/profile_repository.dart';
import 'package:lavender/features/profile/general_cubit.dart';
import 'package:lavender/features/profile/language_cubit.dart';
import 'package:lavender/features/profile/profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfile implements ProfileRepository {
  ApiResult<UserModel> profile = const ApiSuccess(
    UserModel(
      name: 'Sara Ali',
      phone: '555',
      phoneCode: '966',
      image: 'img',
      email: 'a@b.c',
    ),
  );
  ApiResult<void> deleteResult = const ApiSuccess(null);
  ApiResult<void> langResult = const ApiSuccess(null);
  int profileCalls = 0;
  int deleteCalls = 0;
  final List<String> langs = [];

  @override
  Future<ApiResult<UserModel>> getProfile() async {
    profileCalls++;
    return profile;
  }

  @override
  Future<ApiResult<void>> deleteAccount() async {
    deleteCalls++;
    return deleteResult;
  }

  @override
  Future<ApiResult<void>> changeLang(String lang) async {
    langs.add(lang);
    return langResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuth implements AuthRepository {
  ApiResult<void> logoutResult = const ApiSuccess(null);
  final List<String?> tokens = [];

  @override
  Future<ApiResult<void>> logout(String? deviceToken) async {
    tokens.add(deviceToken);
    return logoutResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(SessionCubit, AppPrefs)> _session({bool loggedIn = true}) async {
  SharedPreferences.setMockInitialValues({
    AppPrefs.keyDeviceToken: 'device-1',
    AppPrefs.keyLanguage: 'en',
  });
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final session = SessionCubit(prefs, UserStore(sp));
  if (loggedIn) {
    await session.onAuthenticated(
      const UserModel(id: 1, name: 'Old', token: 't', lang: 'en'),
    );
  }
  return (session, prefs);
}

void main() {
  group('ProfileCubit', () {
    test('refresh stores the fresh profile in the session', () async {
      final (session, _) = await _session();
      final cubit = ProfileCubit(_FakeProfile(), session);
      await cubit.refresh();
      expect(session.state.user?.name, 'Sara Ali');
      expect(session.state.user?.phone, '555');
      expect(session.state.user?.image, 'img');
      expect(cubit.state.failure, isNull);
    });

    test('a failure is only reported, the stored user stays', () async {
      final (session, _) = await _session();
      final repo = _FakeProfile()..profile = const NetworkFailure();
      final cubit = ProfileCubit(repo, session);
      await cubit.refresh();
      expect(session.state.user?.name, 'Old');
      expect(cubit.state.failure, isA<NetworkFailure>());
      cubit.consumeFailure();
      expect(cubit.state.failure, isNull);
    });

    test('guests request nothing', () async {
      final (session, _) = await _session(loggedIn: false);
      final repo = _FakeProfile();
      await ProfileCubit(repo, session).refresh();
      expect(repo.profileCalls, 0);
    });
  });

  group('GeneralCubit', () {
    test('logout sends the device token and clears the session', () async {
      final (session, prefs) = await _session();
      final auth = _FakeAuth();
      final cubit = GeneralCubit(
        GeneralType.logout,
        auth,
        _FakeProfile(),
        session,
        prefs,
      );
      await cubit.confirm();
      expect(auth.tokens, ['device-1']);
      expect(cubit.state.done, isTrue);
      expect(session.state.isLoggedIn, isFalse);
      expect(session.state.languageCode, 'ar');
    });

    test('delete account calls the profile API', () async {
      final (session, prefs) = await _session();
      final profile = _FakeProfile();
      final cubit = GeneralCubit(
        GeneralType.deleteAccount,
        _FakeAuth(),
        profile,
        session,
        prefs,
      );
      await cubit.confirm();
      expect(profile.deleteCalls, 1);
      expect(cubit.state.done, isTrue);
      expect(session.state.isLoggedIn, isFalse);
    });

    test('a failure keeps the session and is reported once', () async {
      final (session, prefs) = await _session();
      final auth = _FakeAuth()..logoutResult = const ServerFailure(500, 'boom');
      final cubit = GeneralCubit(
        GeneralType.logout,
        auth,
        _FakeProfile(),
        session,
        prefs,
      );
      await cubit.confirm();
      expect(cubit.state.done, isFalse);
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.failure, isA<ServerFailure>());
      expect(session.state.isLoggedIn, isTrue);
      cubit.consumeFailure();
      expect(cubit.state.failure, isNull);
    });
  });

  group('LanguageCubit', () {
    test('starts on the current language', () async {
      final (session, _) = await _session();
      expect(LanguageCubit(_FakeProfile(), session).state.selected, 'en');
    });

    test('a logged-in user tells the server, then switches', () async {
      final (session, prefs) = await _session();
      final repo = _FakeProfile();
      final cubit = LanguageCubit(repo, session)..select('ar');
      await cubit.confirm();
      expect(repo.langs, ['ar']);
      expect(session.state.languageCode, 'ar');
      expect(prefs.languageCode, 'ar');
      expect(cubit.state.done, isTrue);
    });

    test('a server failure keeps the old language', () async {
      final (session, _) = await _session();
      final repo = _FakeProfile()..langResult = const NetworkFailure();
      final cubit = LanguageCubit(repo, session)..select('ar');
      await cubit.confirm();
      expect(session.state.languageCode, 'en');
      expect(cubit.state.done, isFalse);
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('a guest switches without calling the server', () async {
      final (session, _) = await _session(loggedIn: false);
      final repo = _FakeProfile();
      final cubit = LanguageCubit(repo, session)..select('ar');
      await cubit.confirm();
      expect(repo.langs, isEmpty);
      expect(session.state.languageCode, 'ar');
      expect(cubit.state.done, isTrue);
    });
  });
}
