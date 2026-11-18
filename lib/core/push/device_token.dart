import 'dart:math';

import '../storage/app_prefs.dart';

/// Source of the push device token. T11 stub returns the stored token;
/// T39 replaces the body with the FCM token retrieval.
class DeviceTokenProvider {
  DeviceTokenProvider(this._prefs);

  final AppPrefs _prefs;

  /// Stored token, or a placeholder generated once per install: the backend
  /// rejects a login without `device_token`. T39 replaces this with FCM.
  Future<String?> getToken() async {
    final stored = _prefs.deviceToken;
    if (stored != null && stored.isNotEmpty) return stored;
    final rnd = Random.secure();
    final placeholder =
        'flutter-${List.generate(32, (_) => rnd.nextInt(16).toRadixString(16)).join()}';
    await _prefs.setDeviceToken(placeholder);
    return placeholder;
  }

  /// Android AuthViewModel.saveDeviceToken (done right after the token is fetched at login).
  Future<void> saveToken(String token) => _prefs.setDeviceToken(token);
}
