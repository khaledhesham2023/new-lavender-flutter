# T41 - Release config: icons, native splash, signing, version, Crashlytics, manifest

## Goal
Make the release build a drop-in update of the Play Store app: same launcher icon, a native launch screen matching
`Theme.Splash`, the same release keystore, a higher versionCode, Crashlytics (decision D7), and a clean manifest with only the
permissions the app uses.

## Read first
- `app/build.gradle.kts` (signing, minify off, versions), `README.md` (keystore property names)
- `app/src/main/res/mipmap-*` (launcher icons), `mipmap-anydpi-v26/*`, `res/values/ic_launcher_background.xml`, `app/src/main/ic_launcher-playstore.png`
- `res/values/themes.xml` (`Theme.Splash`, drawable `bg_splash`), `res/values-v31/themes.xml`
- `app/src/main/AndroidManifest.xml`
- `docs/migration/CONTEXT.md` §2, §3, §9 (launcher)
- `docs/migration/PLAN.md` D3, D7

## Build
- `lavender-flutter/android/app/src/main/res/mipmap-*` — copied launcher icons (replace Flutter's), `mipmap-anydpi-v26/ic_launcher*.xml` and the referenced foreground/background resources, `values/ic_launcher_background.xml`
- `lavender-flutter/android/app/src/main/res/drawable/launch_background.xml`, `drawable-v21/launch_background.xml`, `values/styles.xml`, `values-v31/styles.xml` — native launch screen
- `lavender-flutter/android/key.properties` (NOT committed) + `android/app/build.gradle.kts` signing config
- `pubspec.yaml` version
- Crashlytics: Gradle plugin + `main.dart` hooks
- Final `AndroidManifest.xml`

## Steps
1. Icons: copy `app/src/main/res/mipmap-*/ic_launcher*.png|webp` and `mipmap-anydpi-v26/*.xml` (and any drawable/color they reference, e.g. `ic_launcher_foreground`, `ic_launcher_background`)
   into the Flutter `android/app/src/main/res/` with the same names; manifest `android:icon="@mipmap/ic_launcher"`, `android:roundIcon="@mipmap/ic_launcher_round"`.
2. Native launch screen: `launch_background.xml` = the content of `bg_splash` (copy the drawable and its resources); Android 12+ (`values-v31/styles.xml` LaunchTheme): `android:windowSplashScreenBackground` white and
   `android:windowSplashScreenAnimatedIcon` transparent (copy `values-v31/themes.xml`). Keep Flutter's `NormalTheme` white background so there is no flash before the Flutter splash (T11).
3. Signing: create `android/key.properties` (untracked) with `storeFile=D:/flutter/New folder/lavenderk/app/PlayStore/key.jks` (absolute path to the Android repo's keystore; do not copy the keystore into `lavender-flutter`), `storePassword`, `keyAlias`, `keyPassword` from `README.md` values;
   in `android/app/build.gradle.kts` load it (`java.util.Properties`) and add `signingConfigs.create("release")`; `buildTypes.release.signingConfig = signingConfigs.getByName("release")`,
   `isMinifyEnabled = false`, `isShrinkResources = false` (Android release had minify off; keeps goSell/Firebase safe). If `key.properties` is missing, fall back to debug signing so CI/dev builds still work.
4. Version: keep it as the Android app (owner decision): `pubspec.yaml` `version: 1.0.0+1` (Android versionName "1.0", versionCode 1). Do not bump it; the owner does that when releasing.
5. Crashlytics: `flutter pub add firebase_crashlytics`; Gradle plugin `com.google.firebase.crashlytics` 3.0.2 (like Android) in settings + app; in `main.dart` after `Firebase.initializeApp()`:
   `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;` and `PlatformDispatcher.instance.onError = (e, s) { FirebaseCrashlytics.instance.recordError(e, s, fatal: true); return true; };`
   `setCrashlyticsCollectionEnabled(!kDebugMode)`.
6. Manifest final review: permissions only `INTERNET`, `POST_NOTIFICATIONS`, `VIBRATE` (if used by notifications) plus whatever the plugins merge (check `build/app/intermediates/merged_manifests`); app label "Lavender" (check `app_name`
   — use the localized label via `@string/app_name` in `res/values` and `values-ar` copies), `allowBackup=false`, portrait, `supportsRtl=true`.
7. Build `flutter build appbundle --release --dart-define-from-file=env/release.json` and `flutter build apk --release --dart-define-from-file=env/release.json`.
8. Compare signing: `keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk` SHA-256 must equal the Android release APK's (build one from `app/` with `./gradlew assembleGoogleRelease` or ask the owner for the Play App Signing upload key fingerprint).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; release APK and AAB build.
- Release APK installs **over** an installed Android release build of the app (same id + same signature) without uninstalling — on a test device.
- Launcher icon (round and adaptive) identical to the Android app; cold start shows no black/white flash beyond what Android showed.
- A forced test crash (temporary button, removed afterwards) appears in the Firebase Crashlytics console for project `lavender-94083`.

## Out of scope
- Uploading to Play. Changing the keystore or rotating keys (owner's job; see Notes for the security remarks).

## Gotchas
- Play App Signing: if the Play Console uses app signing, the upload key must match the keystore here — confirm with the owner.
- The release env uses the **live** Tap key; do not make test payments with a release build.
- `key.properties` and `env/release.json` must never be committed — check `git status`.
