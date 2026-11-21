# PARITY: Flutter app vs Android app (T42)

Status: **in progress.** Only what could be checked from the PC is filled in. The screen-by-screen rows need a person on the two phones.

## Setup
| | Device | App |
|---|---|---|
| Reference | RMX3710, Android 13 | Android app `app-google-debug.apk`, versionName 1.0GMS |
| Flutter | CPH2127, Android 12 | `app-debug.apk`, versionName 1.0.0 (build 1) |

Both apps use package id `com.alalmiya.lavender`, so they cannot share a phone.

## Versions and sizes (2026-11-22)
- Flutter 3.47.7 stable (framework abaf9c5237, engine bf601093ad).
- Release APK 116.6 MB, release AAB 112.4 MB, debug APK 218.1 MB (all Flutter, `env/release.json` / `env/debug.json`).
- Release APK signature SHA-256 `2A:D9:31:F7:E8:A0:A0:DA:D7:3E:F3:AD:25:A1:98:99:42:7E:B3:2C:A0:08:73:9F:09:6F:A7:8D:A9:C5:97:71` equals the SHA-256 of `lavenderk/app/PlayStore/key.jks` (alias `key0`).
- Dart 3.14.0. Direct packages: app_links 7.2.2, background_downloader 9.6.6, cached_network_image 4.0.7, dio 5.11.1, firebase_core 5.2.0, firebase_crashlytics 6.1.0, firebase_messaging 17.1.0, flutter_bloc 9.1.1, flutter_local_notifications 23.0.3, flutter_svg 2.5.0, get_it 9.3.0, go_router 18.1.4, go_sell_sdk_flutter 2.4.29 (vendored patch, D14), image_picker 1.2.4, infinite_scroll_pagination 5.1.1, intl 0.20.3, lottie 3.8.2, material_ui 1.11.1, retrofit 4.10.0, share_plus 13.3.1, shared_preferences 2.5.6, url_launcher 6.3.3 (full list: `flutter pub deps --style=compact`).

Notes for whoever continues: CPH2127 is now logged out (`pm clear` is blocked on it; I used the in-app logout, previous account "User2000"). Both phones are 720x1600 (CPH2127) and 1080x2400 (RMX3710); drive them with `adb -s <serial> shell input tap` and `exec-out screencap -p`. RMX3710 serial `JBR855DEIBHYNZXW`, CPH2127 serial `fe95c1b7`. Wake RMX3710 first (`input keyevent KEYCODE_WAKEUP`), its screen turns off.

## Automated checks
| Check | Result |
|---|---|
| `flutter analyze` | Lint in `bottom_sheet_frame.dart` fixed (braces added) |
| `flutter test` | 446 pass, 1 fail: `offer_booking_test` "AppointmentTypeSheet single selection..." (tap misses its target on the test screen). Cause: the third row was below the fold of the test screen, so the tap missed. Fixed in the test (`ensureVisible`), no app change. |
| Release APK / AAB build | OK |
| Debug APK build and install on CPH2127 | OK |
| Release installed over the Android release build | N/A: the Android app is not published on the Play Store, so there is no release build to update |

## Flows
| Flow | Result |
|---|---|
| Deep link `/doctor/<id>`, cold start, logged in (CPH2127, `adb`) | OK: opens Doctor Details. The debug splash took about 25 s before it navigated. |
| Deep link, warm, logged in | OK: a second link (different id) opened that doctor |
| Deep link as guest | Not checked |
| Deep link on the Android app (RMX3710) | Not checked |
| First launch, onboarding (3 pages), start screen, "continue as guest" | OK on both. Same layout and strings (`app_ar.arb` equals the Android string file, including the `\n`). Final-yeh glyph differs ("فى" on Android, "في" on Flutter) with identical strings: likely font, to confirm. |
| Guest home (banner, search, specialities, recently added doctors) | OK on both |
| Guest must-login prompt on Bookings tab | Flutter OK (illustration, "يجب عليك تسجيل الدخول اولاً", login button). Android screenshot came back black (screen off), redo. |
| Guest Bookings tab (Android side, redone) | DIFF: Android shows the sort button (top-left of the header) above the must-login prompt; Flutter shows none. Rest identical. |
| Guest Favorites tab | DIFF: Android shows the "search by doctor name" field above the must-login prompt; Flutter shows only the prompt. Header and prompt text identical. |
| Guest Profile tab | OK on both (illustration, login button, notifications, language, contact us, rate app, about us rows) |
| Guest Search tab (popular specialities with doctor counts) | OK on both |
| Guest: doctor details | Not checked |
| Flutter logout, then next launch | OK: start screen right after logout, onboarding on the next launch (matches the Android behaviour in the task) |
| Register, OTP, logout, login unverified, reset password | Not checked |
| Book normal appointment (change slot), book with offer | Not checked |
| Bookings: tabs, search, filters, cancel / edit / rebook / rate | Not checked |
| Favorites | Not checked |
| Notifications and push (foreground, background, killed) | Not checked |
| Profile: edit, password, language, contact, about, terms, privacy, delete account | Not checked |
| My offers, purchase with a Tap **test** card | Not checked |
| My reports, downloads | Not checked |
| Arabic RTL and English LTR | Doctor Details in Arabic looks correct; the rest not checked |
| Error states (airplane mode, 404 on offer details) | Not checked |
| D8 to D10 | Code check OK: channel `NOTIFICATIONS_CHANNEL_ID` created and permission requested once on home (`push_service.dart`); Play Store `market://` with https fallback (`launchers.dart`); `Authorization` header only set when a token exists (`api_client.dart:52`). Runtime check on a device still open. |

## Logged-in checks (Android: User2000 on RMX3710, Flutter: User8000 on CPH2127; different accounts, so layout only)
| Screen | Result |
|---|---|
| Bookings tab (empty: tabs, search, sort, calendar icon) | OK |
| Favorites tab (empty, search field) | OK |
| Profile tab (name, edit, password, my offers, reports, notifications, language, contact, rate, about) | OK |
| My offers (empty) | OK |
| My reports (empty, x-ray / labs tabs) | OK |
| Notifications (empty) | DIFF fixed: Flutter showed a "retry" button under the empty state, Android shows none. Button removed in `notifications_screen.dart`. |
| Everything needing data (bookings actions, favorites toggle, paging, swipe delete, push, purchase, downloads) | Not checked: both accounts are empty |

## Booking flow (same doctor "doctor test", first day chip, 02:00 PM, no notes)
| Step | Result |
|---|---|
| Home to doctor details (booking times tab, chips, slots, "book" button) | OK, identical |
| Book appointment screen (date, time, duration, price, notes) | OK; both show "Saturday, 28 November 2026 / 02:00 PM". Android's confirm button is partly under the nav bar, Flutter's is fully visible (Android layout quirk). |
| Success screen layout, confetti, ids (#1058 Android, #1059 Flutter) | OK |
| Success screen date | DIFF: Android "Saturday, 28 Nov 2026", Flutter "Friday, 27 Nov 2026" (text comes from the server's `formatedDate`, so the saved day differs by one). The chip label says "Saturday 11/27" on both, so the chip date is a UTC date that is already one day behind the weekday. Both ports send `convertIsoToDateOnly(date)` (UTC); the cause of the one-day gap is not found. Needs the request body of both apps (Charles/proxy or the debug logger, the Flutter logcat had no request lines) to compare `day`. Appointments #1058 and #1059 now exist on the test accounts. |

Resume notes for the date investigation: the Flutter `ApiLogger` writes with `dart:developer` `log`, which neither `flutter attach` nor logcat shows. To see the request body, temporarily make its sink also `print(...)` and use `flutter run -d fe95c1b7 --dart-define-from-file=env/debug.json` (the debug splash takes ~25 s). Compare the saved `day` of a Flutter booking with Android's response text (`formatedDate`). Revert the logger edit afterwards.

## Remaining differences
- Booking: saved date is one day earlier on Flutter than on Android for the same chip (see Booking flow table). Open.
- Guest Bookings: Android shows the sort button in the header, Flutter does not (likely an Android layout quirk, the button does nothing for a guest; owner to decide).
- Guest Favorites: Android shows the search field above the must-login prompt, Flutter does not (same kind of quirk).
- Onboarding: final-yeh glyph "فى" (Android) vs "في" (Flutter) with identical strings; likely font.

## Open questions
- Never verified on a device per task Notes: T10, T12, T22, T23, T26, T28, T29, T30, T37 (Tap test card), T38, T39 (push foreground/background/killed). These are the "Not checked" rows above.
- T04: check `app:halfStars` in the Android review layouts before adding half-star input.
- T06: `UserData` depends on the data-layer `UserModel`; refactor parked.
- T37: `go_sell_sdk_flutter` is a vendored patched copy (Gradle 9 / AGP 9.3.1); owner decided to keep it.
- `offer_booking_test` failure above: decide whether to fix the test or the sheet's layout.
