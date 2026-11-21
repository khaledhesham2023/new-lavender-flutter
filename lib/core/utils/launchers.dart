import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../push/device_info.dart';

/// Package id of the Play Store listing (same as the Android app).
const playStorePackage = 'com.alalmiya.lavender';

/// Numeric App Store id of the iOS listing (the digits after `id` in the App
/// Store URL). Fill it in when the iOS app is published.
const appStoreId = '';

/// Opens [url] outside the app. Returns `false` when nothing could handle it.
Future<bool> openUrl(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openUrl failed for $url: $e');
    return false;
  }
}

/// "Rate the app": the store listing of the running platform (decision D9).
Future<bool> openStore() => isIos ? openAppStore() : openPlayStore();

/// Port of `CommonUtils.redirectToPlayStore`: the Play Store app first, the
/// website when it is not installed.
Future<bool> openPlayStore() async {
  if (await openUrl('market://details?id=$playStorePackage')) return true;
  return openUrl(
    'https://play.google.com/store/apps/details?id=$playStorePackage',
  );
}

/// The App Store listing. Does nothing until [appStoreId] is set.
Future<bool> openAppStore() async {
  if (appStoreId.isEmpty) return false;
  if (await openUrl('itms-apps://apps.apple.com/app/id$appStoreId')) {
    return true;
  }
  return openUrl('https://apps.apple.com/app/id$appStoreId');
}

/// Port of the Android contact-us link: `api.whatsapp.com/send?phone=...`.
Future<bool> openWhatsApp(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return openUrl('https://api.whatsapp.com/send?phone=$digits');
}
