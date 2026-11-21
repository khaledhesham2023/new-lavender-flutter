import 'package:flutter/foundation.dart';

/// The `device_type` value the backend expects (also sent as the `os` / `type`
/// headers). Read from the running platform, so nothing else hardcodes it.
///
/// Android -> `android`, iOS -> `ios`. Confirm the iOS spelling with the backend.
String get deviceType => switch (defaultTargetPlatform) {
  TargetPlatform.iOS => 'ios',
  _ => 'android',
};

/// Whether the app runs on iOS.
bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;
