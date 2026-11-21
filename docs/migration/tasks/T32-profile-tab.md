# T32 - Profile tab, logout/delete sheet, language sheet

## Goal
Port the Account tab (header, menu for logged-in and guest users), the logout / delete-account confirmation sheet, the language
sheet, and "Rate the app" → Play Store (decision D9).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/screen/ProfileFragment.kt` (whole file), `ProfileViewModel.kt` (`logout`, `deleteAccount`, `observeUserModel`, `getProfileData`, `changeLang`)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/adapter/ProfileAdapter.kt`, `ProfileContent.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/sheet/GeneralSheet.kt`, `GeneralType.kt`, `ChangeLanguageSheet.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/ProfileNavigationController.kt`
- Layouts: `res/layout/fragment_profile.xml` (check the binding name in the fragment), profile item layout, `sheet_general.xml`, `sheet_change_language.xml` (check names)
- `docs/migration/CONTEXT.md` §7.4 (Profile, General sheet, Change language sheet rows), §6.1 (logout clearing)
- `lib/core/session/session_cubit.dart`

## Build
- `lib/features/profile/profile_screen.dart`, `profile_cubit.dart`, `widgets/profile_menu_item.dart`, `widgets/profile_header.dart`
- `lib/features/profile/general_sheet.dart` (+ cubit) — `Future<void> showGeneralSheet(BuildContext, GeneralType type)` with `enum GeneralType { logout, deleteAccount }`
- `lib/features/profile/language_sheet.dart` (+ cubit) — `Future<void> showLanguageSheet(BuildContext)`
- `lib/core/utils/launchers.dart` — `openUrl(String)`, `openPlayStore()`, `openWhatsApp(String phone)` (T35 uses it)
- Router: replace `profile` (shell tab).

## Steps
1. `flutter pub add url_launcher`. Add the `<queries>` entries for `https`/`market` intents in the Android manifest (Android 11 package visibility).
2. `ProfileCubit(ProfileRepository, SessionCubit)`: `refresh()` (on every screen show, like `onResume`) → `getProfile()`; on success `session.updateUser(name, phone, phoneCode, image, email)`; failure → toast only (Android shows toast).
3. Header: logged in → avatar (`AppNetworkImage` circle with loader), `welcome(", ${firstName}")`, "update profile" text; tapping name or the text → `context.push(Routes.editProfile)`.
   Guest → guest header + Login `ProgressButton` → `context.push(Routes.authStart)`. Transparent status bar with light content (copy `changeStatusBarAndNavColor(transparent, true)`).
4. Menu items (icon, text, chevron) in this order:
   - logged in: password (`ic_change_password`) → `context.push(Routes.changePassword, extra: ChangePasswordArgs(phone: user.phone, code: '+${user.phoneCode}'))`;
     my offers (`ic_discount_shape`) → `Routes.myOffers`; radiology & analysis reports (`ic_discount_shape`) → `Routes.myReports`; notifications (`ic_notification_bing`) → `Routes.notifications`;
     language (`ic_translate`) → language sheet; contact us (`ic_call`) → `Routes.contactUs`; rate the app (`ic_app_evaluation`) → `openPlayStore()`;
     who are we (`ic_who_we_are`) → `Routes.aboutUs`; about app (`ic_who_we_are`) → `Routes.aboutApp`; logout (`ic_logout`, check if it has a red style) → general sheet logout.
   - guest: notifications, language, contact us, rate the app, who are we, about app.
5. `openPlayStore()`: try `market://details?id=com.alalmiya.lavender`, fallback `https://play.google.com/store/apps/details?id=com.alalmiya.lavender` (port `CommonUtils.redirectToPlayStore`).
6. General sheet (dismissible): logout → image/texts from the layout, button `logout`; deleteAccount → `ic_bg_delete_account`, red button background, text `deleteAccount`
   (and its body string, e.g. `makeSureYouCancelYourAccount…`). Confirm → `AuthRepository.logout(prefs.deviceToken)` or `ProfileRepository.deleteAccount()`;
   success → `session.onLoggedOut()` → `context.go(Routes.authStart)`; failure → toast. Button shows loading.
7. Language sheet: two options ar/en with the current preselected (`session.languageCode`); confirm → if logged in `changeLang(code)` first (failure → toast and stay);
   then `session.changeLanguage(code)` → close → `context.go(Routes.home)` (Android restarts Main clearing the stack).
8. Back → shell (Home).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: header and menu match Android for logged in and guest; switching language flips the whole app (RTL/LTR) and lands on Home;
  logout returns to Start now and relaunch shows onboarding (first-time cleared, language Arabic); Rate opens Play Store.

## Out of scope
- Destination screens (T33–T38).

## Gotchas
- Logout sends `device_token` in the body.
- After logout the language is forced to Arabic even if the user chose English (Android behavior).
- Menu routing in Android compares localized strings; use an enum per item instead.

## Notes
- Done on branch `T31-T32-notifications-profile` together with T31. `flutter analyze`, `flutter test` (incl. new `test/features/profile`) and the debug APK build pass; not run on a device yet.
- `ProfileScreen` creates `ProfileCubit` on each show (the tab is rebuilt on every switch) and again after returning from a pushed screen. The header reads the user from `SessionCubit`; guests do not call `getProfile`.
- Menu rows are the `ProfileMenu` enum (`widgets/profile_menu_item.dart`), no string matching. Password passes `ChangePasswordArgs(phone, code: +phoneCode)` from the session user.
- `showGeneralSheet(context, GeneralType)` / `showLanguageSheet(context)` keep the `GoRouter` from the caller, pop the sheet, then `go` (Start after logout/delete, Home after a language change). Logout and delete both go through `session.onLoggedOut()`; language is forced to Arabic by `clearForLogout`.
- `lib/core/utils/launchers.dart` has `openUrl`, `openPlayStore` (market first, https fallback) and `openWhatsApp(phone)` (`api.whatsapp.com/send?phone=`, digits only) for T35. The manifest got `queries` for `https` and `market`.
- Status bar on the tab is transparent with light icons (as the task asks); check the 150dp header image on a device.
