# T39 - Firebase and push notifications

## Goal
Add Firebase to the Flutter Android app, get/refresh the FCM token (used by login/verify/logout), show notifications in all app
states, and route notification taps — **fixing** the Android bugs (decision D8): create the channel, request POST_NOTIFICATIONS on
Android 13+, and handle taps on cold start too.

## Read first
- `app/src/main/java/com/alalmiya/lavender/fcm/FirebaseMessagingService.kt`, `fcm/MyInstanceIDService.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/home/MainActivity.kt` (`handleNotificationNavigation`)
- `app/src/main/java/com/alalmiya/lavender/presentation/splash/SplashActivity.kt` (token fetch)
- `app/google-services.json` (copy it; do not edit)
- `res/values/strings.xml` (`notifications_channel_id`, `channel_description` — non-translatable)
- `docs/migration/CONTEXT.md` §7.5, §8 (FCM)
- `docs/migration/PLAN.md` D8
- `lib/core/push/device_token.dart` (T11 stub)

## Build
- `lavender-flutter/android/app/google-services.json` (copy of `app/google-services.json`)
- Gradle: `com.google.gms.google-services` plugin in `android/settings.gradle.kts` (plugins block, `apply false`) and `android/app/build.gradle.kts`
- `lib/core/push/push_service.dart` — init, permission, channel, handlers, pending tap target
- `lib/core/push/device_token.dart` — real FCM token
- `lib/core/push/notification_target.dart` — `NotificationTarget.fromData(Map<String, dynamic>)` → route location string (+ test)
- `main.dart`, splash: init + consume pending target
- `test/core/push/notification_target_test.dart`

## Steps
1. `flutter pub add firebase_core firebase_messaging flutter_local_notifications`. Copy `../lavenderk/app/google-services.json` into `lavender-flutter/android/app/`. Add the Google services Gradle plugin (version 4.4.2 like Android).
   Enable core library desugaring if `flutter_local_notifications` requires it (its README) in `android/app/build.gradle.kts`.
2. `main.dart`: `await Firebase.initializeApp();` before `runApp`; register `FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler)` (top-level, `@pragma('vm:entry-point')`).
3. `PushService.init()`:
   - Create Android channel id `NOTIFICATIONS_CHANNEL_ID`, name = `l10n` app name or "Notifications", description "FCM Channel For API 26 and Higher", importance high, default sound (Android: PRIORITY_HIGH, default sound).
   - Initialize `flutter_local_notifications` with the small icon — Android used `ic_launcher_round` (colored), which renders as a white square on Android 5+.
     Create a monochrome icon `android/app/src/main/res/drawable/ic_stat_notification.xml` from the app logo shape and use it; set `color: AppColors.primary` (Android `setColor(colorPrimary)`). Note this improvement in Notes.
   - `FirebaseMessaging.instance.requestPermission()` (shows the Android 13 dialog). Call it once after the user reaches Home the first time (not on splash) — store `notif_permission_asked` in prefs.
   - `onMessage` (foreground): build the notification from `message.data` (`title`, `body`, `notify_type`, `notify_id`); if data empty use `message.notification` or Android's fallback ("FCM", "We are glade to reach you"). Payload = `jsonEncode(message.data)`.
   - Background handler: if the message has **no** `notification` block, show the same local notification (Android built it from data in all states); if it has one, the system shows it.
   - Taps: local notification `onDidReceiveNotificationResponse` → payload; `FirebaseMessaging.onMessageOpenedApp` → `message.data`; cold start: `getInitialMessage()` and
     `flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails()` → store as `pendingTarget`.
   - `onTokenRefresh` → `prefs.deviceToken = token` (Android `onNewToken`; no API call).
4. `DeviceTokenProvider.getToken()` → `FirebaseMessaging.instance.getToken()` (save to prefs, fall back to stored value on error). Splash also calls it once (Android `saveToken`).
5. `NotificationTarget.fromData`: `notify_type` appointment → `Routes.appointmentDetails(id)`, offer → `Routes.offerDetails(id)`, user_offer → `Routes.myOfferDetails(id)`,
   report → `Routes.myReports`, anything else → `Routes.home`; `id = int.tryParse(notify_id) ?? 0`.
6. Routing: warm (app running) → if logged in `router.push(target)` (from Home stack: `router.go(Routes.home)` first only if the current route is an auth route); guest → ignore.
   Cold start → Splash, after its decision, if logged in and `pendingTarget != null` → `go(Routes.home)` then `push(target)`, clear it.
7. Tests: `NotificationTarget` mapping for every type, missing id, unknown type.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On an Android 13+ emulator with Play services: permission dialog appears once after reaching Home; sending a data message from the backend (or Firebase console "custom data")
  shows a heads-up notification in foreground, background and killed states; tapping each type opens the right screen in all three states; login sends a real `device_token`.

## Out of scope
- Crashlytics (T41). Deep links (T40). Badge counters.

## Gotchas
- Firebase Console test messages always include a `notification` block; to test data-only messages use the backend or the FCM HTTP v1 API.
- Background isolate: the background handler cannot use `context`/l10n; use the data strings as-is.
- Android's notification id was `now/1000 % Int.MAX`; use `DateTime.now().millisecondsSinceEpoch ~/ 1000 % 0x7fffffff` so notifications don't replace each other.
