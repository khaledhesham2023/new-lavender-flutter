# T10 - Session, router and bottom-nav shell

## Goal
Wire the app together: build `AppPrefs`, `UserStore`, `ApiClient` and all repositories in `main.dart`; add the app-wide
`SessionCubit` (login state, language, user); register **every route of the app** in `go_router` with placeholder
screens; and build the 5-tab bottom-navigation shell with Android's back behavior. After this, each screen task only
replaces one placeholder.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/home/MainActivity.kt` (bottom nav, show/hide, tab clicks)
- `app/src/main/res/layout/activity_main.xml`, `res/menu/main_menu.xml`, `res/color/nav_item_text_selector.xml`,
  `res/drawable/home_selector.xml`, `search_selector.xml`, `reservation_selector.xml`, `favorites_selector.xml`, `account_selector.xml`,
  `bg_bottom_navigation_sheet.xml`
- `app/src/main/res/navigation/main_nav_graph.xml`, `auth_nav_graph.xml`
- `app/src/main/java/com/alalmiya/lavender/base/GeneralViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthViewModel.kt` (`login`/`verifyPhone` save logic)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/ProfileViewModel.kt` (`logout`, `deleteAccount`)
- Back handling: `HomeFragment.setupListeners` (back on home), `BookingsFragment`, `FavoritesFragment`, `LastSearchFragment`, `ProfileFragment` (back → pop to home)
- `docs/migration/CONTEXT.md` §4, §7.3, §7.4 (bottom nav paragraph)
- `docs/migration/PLAN.md` §3, §4.3, §4.5

## Build
- `lib/core/session/session_cubit.dart`
- `lib/router/routes.dart` — path constants + argument classes
- `lib/router/app_router.dart` — `GoRouter createRouter()`
- `lib/features/shell/main_shell.dart` — bottom navigation scaffold
- `lib/features/shell/placeholder_screen.dart`
- `lib/main.dart`, `lib/app.dart` — final bootstrap
- `test/core/session/session_cubit_test.dart`

## Steps
1. `SessionCubit` (state: `isLoggedIn`, `languageCode`, `UserData? user`; `Equatable`):
   - constructor reads `AppPrefs` + `UserStore`.
   - `Future<void> onAuthenticated(UserModel user)`: exactly Android's verified-login save: `prefs.isLoggedIn = true`,
     `prefs.setBearerToken(user.token ?? '')`, `prefs.isFirstTime = false`, `userStore.save(UserData.fromUserModel(user))`,
     `prefs.languageCode = user.lang ?? 'ar'`, `prefs.allowNotifications = user.allowNotification ?? false`; emit.
   - `Future<void> onLoggedOut()`: `prefs.clearForLogout()`, `userStore.clear()`; emit `isLoggedIn=false, languageCode='ar', user=null`.
   - `Future<void> changeLanguage(String code)`: save + emit.
   - `Future<void> updateUser({name, phone, phoneCode, image, email})`: `userStore.updateFields` + emit.
2. `routes.dart`: `abstract final class Routes` with these paths (and helper functions for ids):
   | Constant | Path | Argument |
   |---|---|---|
   | splash | `/` | – |
   | onboarding | `/onboarding` | – |
   | authStart | `/auth/start` | – |
   | authLogin | `/auth/login` | – |
   | authRegister | `/auth/register` | – |
   | authForgetPassword | `/auth/forget-password` | – |
   | authOtp | `/auth/otp` | extra `OtpArgs(phone, phoneCode, fromDestination)` |
   | authNewPassword | `/auth/new-password` | extra `NewPasswordArgs(phone, phoneCode, otp)` |
   | authSuccess | `/auth/success` | – |
   | home / search / bookings / favorites / profile | `/home`, `/search`, `/bookings`, `/favorites`, `/profile` | – (shell tabs) |
   | notifications | `/notifications` | – |
   | allSpecialities | `/specialities` | – |
   | offers | `/offers` | – |
   | offerDetails | `/offers/:id` | path id |
   | purchaseOffer | `/purchase-offer` | extra `OfferModel` |
   | offerPurchased | `/offer-purchased/:id` | path id (user offer id) |
   | searchDetails | `/search-details` | extra `SpecialityModel` |
   | filter | `/filter` | extra `FilterArgs` (defined in T21; use `Object?` for now) |
   | doctorDetails | `/doctor/:id` | path id |
   | bookAppointment | `/book-appointment` | extra `BookingDraft` |
   | bookAppointmentWithOffer | `/book-appointment-offer` | extra `BookWithOfferArgs(BookingDraft draft, OfferModel offer)` |
   | appointmentRequested | `/appointment-requested/:id` | path id |
   | sessionRequested | `/session-requested/:id` | path id |
   | appointmentDetails | `/appointments/:id` | path id |
   | sessionDetails | `/sessions/:id` | path id |
   | editProfile | `/profile/edit` | – |
   | otpChangePhone | `/profile/otp` | extra `OtpArgs` |
   | changePassword | `/profile/password` | extra `ChangePasswordArgs(phone, code)` |
   | forgetPasswordForEdit | `/profile/password/reset` | extra `NewPasswordArgs` |
   | contactUs / aboutApp / aboutUs / terms / privacy | `/contact-us`, `/about-app`, `/about-us`, `/terms`, `/privacy` | – |
   | myOffers | `/my-offers` | – |
   | myOfferDetails | `/my-offers/:id` | path id |
   | myReports | `/reports` | – |
   `OtpArgs.fromDestination` uses `enum OtpDestination { login, register, resetPassword, editProfile, editProfileAddNewPassword }`.
   Replace the literal `'/auth/start'` in `must_login_sheet.dart` (T04) with `Routes.authStart`.
3. `app_router.dart`: `GoRouter(initialLocation: Routes.splash, routes: [...])`. Every non-tab route is a top-level `GoRoute`
   (so it covers the shell and the bottom bar disappears, like Android hiding it). The 5 tabs are inside one `ShellRoute` whose builder is
   `MainShell`. Each builder for now returns `PlaceholderScreen(name: '<RouteName>')` (title + `AppBackButton`), reading args so the types are checked.
   Tab routes use `NoTransitionPage`. Auth routes use a slide transition (Android `enter_from_right`/`exit_to_left`), others the default.
4. `MainShell`: `Scaffold(body: child, bottomNavigationBar: ...)` reproducing `activity_main.xml`: white rounded background drawable,
   5 items always labeled, selected/unselected SVG icons from the selector XMLs, label colors from `nav_item_text_selector.xml`, no ripple.
   Selected index from `GoRouterState.of(context).uri.path`. Tap: if already selected → nothing; else `context.go(path)`.
   Wrap in `PopScope(canPop: false)`: on back, if current tab is not home → `context.go(Routes.home)`; if home and
   `session.isLoggedIn` → `SystemNavigator.pop()`; if home and guest → `context.go(Routes.authStart)` (Android opens Auth and finishes Main).
5. `main.dart`: `WidgetsFlutterBinding.ensureInitialized()`, portrait lock, `await initializeDateFormatting()`, create `AppPrefs`, `UserStore`,
   `ApiClient`, all 11 repositories; `runApp(MultiRepositoryProvider(providers: [...], child: BlocProvider(create: (_) => SessionCubit(...), child: LavenderApp())))`.
6. `app.dart`: `MaterialApp.router(routerConfig: router, theme: AppTheme.light(), locale: Locale(session.languageCode), ...)` inside a
   `BlocBuilder<SessionCubit, SessionState>` (buildWhen language changed). Create the router once (a `late final` in a `StatefulWidget`).
7. Temporarily make `PlaceholderScreen` for splash show buttons to `go` to `/home` and `/auth/start` to test the shell; T11 replaces it.
8. Tests: `SessionCubit.onAuthenticated` saves token with "Bearer ", language from user, first-time false; `onLoggedOut` resets.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: from the splash placeholder go to Home; the 5 tabs switch without animation and highlight icons/labels like Android in both
  ar (RTL, tabs mirrored) and en; pushing a placeholder detail route (e.g. temporary button to `/notifications`) hides the bottom bar;
  back on a non-home tab goes to Home; back on Home exits the app.

## Out of scope
- Real screens (T11+). Deep links (T40) and notification routing (T39).

## Gotchas
- Android tab navigation used plain `navigate` (stack grows) but the back override always returns to Home; `context.go` gives the same visible result.
- Detail routes opened from inside a tab must use `context.push` (so back returns to the tab). Flows that Android ends with
  `NavigateToBackStack` (pop up to Home) use `context.go(Routes.home)`.
- Do not put Cubits for screens at the app root; only `SessionCubit` lives there.
