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
  static Future<String?> _fcmToken() async {
    await _awaitApnsToken();
    // ignore: deprecated_member_use
    return FirebaseMessaging.instance.getToken();
  }

  /// iOS only. FCM cannot mint a registration token before APNs has handed the
  /// app its device token, and `getToken` throws `apns-token-not-set` until then.
  /// Registration is asynchronous and usually lands a moment after launch, so a
  /// login early in the session would otherwise fall through to the placeholder
  /// below and leave the backend pushing to an address that never resolves.
  /// Giving up after the wait is fine: `getToken` then throws and the stored or
  /// placeholder token is used, exactly as when Firebase is unavailable.
  static Future<void> _awaitApnsToken() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    const step = Duration(milliseconds: 250);
    for (var waited = Duration.zero;
        waited < const Duration(seconds: 5);
        waited += step) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return;
      await Future<void>.delayed(step);
    }
    debugPrint('APNs token still unset; FCM token will be unavailable');
  }

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
