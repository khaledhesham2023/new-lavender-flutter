# T40 - Deep links for doctor pages

## Goal
Open `https://<HOST>/doctor/<id>` links (the links the app itself shares from doctor details) in the app, like Android App Links.

## Read first
- `app/src/main/AndroidManifest.xml` (MainActivity intent filters)
- `app/src/main/java/com/alalmiya/lavender/presentation/home/MainActivity.kt` (`handelAppLinks`, `extractNumberFromPath`)
- `docs/migration/CONTEXT.md` §7.5, §11 item 12
- `lib/core/push/push_service.dart` (T39 pending-target pattern to reuse)

## Build
- `lavender-flutter/android/app/src/main/AndroidManifest.xml` — intent filters + `flutter_deeplinking_enabled=false` meta-data
- `lib/core/deeplink/deep_link_service.dart` — `app_links` listener + pending target
- `lib/core/deeplink/doctor_link.dart` — `int? parseDoctorId(Uri)` (+ test)
- Splash / app wiring.
- `test/core/deeplink/doctor_link_test.dart`

## Steps
1. `flutter pub add app_links`.
2. Manifest on the main activity, copying Android: one filter `autoVerify="true"` with `VIEW`, `DEFAULT`, `BROWSABLE`, `scheme https`, `host lavander.doha.aait-d.com`, `pathPrefix /doctor`;
   a second with `scheme http`, same host, `pathPattern /doctor`. (The host is the same in debug and release — hardcode it with a comment pointing to `env/*.json` `HOST`.)
   Add `<meta-data android:name="flutter_deeplinking_enabled" android:value="false"/>` so go_router doesn't consume the URL itself.
   Set `android:launchMode="singleTop"` if not already (Flutter default) so warm links arrive as new intents.
3. `parseDoctorId`: regex `/doctor/(\d+)` on `uri.path` → int; anything else → null.
4. `DeepLinkService.init(router)`: `AppLinks().getInitialLink()` → store as pending; `uriLinkStream` → handle immediately.
   Handle: only if `session.isLoggedIn` (Android ignores guests) and id != null: wait 500 ms (Android `delay(500)`), `router.go(Routes.home)` then `router.push(Routes.doctorDetails(id))`
   (Android pops up to Home, single top).
5. Splash: after its decision, if logged in and a pending link exists → consume it (same as the push pending target; the push target wins if both exist).
6. Test `parseDoctorId` (`/doctor/12` → 12, `/doctor/12/` → 12, `/doctor` → null, `/doctors/1` → check regex behavior and document).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- `adb shell am start -a android.intent.action.VIEW -d "https://lavander.doha.aait-d.com/doctor/<id>" com.alalmiya.lavender` opens the doctor details when logged in (cold and warm); as guest nothing special happens.
- Sharing from doctor details and tapping the link in another app opens the app (verified App Links need the server's `assetlinks.json` to include the release key fingerprint — same as the Android app, unchanged).

## Out of scope
- Server `assetlinks.json`.

## Gotchas
- The debug build is signed with the debug key, so `autoVerify` fails in debug and Android shows a chooser — expected.
