import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../session/session_cubit.dart';
import '../storage/app_prefs.dart';
import '../theme/app_colors.dart';
import 'notification_target.dart';

/// Android `notifications_channel_id` (not translatable).
const String notificationChannelId = 'NOTIFICATIONS_CHANNEL_ID';

const String _channelName = 'Lavender';

/// Android `channel_description`.
const String _channelDescription = 'FCM Channel For API 26 and Higher';

/// Monochrome status-bar icon (`res/drawable/ic_stat_notification.xml`).
const String _smallIcon = 'ic_stat_notification';

/// What Android showed when the message had no data at all.
const String _fallbackTitle = 'FCM';
const String _fallbackBody = 'We are glade to reach you';

/// Registers the plugin and creates the notification channel. Android never
/// created it (so nothing was shown on Android 8+, decision D8); the channel is
/// high importance with the default sound (`PRIORITY_HIGH`). Called from the main
/// isolate and from the background-message isolate.
Future<void> initLocalNotifications(
  FlutterLocalNotificationsPlugin plugin, {
  DidReceiveNotificationResponseCallback? onTap,
}) async {
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings(_smallIcon),
    ),
    onDidReceiveNotificationResponse: onTap,
  );
  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          notificationChannelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
}

/// Builds and shows the notification of [message] (Android
/// `FirebaseMessagingService.createNotification`): title/body from the data,
/// then from the `notification` block, then Android's fallback texts. The
/// payload is the data map, read back on tap.
Future<void> showRemoteMessage(
  FlutterLocalNotificationsPlugin plugin,
  RemoteMessage message,
) {
  final data = message.data;
  final title =
      _nonEmpty(data['title']) ??
      _nonEmpty(message.notification?.title) ??
      _fallbackTitle;
  final body =
      _nonEmpty(data['body']) ??
      _nonEmpty(message.notification?.body) ??
      _fallbackBody;
  return plugin.show(
    id: notificationId(),
    title: title,
    body: body,
    payload: jsonEncode(data),
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        _channelName,
        channelDescription: _channelDescription,
        icon: _smallIcon,
        color: AppColors.primary,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(body),
      ),
    ),
  );
}

String? _nonEmpty(String? value) =>
    (value == null || value.isEmpty) ? null : value;

/// Android used `now / 1000 % Int.MAX`: one id per second, so notifications do
/// not replace each other.
@visibleForTesting
int notificationId([DateTime? now]) =>
    (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000 % 0x7fffffff;

/// Background / terminated messages. A message with a `notification` block is
/// drawn by the system (with the channel, icon and colour from the manifest);
/// a data-only message is shown here, like Android did in every state.
/// No `BuildContext` or l10n in this isolate: the data strings are used as-is.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) return;
  final plugin = FlutterLocalNotificationsPlugin();
  await initLocalNotifications(plugin);
  await showRemoteMessage(plugin, message);
}

/// Push notifications: channel, permission, foreground display, token refresh
/// and tap routing (all states). Port of `FirebaseMessagingService` plus the
/// notification part of `MainActivity`, with the Android bugs fixed (D8).
class PushService {
  PushService(this._prefs, this._session);

  final AppPrefs _prefs;
  final SessionCubit _session;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  GoRouter? _router;
  String? _pendingTarget;

  /// The route a tap asked for before the app could open it (cold start, or a
  /// tap while the splash is still showing). The splash consumes it.
  String? takePendingTarget() {
    final target = _pendingTarget;
    _pendingTarget = null;
    return target;
  }

  /// Wires the router used for taps while the app runs.
  void attachRouter(GoRouter router) => _router = router;

  /// Call once after `Firebase.initializeApp()`.
  Future<void> init() async {
    await initLocalNotifications(_local, onTap: _onLocalTap);

    final messaging = FirebaseMessaging.instance;
    // Foreground: the system draws nothing, so the notification is built here.
    FirebaseMessaging.onMessage.listen((m) => showRemoteMessage(_local, m));
    // Background: the user tapped a system-drawn notification.
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _onTap(m.data));
    // Android `onNewToken`: store it only (no API call).
    // (`onTokenRefresh` is deprecated for `onRegistered`, which yields the
    // Installation ID instead of the FCM token: see DeviceTokenProvider.)
    // ignore: deprecated_member_use
    messaging.onTokenRefresh.listen(_prefs.setDeviceToken);

    // Cold start from a tap: a system notification, then one of ours.
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _pendingTarget = NotificationTarget.fromData(initial.data);
      return;
    }
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _pendingTarget = NotificationTarget.fromData(
        _decode(launch?.notificationResponse?.payload),
      );
    }
  }

  /// Shows the Android 13+ permission dialog once, the first time the user
  /// reaches Home (not on the splash).
  Future<void> requestPermissionOnce() async {
    if (_prefs.notifPermissionAsked) return;
    await _prefs.setNotifPermissionAsked(true);
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (e) {
      debugPrint('requestPermission failed: $e');
    }
  }

  void _onLocalTap(NotificationResponse response) =>
      _onTap(_decode(response.payload));

  void _onTap(Map<String, dynamic> data) =>
      openTarget(NotificationTarget.fromData(data));

  /// Opens [target] now when the app is running past the splash, otherwise keeps
  /// it for the splash. Guests are ignored. Logged in users get [target] pushed
  /// on top of what they see (Home first if they are on an auth screen).

  void openTarget(String target) {
    final router = _router;
    if (router == null || _location(router) == Routes.splash) {
      _pendingTarget = target;
      return;
    }
    if (!_session.state.isLoggedIn) return;
    if (_isAuthLocation(_location(router))) router.go(Routes.home);
    if (target == Routes.home) {
      router.go(Routes.home);
    } else {
      router.push(target);
    }
  }

  static String _location(GoRouter router) =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;

  static bool _isAuthLocation(String path) =>
      path.startsWith('/auth') || path == Routes.onboarding;

  static Map<String, dynamic> _decode(String? payload) {
    if (payload == null || payload.isEmpty) return const {};
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }
}
