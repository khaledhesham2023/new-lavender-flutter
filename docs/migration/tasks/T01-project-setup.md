# T01 - Flutter project setup

## Goal
Create the empty Flutter app in `lavender-flutter/` with the same applicationId, minSdk and portrait lock as the Android
app, the env-file mechanism that replaces `BuildConfig`, the base folder skeleton and the first three packages.
Everything else builds on this, so it comes first.

## Read first
- `app/build.gradle.kts` (applicationId, min/target/compile SDK, BuildConfig fields, signing)
- `app/src/main/AndroidManifest.xml` (portrait, `supportsRtl`, `allowBackup=false`)
- `README.md` (the env values — copy them only into the untracked `env/debug.json` / `env/release.json`)
- `docs/migration/CONTEXT.md` §2, §3
- `docs/migration/PLAN.md` §1, §2, §3, §4.1, §4.8

## Build
- `lavender-flutter/` created by `flutter create`.
- `lavender-flutter/android/app/build.gradle.kts` — namespace/applicationId `com.alalmiya.lavender`, minSdk 24, targetSdk 36, compileSdk 36.
- `lavender-flutter/android/app/src/main/AndroidManifest.xml` — label "Lavender", portrait, `allowBackup="false"`, INTERNET permission.
- `lavender-flutter/env/example.json` (committed), `env/debug.json`, `env/release.json` (not committed).
- `lavender-flutter/.gitignore` additions.
- `lavender-flutter/lib/core/config/env.dart`.
- `lavender-flutter/lib/main.dart`, `lavender-flutter/lib/app.dart` (temporary minimal app).
- Empty folders with a `.gitkeep`: `lib/core/{network,storage,session,theme,utils,widgets,l10n}`, `lib/data/{models,repositories}`, `lib/router`, `lib/features`, `assets/{fonts,images,svg,gifs,lottie}`, `tool`.
- `lavender-flutter/test/app_smoke_test.dart`.

## Steps
1. From `D:\flutter\New folder` (the parent of the Android repo `lavenderk`) run:
   `flutter create --org com.alalmiya --project-name lavender --platforms android --description "Lavender medical booking" lavender-flutter`
   This creates `D:\flutter\New folder\lavender-flutter` with applicationId `com.alalmiya.lavender` and Kotlin `MainActivity` in package `com.alalmiya.lavender`
   (`--project-name lavender` is required because a folder name with `-` is not a valid Dart package name).
   Then run `git init` inside `lavender-flutter` (it is its own repository, outside `lavenderk`). Do not commit.
2. In `lavender-flutter/android/app/build.gradle.kts` set inside `android {}`: `namespace = "com.alalmiya.lavender"`,
   `compileSdk = 36`; in `defaultConfig`: `applicationId = "com.alalmiya.lavender"`, `minSdk = 24`, `targetSdk = 36`.
   Keep `versionCode = flutter.versionCode` / `versionName = flutter.versionName` (version comes from pubspec; T41 sets the real number).
   Leave the release block signing with the debug key for now (T41 changes it).
3. In `AndroidManifest.xml` (main): set `android:label="Lavender"`, add `android:allowBackup="false"` on `<application>`,
   add `android:screenOrientation="portrait"` on the `<activity>`, add `<uses-permission android:name="android.permission.INTERNET"/>`.
   Do not add any other permission.
4. Create `env/example.json`:
   ```json
   {
     "BASE_URL": "https://example.com/api/",
     "HOST_URL": "https://example.com",
     "HOST": "example.com",
     "PAYMENT_KEY": "sk_test_xxx"
   }
   ```
   Create `env/debug.json` with the `DEBUG_*` values from `../lavenderk/README.md` and `env/release.json` with the `RELEASE_*` values
   (`BASE_URL`←`*_BASE_URL`, `HOST_URL`←`*_HOST_URL`, `HOST`←`*_HOST`, `PAYMENT_KEY`←`*_PAYMENT_KEY`).
5. Append to `lavender-flutter/.gitignore`:
   ```
   env/*.json
   !env/example.json
   android/key.properties
   ```
6. `lib/core/config/env.dart`:
   ```dart
   class Env {
     static const baseUrl = String.fromEnvironment('BASE_URL');
     static const hostUrl = String.fromEnvironment('HOST_URL');
     static const host = String.fromEnvironment('HOST');
     static const paymentKey = String.fromEnvironment('PAYMENT_KEY');
     static bool get isConfigured => baseUrl.isNotEmpty;
   }
   ```
7. `flutter pub add flutter_bloc equatable go_router`.
8. `lib/app.dart`: `class LavenderApp extends StatelessWidget` returning a `MaterialApp` (debugShowCheckedModeBanner false,
   title "Lavender", `themeMode: ThemeMode.light`) whose home is a `Scaffold` with centered text
   `Env.isConfigured ? 'Lavender' : 'Missing env: run with --dart-define-from-file=env/debug.json'`.
9. `lib/main.dart`: `WidgetsFlutterBinding.ensureInitialized()`, `await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`, `runApp(const LavenderApp())`.
10. Delete `test/widget_test.dart`; create `test/app_smoke_test.dart` that pumps `LavenderApp` and expects one `MaterialApp`.
11. Create the empty folders listed in Build with `.gitkeep` files.
12. Run the checks.

## Done when
- `cd "D:\flutter\New folder\lavender-flutter"` then `flutter analyze` → `No issues found!`
- `flutter test` → all tests pass.
- `flutter build apk --debug --dart-define-from-file=env/debug.json` → builds.
- `flutter run --dart-define-from-file=env/debug.json` on an Android emulator (API 24+) shows "Lavender"; rotating the device keeps portrait.
- `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk | findstr package` (or check in Android Studio) shows `com.alalmiya.lavender`.
- `git status` inside `lavender-flutter` does not list `env/debug.json` or `env/release.json`; `git status` in `lavenderk` shows no changes under `app/`.

## Out of scope
- Theme, fonts, strings, assets (T02/T03), Firebase (T39), signing/icons (T41). Do not touch `app/`.

## Gotchas
- `flutter create` may generate Groovy `build.gradle` on some setups; edit whichever file exists, same values.
- Never put real keys in `env/example.json` or any committed file.
- Android forces light mode (`MODE_NIGHT_NO`); keep `themeMode: ThemeMode.light` everywhere.

## Notes
Done. Project created at `D:\flutter\New folder\lavender-flutter` (own git repo, `git init` only, nothing committed).
- Flutter 3.47.7 / Dart 3.14. Gradle: namespace/applicationId `com.alalmiya.lavender`, compileSdk 36, minSdk 24, targetSdk 36. Manifest: label Lavender, portrait, `allowBackup=false`, INTERNET only.
- Verified: `flutter analyze` clean, `flutter test` passes, debug APK builds; `aapt` shows package `com.alalmiya.lavender`, versionCode 1, sdk 24/36. `env/debug.json` and `env/release.json` are git-ignored (contain real keys); `env/example.json` is not.
- Installed packages: `flutter_bloc`, `equatable`, `go_router` (plus `material_ui`, which the generated pubspec already contained).
- **IMPORTANT for all later tasks:** in Flutter 3.47 `package:flutter/material.dart` is **deprecated** (analyzer reports `deprecated_member_use`). The Material widgets now come from the package `material_ui`
  (already a dependency): use `import 'package:material_ui/material_ui.dart';` wherever a task would import `package:flutter/material.dart`. Keep using `package:flutter/widgets.dart`,
  `services.dart`, `foundation.dart` where only those are needed (as in `lib/main.dart`). Otherwise `flutter analyze` will not be clean. The test file imports `material_ui` too.
- The generated template used new dot-shorthand syntax (`.center`); not needed, plain `MainAxisAlignment.center` etc. is fine.
- pubspec version is the generated `1.0.0+1` (matches Android versionCode 1 / name "1.0" in spirit; T41 confirms).
- Empty skeleton folders have `.gitkeep`.
