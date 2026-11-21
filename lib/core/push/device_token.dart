import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../storage/app_prefs.dart';

/// Source of the push device token (login / verify / logout send it).
/// Port of `MyInstanceIDService`: asks Firebase for the current FCM token.
class DeviceTokenProvider {
  DeviceTokenProvider(
    this._prefs, {
    Future<String?> Function()? fetchFcmToken,
  }) : _fetch = fetchFcmToken ?? _fcmToken;

  final AppPrefs _prefs;
  final Future<String?> Function() _fetch;

  // `getToken` is deprecated in favour of `register()`/`onRegistered`, which return
  // the Firebase Installation ID, not the FCM registration token the backend sends
  // to (Android used `FirebaseMessaging.token`), so the deprecated call is kept.
  // ignore: deprecated_member_use
  static Future<String?> _fcmToken() => FirebaseMessaging.instance.getToken();

  /// The fresh FCM token, which is also stored. When Firebase cannot answer
  /// (no Play services, offline) the stored token is returned; with none stored,
  /// a placeholder generated once per install, because the backend rejects a
  /// login without `device_token`. A later successful call replaces it.
  Future<String?> getToken() async {
    try {
      final token = await _fetch().timeout(const Duration(seconds: 10));
      if (token != null && token.isNotEmpty) {
        await _prefs.setDeviceToken(token);
        return token;
      }
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
    }
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
