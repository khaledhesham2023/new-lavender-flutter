import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppPrefs> _make([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppPrefs(await SharedPreferences.getInstance());
}

void main() {
  test('defaults', () async {
    final p = await _make();
    expect(p.languageCode, 'ar');
    expect(p.isFirstTime, true);
    expect(p.isLoggedIn, false);
    expect(p.bearerToken, isNull);
    expect(p.deviceToken, isNull);
    expect(p.allowNotifications, false);
    expect(p.whatsAppNumber, '');
  });

  test('setters round trip', () async {
    final p = await _make();
    await p.setLanguageCode('en');
    await p.setFirstTime(false);
    await p.setLoggedIn(true);
    await p.setAllowNotifications(true);
    await p.setWhatsAppNumber('123');
    await p.setDeviceToken('dev');
    await p.setNotifPermissionAsked(true);
    expect(p.languageCode, 'en');
    expect(p.isFirstTime, false);
    expect(p.isLoggedIn, true);
    expect(p.allowNotifications, true);
    expect(p.whatsAppNumber, '123');
    expect(p.deviceToken, 'dev');
    expect(p.notifPermissionAsked, true);
  });

  test('bearer token prefix', () async {
    final p = await _make();
    await p.setBearerToken('abc');
    expect(p.bearerToken, 'Bearer abc');
    await p.setBearerToken('Bearer xyz');
    expect(p.bearerToken, 'Bearer xyz');
  });

  test('clearForLogout keeps device token and permission flag, resets language', () async {
    final p = await _make();
    await p.setLanguageCode('en');
    await p.setFirstTime(false);
    await p.setLoggedIn(true);
    await p.setBearerToken('abc');
    await p.setDeviceToken('dev');
    await p.setNotifPermissionAsked(true);
    await p.clearForLogout();
    expect(p.deviceToken, 'dev');
    expect(p.notifPermissionAsked, true);
    expect(p.languageCode, 'ar');
    expect(p.isFirstTime, true);
    expect(p.isLoggedIn, false);
    expect(p.bearerToken, isNull);
  });
}
