import '../storage/app_prefs.dart';

/// Source of the push device token. T11 stub returns the stored token;
/// T39 replaces the body with the FCM token retrieval.
class DeviceTokenProvider {
  DeviceTokenProvider(this._prefs);

  final AppPrefs _prefs;

  Future<String?> getToken() async => _prefs.deviceToken;
}
