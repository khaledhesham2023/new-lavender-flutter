import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/push/device_token.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppPrefs> _prefs([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppPrefs(await SharedPreferences.getInstance());
}

void main() {
  test('returns the fresh FCM token and stores it', () async {
    final prefs = await _prefs({AppPrefs.keyDeviceToken: 'old'});
    final provider = DeviceTokenProvider(prefs, fetchFcmToken: () async => 'new');
    expect(await provider.getToken(), 'new');
    expect(prefs.deviceToken, 'new');
  });

  test('falls back to the stored token when Firebase fails', () async {
    final prefs = await _prefs({AppPrefs.keyDeviceToken: 'stored'});
    final provider = DeviceTokenProvider(
      prefs,
      fetchFcmToken: () async => throw Exception('no play services'),
    );
    expect(await provider.getToken(), 'stored');
    expect(prefs.deviceToken, 'stored');
  });

  test('falls back to the stored token when Firebase returns nothing', () async {
    final prefs = await _prefs({AppPrefs.keyDeviceToken: 'stored'});
    final provider = DeviceTokenProvider(prefs, fetchFcmToken: () async => null);
    expect(await provider.getToken(), 'stored');
  });

  test('with nothing stored a placeholder is created once', () async {
    final prefs = await _prefs();
    final provider = DeviceTokenProvider(prefs, fetchFcmToken: () async => null);
    final first = await provider.getToken();
    expect(first, startsWith('flutter-'));
    expect(await provider.getToken(), first);
  });

  test('a later real token replaces the placeholder', () async {
    final prefs = await _prefs({AppPrefs.keyDeviceToken: 'flutter-abc'});
    final provider = DeviceTokenProvider(prefs, fetchFcmToken: () async => 'fcm');
    expect(await provider.getToken(), 'fcm');
    expect(prefs.deviceToken, 'fcm');
  });
}
