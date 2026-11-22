import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lavender/shared/session/session_state.dart';

Future<(SessionCubit, AppPrefs, UserStore)> _make([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final store = UserStore(sp);
  return (SessionCubit(prefs, store), prefs, store);
}

void main() {
  const user = UserModel(
    id: 5,
    name: 'Sara',
    phone: '555',
    phoneCode: '966',
    lang: 'en',
    token: 'abc',
    allowNotification: true,
  );

  test('starts as guest with Arabic', () async {
    final (cubit, _, _) = await _make();
    expect(cubit.state.isLoggedIn, false);
    expect(cubit.state.languageCode, 'ar');
    expect(cubit.state.user, isNull);
  });

  test('onAuthenticated saves login data like Android', () async {
    final (cubit, prefs, store) = await _make();
    await cubit.onAuthenticated(user);
    expect(prefs.isLoggedIn, true);
    expect(prefs.bearerToken, 'Bearer abc');
    expect(prefs.isFirstTime, false);
    expect(prefs.languageCode, 'en');
    expect(prefs.allowNotifications, true);
    expect(store.read()?.name, 'Sara');
    expect(cubit.state.isLoggedIn, true);
    expect(cubit.state.languageCode, 'en');
    expect(cubit.state.user?.id, 5);
  });

  test('onLoggedOut resets everything', () async {
    final (cubit, prefs, store) = await _make();
    await cubit.onAuthenticated(user);
    await cubit.onLoggedOut();
    expect(prefs.isLoggedIn, false);
    expect(prefs.bearerToken, isNull);
    expect(prefs.languageCode, 'ar');
    expect(store.read(), isNull);
    expect(cubit.state, const SessionState());
  });

  test('changeLanguage saves and emits', () async {
    final (cubit, prefs, _) = await _make();
    await cubit.changeLanguage('en');
    expect(prefs.languageCode, 'en');
    expect(cubit.state.languageCode, 'en');
  });

  test('updateUser changes only given fields', () async {
    final (cubit, _, store) = await _make();
    await cubit.onAuthenticated(user);
    await cubit.updateUser(name: 'Mona');
    expect(cubit.state.user?.name, 'Mona');
    expect(cubit.state.user?.phone, '555');
    expect(store.read()?.name, 'Mona');
  });
}
