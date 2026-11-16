import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper over [SharedPreferences] for the flags/tokens the app uses.
/// Getters are synchronous (cached instance); setters are async.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppPrefs> create() async =>
      AppPrefs(await SharedPreferences.getInstance());

  static const keyLanguage = 'app_language';
  static const keyFirstTime = 'first_time';
  static const keyLoginStatus = 'login_status';
  static const keyBearerToken = 'bearer_token';
  static const keyDeviceToken = 'device_token';
  static const keyAllowNotifications = 'allow_notifications';
  static const keyWhatsAppNumber = 'whats_app_number';

  String get languageCode => _prefs.getString(keyLanguage) ?? 'ar';
  Future<void> setLanguageCode(String value) =>
      _prefs.setString(keyLanguage, value);

  bool get isFirstTime => _prefs.getBool(keyFirstTime) ?? true;
  Future<void> setFirstTime(bool value) => _prefs.setBool(keyFirstTime, value);

  bool get isLoggedIn => _prefs.getBool(keyLoginStatus) ?? false;
  Future<void> setLoggedIn(bool value) => _prefs.setBool(keyLoginStatus, value);

  String? get bearerToken => _prefs.getString(keyBearerToken);

  /// Stores `"Bearer $token"` unless it already starts with `"Bearer"`.
  Future<void> setBearerToken(String token) => _prefs.setString(
        keyBearerToken,
        token.startsWith('Bearer') ? token : 'Bearer $token',
      );

  String? get deviceToken => _prefs.getString(keyDeviceToken);
  Future<void> setDeviceToken(String value) =>
      _prefs.setString(keyDeviceToken, value);

  bool get allowNotifications => _prefs.getBool(keyAllowNotifications) ?? false;
  Future<void> setAllowNotifications(bool value) =>
      _prefs.setBool(keyAllowNotifications, value);

  String get whatsAppNumber => _prefs.getString(keyWhatsAppNumber) ?? '';
  Future<void> setWhatsAppNumber(String value) =>
      _prefs.setString(keyWhatsAppNumber, value);

  /// Removes everything except the device token, then resets language to "ar".
  /// `first_time` is removed too, so onboarding shows again on next cold start.
  Future<void> clearForLogout() async {
    for (final key in _prefs.getKeys().toList()) {
      if (key != keyDeviceToken) await _prefs.remove(key);
    }
    await _prefs.setString(keyLanguage, 'ar');
  }
}
