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

## Notes
- `compileSdk` raised 36 → 37 in `android/app/build.gradle.kts` (SDK 37 was already installed): `flutter_local_notifications` 23 and androidx.core 1.19 require it. `targetSdk` stays 36.
- Done: Firebase + push for Android. `android/app/google-services.json` (copy of the Android app's), Google services Gradle plugin 4.4.2 (`settings.gradle.kts` + `app/build.gradle.kts`), core library desugaring (`desugar_jdk_libs` 2.1.5) for `flutter_local_notifications`. Packages: `firebase_core 5.2.0`, `firebase_messaging 17.1.0`, `flutter_local_notifications 23.0.3`.
- New: `lib/core/push/push_service.dart` (channel, permission, foreground display, token refresh, tap routing, top-level `firebaseBackgroundHandler`), `lib/core/push/notification_target.dart`, real FCM token in `lib/core/push/device_token.dart`. `main.dart` initializes Firebase and the service (a failure there is only logged, the app still starts); `app.dart` hands the router to the service; the splash fetches the token once (Android `saveToken`) and, when logged in, goes Home and then pushes the pending notification target; Home asks for the notification permission once (`notif_permission_asked` in prefs; logout keeps the flag).
- Android bugs fixed (D8): the channel `NOTIFICATIONS_CHANNEL_ID` is now created (high importance, default sound); POST_NOTIFICATIONS is requested on Android 13+; taps work on cold start (`getInitialMessage` / `getNotificationAppLaunchDetails` → pending target → splash).
- Small icon: new monochrome `res/drawable/ic_stat_notification.xml` (the launcher logo shape, single colour) instead of the coloured `ic_launcher_round`; tint `AppColors.primary`. The manifest also sets FCM's default channel / icon / colour so notifications drawn by the system (messages with a `notification` block while in background) use the same channel and look. The icon was built by hand from the launcher vector — check it on a device.
- Taps: warm → logged in users get the target pushed (Home first only when on an auth/onboarding screen; the Home target does `go`); guests ignore the tap; a tap while the splash shows (or before the router exists) becomes the pending target.
- **Token API:** `FirebaseMessaging.getToken` / `onTokenRefresh` are marked deprecated in 17.x in favour of `register()` / `onRegistered`, but those return the Firebase *Installation ID*, not the FCM registration token the backend sends to (Android used `FirebaseMessaging.token`). The deprecated calls are kept with an `ignore` and a comment; confirm with the backend before ever switching.
- `DeviceTokenProvider.getToken()` order: fresh FCM token (10 s timeout) → stored token → a placeholder generated once (the backend rejects a login without `device_token`; the next successful call replaces it).
- Not copied: Android's `setGroup(CLIENT_GROUP_NAME)` (no summary notification was ever created) and the `LocalBroadcastManager` broadcast (nothing listened). The channel name is the fixed string "Lavender" (no l10n in the background isolate).
- Foreground notifications with an empty `data` use the `notification` block's title/body, then Android's fallback texts ("FCM" / "We are glade to reach you").
- Tests: `test/core/push/notification_target_test.dart` (every type, missing/non-numeric id, unknown type), `device_token_test.dart`, `push_service_test.dart` (tap routing: pending, logged in, auth screen, Home target, guest; notification id), and the prefs flag in `app_prefs_test.dart`.
- **Not verified on a device**: the heads-up notification in foreground / background / killed states, the Android 13+ dialog and tap routing need an emulator with Play services and a data-only message from the backend (or the FCM HTTP v1 API).
