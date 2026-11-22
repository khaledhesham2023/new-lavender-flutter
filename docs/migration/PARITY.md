# PARITY: Flutter app vs Android app (T42)

Status: **partly done (2026-11-22).** Flutter side checked on CPH2127 for guest browsing, booking (book, edit, cancel), favorites, notifications, language, profile content pages and deep links. Not done: the Android phone was not re-run side by side for those flows, and rows that need data, OTP, passwords or a payment card are listed under "Not checked" below. T42 is not ticked in PLAN.md.

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

Notes for whoever continues: CPH2127 is now logged out (`pm clear` is blocked on it; I used the in-app logout, previous account "test account A"). Both phones are 720x1600 (CPH2127) and 1080x2400 (RMX3710); drive them with `adb -s <serial> shell input tap` and `exec-out screencap -p`. Get the serials with `adb devices`. Wake RMX3710 first (`input keyevent KEYCODE_WAKEUP`), its screen turns off.

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
| Deep link logged in again (CPH2127, 2026-11-22, id 1 = doctor "ضحى") | Cold: OK, opens Doctor Details, Back lands on Home. Warm: opens Doctor Details; DIFF (minor): Back returned to the screen the user was on (My reports), whereas Android navigates with `popUpTo(homeFragment, inclusive)` and clears the stack. Not run on the Android phone. Owner to decide if the Flutter behaviour is acceptable. |
| My offers / My reports, test account B (Flutter) | Still empty for this account (empty states and tabs OK, same as before). Purchase with a Tap test card, offer details and report downloads need data on the account. |
| Deep link as guest (CPH2127, 2026-11-22, `adb am start -a VIEW -d https://lavander.doha.aait-d.com/doctor/1`) | OK by code and device. Cold start as guest (onboarding done): the link is dropped and the app lands on the start screen, same as Android `handelAppLinks` (guest goes to `AuthActivity` and the main activity finishes). Warm as guest: the link is ignored and the guest stays on home; Android only runs `handelAppLinks` in `onCreate`, so a warm link does nothing there either (not run on the Android phone). Note: right after a logout the first launch shows onboarding first (isFirstTime), the link is dropped there too, as in the logged-out Android flow. |
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
| Bookings: tabs, search, filters, cancel / edit / rebook / rate | Partly checked on Flutter only (see the Booking flow table); rebook and rate not checked |
| Favorites | Checked on Flutter only (see the Booking flow table) |
| Notifications and push (foreground, background, killed) | List, tap routing, toggle, swipe delete and foreground push checked on Flutter only; background / killed not checked |
| Profile: edit, password, language, contact, about, terms, privacy, delete account | Language, contact, about, terms, privacy checked on Flutter only; edit, password, delete account not checked |
| My offers, purchase with a Tap **test** card | Not checked |
| My reports, downloads | Not checked |
| Arabic RTL and English LTR | Doctor Details in Arabic looks correct; the rest not checked |
| Error states (airplane mode, 404 on offer details) | Not checked |
| D8 to D10 | Code check OK: channel `NOTIFICATIONS_CHANNEL_ID` created and permission requested once on home (`push_service.dart`); Play Store `market://` with https fallback (`launchers.dart`); `Authorization` header only set when a token exists (`api_client.dart:52`). Runtime check on a device still open. |

## Logged-in checks (Android: test account A on RMX3710, Flutter: test account B on CPH2127; different accounts, so layout only)
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
| Re-check on CPH2127 (2026-11-22, latest master debug build, test account B) | OK: booked 02:00 PM, success screen #1065 shows "Saturday, 28 November 2026" (was Friday 27), and the Bookings list shows "Saturday, 28 November 2026 - 02:00 PM". Android side not repeated. |
| Booking rule: second pending booking with the same doctor | OK: server rejects with the red toast "لديك حجز بالفعل مع هذا الطبيب" (the toast disappears in about 3 s). Same behaviour as before, not an app bug. |
| Cancel from the Bookings list (Flutter) | OK: confirmation sheet, then the booking disappears and the empty state shows. Android side not compared. |
| Bookings (Flutter only, CPH2127, 2026-11-22): type and date filter sheets open, red dot on the filter button when a filter is active, empty state when nothing matches, search "doctor" matches, edit slot (sheet, confirm sheet, "تم تغيير الموعد بنجاح", list shows 05:00 PM), appointment details (#1065, pending badge, date, duration, price, notes, edit / cancel buttons) | OK on Flutter. Android side not compared. A push notification arrived after the edit (bell badge 2 to 3). |
| Bookings: other tabs with data (confirmed, ongoing, completed, cancelled), rebook, rate | Not checked: needs a booking the doctor confirms and completes |
| Favorites (Flutter only): heart on a home card, doctor shows in the Favorites tab with a filled heart, un-heart in the tab removes it and shows the empty state | OK on Flutter. Android side, favorites from search / doctor details, and home heart sync after removal not checked. |
| Notifications (Flutter only, CPH2127, 2026-11-22): list shows the booking / edit pushes with unread dots; tap opens the right appointment details and clears the dot; switch off shows the "لن تستطيع استلام اشعارات جديدة" banner, switch on removes it; swipe delete (Arabic: left to right, `Dismissible` endToStart, matches Android `ItemTouchHelper.START`) shows "تم الحذف بنجاح" and removes the row; bell badge on home follows the unread count | OK on Flutter. Android side not compared. Push foreground showed up (badge 2 to 3 after an edit); background / killed and tap routing from the system tray not checked. |
| Notification time vs phone clock | Note: a booking made at 21:34 phone time shows "10:34 مساءً" in the list. Both apps print the server's `date_formated` as is (Android `NotificationModel.date_formated`, Flutter `notification.dateFormated`), so the one-hour offset comes from the server, not from the app. |
| Language switch Arabic to English and back (Flutter) | OK: sheet, confirm, app restarts on home in English LTR (tabs, home, profile mirrored), back to Arabic RTL. The home heart was empty after the earlier un-favorite, so home and the Favorites tab stay in sync. |
| Profile (Flutter, English): contact us (name prefilled, headline, message, send, WhatsApp icon), who are we, about app (social buttons, terms / privacy links), terms, privacy | OK on Flutter; content is server test data ("about", "123", "d"). The message field hint reads "Enter message headline", same as the Android layout (`enter_message_headline` on both fields). Not sent / not compared: send message, WhatsApp, rate app, social links, edit profile, change password, delete account, logout. |
| (earlier note) Success screen date | FIXED in code (branch `fix-booking-date-timezone`), now device-verified (row above): Android showed "Saturday, 28 Nov 2026", Flutter "Friday, 27 Nov 2026". Cause: Android `convertIsoToDateOnly` / `formatToLongDate` parse in UTC but format in the device zone (no zone on the output formatter), so `…T22:00:00Z` is the next day in Egypt; Flutter formatted in UTC. Flutter now uses `toLocal()` in both (`lib/core/utils/date_utils.dart`), covered by a test. The chip label (`formatDateToDayMonth`) reads the raw ISO date on both apps, so it says 11/27 on both, as before. Appointments #1058 and #1059 exist on the test accounts. |

## Remaining differences
- Deep link, warm, logged in: Back returns to the previous screen on Flutter, Android clears the stack to Home (minor, owner to decide).
- Notification times show the server string (one hour ahead of the phone clock on both apps); server side, not an app difference.
- Booking: saved date was one day earlier on Flutter than on Android; fixed in code (see Booking flow table), device re-check still open.
- Guest Bookings: Android shows the sort button in the header, Flutter does not (likely an Android layout quirk, the button does nothing for a guest; owner to decide).
- Guest Favorites: Android shows the search field above the must-login prompt, Flutter does not (same kind of quirk).
- Onboarding: final-yeh glyph "فى" (Android) vs "في" (Flutter) with identical strings; likely font.

## Not checked (needs data, a person, or the Android phone)
- Side-by-side re-run on the Android phone (RMX3710) of everything checked on Flutter only.
- Register, OTP, login unverified, reset password, edit profile, change password, delete account (throwaway account), contact us send, WhatsApp, rate app, social links.
- Booking with an offer, purchase with a Tap **test** card, my offers details, my reports and downloads (test account B has no offers or reports).
- Bookings tabs with data (confirmed, ongoing, completed, cancelled), rebook, rate; sessions.
- Push in background / killed, tap from the system tray.
- Guest doctor details, error states (airplane mode, 404 on offer details), RTL / LTR on the booking flow and bookings.
- Deep link on the Android app.

## Open questions
- Never verified on a device per task Notes: T10, T12, T22, T23, T26, T28, T29, T30, T37 (Tap test card), T38, T39 (push foreground/background/killed). These are the "Not checked" rows above.
- T04: check `app:halfStars` in the Android review layouts before adding half-star input.
- T06: `UserData` depends on the data-layer `UserModel`; refactor parked.
- T37: `go_sell_sdk_flutter` is a vendored patched copy (Gradle 9 / AGP 9.3.1); owner decided to keep it.
- `offer_booking_test` failure above: decide whether to fix the test or the sheet's layout.
