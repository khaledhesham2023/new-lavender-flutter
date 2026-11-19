# Lavender — Android → Flutter migration plan

Read `docs/migration/CONTEXT.md` for everything about the Android app. This file holds the decisions, the
target structure, the conventions every task must follow, and the ordered task list.

---

## 1. Decisions (made by the owner)

| # | Topic | Decision |
|---|---|---|
| D1 | Platforms | **Android only** for now. Keep Dart code platform-neutral (no `dart:io` Platform checks unless needed), but do not configure iOS. |
| D2 | Location | Flutter app in **`D:\flutter\New folder\lavender-flutter`** — a sibling of this repo (`../lavender-flutter`), its own folder/git repo. Android code in `lavenderk/app/` stays untouched. Docs stay in `lavenderk/docs/migration/`. |
| D3 | Identity | Same applicationId **`com.alalmiya.lavender`**, same release keystore → ships as an update. Version **kept as the Android app: versionName `1.0`, versionCode `1`** (owner decision; the owner bumps it when releasing). Release signed with the same keystore the Android app uses (`app/PlayStore/key.jks`); signing secrets read from untracked `lavender-flutter/android/key.properties`. |
| D4 | State management | **`flutter_bloc` (Cubits only)**. One Cubit per screen; app-wide `SessionCubit`. No Bloc events, no freezed. **Exception (owner decision, T05): JSON models use `json_serializable` + `build_runner`** (see T05 Notes). |
| D5 | UI | **Same UI 1:1** as the Android layouts. Only platform-idiomatic substitutes (date picker, bottom sheets, toasts) where named in the task. |
| D6 | Unused Android code | **Not ported**: maps, location, camera, ML Kit, Socket.IO, Room, Remote Config, Places, Firebase Auth/Analytics/Perf, WorkManager worker, 6 orphan booking fragments, Huawei flavor, unused permissions. |
| D7 | Crashlytics | **Add `firebase_crashlytics`** (Android only had the dependency). |
| D8 | Notifications | **Fix** Android bugs: create the notification channel, request POST_NOTIFICATIONS on Android 13+, route notification taps on cold start too. |
| D9 | Rate the app | **Open the Play Store listing** (`market://details?id=com.alalmiya.lavender`, fallback https URL). |
| D10 | Guest Authorization | **Omit the `Authorization` header** when there is no token (Android sent `"null"`). |
| D11 | HTTP 401 | **Do nothing** special (same as Android). |
| D12 | Phone rules | **Keep**: fixed `+966`, 9 digits, must start with `5`. |
| D13 | Login migration | Existing Android sessions are **not** migrated; users log in once after the update. |
| D14 | Payment | `go_sell_sdk_flutter` (Tap's plugin). If it cannot do what `TapPaymentHelper.kt` does, the task stops and reports; fallback is a platform channel to `goSellSDK-Android:2.16.1`. |

---

## 2. Packages (pubspec) — add each only in the task that first needs it

| Package | Used for | Added in |
|---|---|---|
| `flutter_bloc` | Cubits, providers | T01 |
| `equatable` | state equality | T01 |
| `json_annotation`, `json_serializable` (dev), `build_runner` (dev) | JSON models (generated `*.g.dart`, committed) | T05 |
| `go_router` | navigation | T01 |
| `flutter_localizations` (sdk), `intl` | l10n, date/number formatting | T02 |
| `flutter_svg` | converted vector drawables | T03 |
| `lottie` | splash/onboarding animations | T03 |
| `cached_network_image` | network images | T04 |
| `shared_preferences` | local storage | T06 |
| `dio` | HTTP | T07 |
| `infinite_scroll_pagination` | notifications paging | T31 |
| `flutter_widget_from_html_core` | HTML content (about/terms/policy) | T35 |
| `photo_view` | certificate viewer | T22 |
| `share_plus` | share doctor link | T22 |
| `url_launcher` | WhatsApp, social links, Play Store | T32 |
| `image_picker` | profile photo | T33 |
| `background_downloader` | report downloads | T28 |
| `go_sell_sdk_flutter` | Tap payment | T37 |
| `firebase_core`, `firebase_messaging`, `flutter_local_notifications` | push | T39 |
| `app_links` | deep links | T40 |
| `firebase_crashlytics` | crash reporting | T41 |

Launcher icons and the native launch screen are **copied** from the Android `res/` in T41 (no icon/splash generator packages).

Dev: `flutter_lints` (default), `xml` (dev, for the tool scripts in T02/T03), `bloc_test` is **not** used — test Cubits with plain `test` + `await cubit.stream.first` if needed.

Use the latest versions that resolve with the installed Flutter 3.47.7 / Dart 3.14 (`flutter pub add <name>`).

---

## 3. Folder structure of `lavender-flutter/`

```
lavender-flutter/
  pubspec.yaml
  l10n.yaml
  env/
    example.json            # committed: keys with dummy values
    debug.json              # NOT committed (gitignored)
    release.json            # NOT committed
  tool/
    strings2arb.dart        # T02: Android strings.xml -> lib/l10n/app_en.arb, app_ar.arb
    vd2svg.dart             # T03: Android vector drawables -> assets/svg/*.svg + lib/core/theme/app_assets.dart
  assets/
    fonts/                  # copied .ttf
    images/                 # png/jpg (+ images/ar/ for drawable-ar)
    svg/                    # converted vectors
    gifs/                   # loader.gif, success_gif.gif
    lottie/                 # json animations
  android/                  # generated by flutter create, edited in T01/T39/T40/T41
  lib/
    main.dart               # bootstrap: prefs, ApiClient, repositories, SessionCubit, runApp
    app.dart                # LavenderApp: MaterialApp.router, theme, locale, l10n delegates
    l10n/                   # app_en.arb, app_ar.arb (+ generated code via flutter gen-l10n, synthetic package off)
    core/
      config/env.dart       # String.fromEnvironment for BASE_URL, HOST_URL, HOST, PAYMENT_KEY
      network/
        api_client.dart     # Dio setup, headers, call() maps a Retrofit response to ApiResult
        lavender_api.dart   # @RestApi interface with every endpoint (lavender_api.g.dart is generated)
        api_result.dart     # sealed ApiResult / ApiFailure
      storage/
        app_prefs.dart      # typed wrapper over SharedPreferences (CONTEXT §6.1)
        user_store.dart     # UserData (CONTEXT §6.2) as JSON in prefs
      session/session_cubit.dart   # isLoggedIn, language, user; login/logout/changeLanguage
      theme/
        app_colors.dart     # every colors.xml entry used
        app_text_styles.dart
        app_theme.dart
        app_assets.dart     # generated by tool/vd2svg.dart + hand-added png/gif/lottie paths
      l10n/l10n_ext.dart    # extension BuildContext.l10n
      utils/
        date_utils.dart     # ports of the date/time helpers
        number_utils.dart   # formatDecimal, formatPercentage, truncate1
        validators.dart     # phone/password/name/email rules
        launchers.dart      # url_launcher wrappers (T32)
      widgets/              # shared widgets (T04): progress_button, app_toast, state_view,
                            # star_rating, app_network_image, app_back_button, bottom_sheet_frame,
                            # success_dialog, must_login_sheet, loading_view, debounced_search_field
      push/                 # T11 stub device_token.dart; T39: push_service.dart (token, channel, handlers)
      deeplink/             # T40: deep_link_service.dart, doctor_link.dart
    data/
      models/               # one file per CONTEXT §5.4 group (user.dart, doctor.dart, appointment.dart, offer.dart, ...)
      repositories/         # auth_repository.dart, profile_repository.dart, general_repository.dart,
                            # notifications_repository.dart, home_repository.dart, specialities_repository.dart,
                            # search_repository.dart, doctor_repository.dart, booking_repository.dart,
                            # favorites_repository.dart, offers_repository.dart
    router/
      app_router.dart       # all routes (T10), redirect logic
      routes.dart           # path constants + extra classes
    features/
      splash/ onboarding/ auth/ shell/ home/ specialities/ offers/ search/ search_details/ filter/
      doctor_details/ booking/ bookings/ appointment_details/ session_details/ favorites/
      notifications/ profile/ my_offers/ purchase_offer/ reports/ content/
        # each feature: <screen>_screen.dart, <screen>_cubit.dart (Cubit + state in one file), widgets/
  test/
    ... mirrors lib/ for models, storage, network, repositories, utils, validators
```

---

## 4. Conventions every task must follow

### 4.1 Running the app
- All Flutter commands run inside `D:\flutter\New folder\lavender-flutter`. Android source paths in the task files (`app/...`, `res/...`) are relative to
  `D:\flutter\New folder\lavenderk`; Flutter paths (`lib/...`, `android/...`, `test/...`, `tool/...`) are relative to `lavender-flutter`.
  From inside `lavender-flutter`, the Android repo is `../lavenderk`.
- Run: `flutter run --dart-define-from-file=env/debug.json` (needs `env/debug.json`; T01 creates it from `env/example.json` with the values from `lavenderk/README.md`).
- Checks after every task: `flutter analyze` → **No issues found**; `flutter test` → all pass; `flutter build apk --debug --dart-define-from-file=env/debug.json` → succeeds.

### 4.2 Networking
- Endpoints are declared once in `LavenderApi` (Retrofit, `@RestApi`, generated with `dart run build_runner build`). Its methods return the raw `HttpResponse`.
- `ApiClient.call<T>((api) => api.login(body), parse: ...)` runs one of them and returns `Future<ApiResult<T>>`; repositories use only that.
- `ApiResult<T>` is sealed: `ApiSuccess<T>(T data, String message)` | `ApiFailure` subclasses
  `ServerFailure(int code, String message)`, `NetworkFailure()`, `UnknownFailure(String message)`.
- Mapping mirrors CONTEXT §5.2: non-2xx with a JSON body having `message` → `ServerFailure`; non-2xx without parseable
  body → `UnknownFailure`; `DioExceptionType.connectionTimeout/sendTimeout/receiveTimeout/connectionError` and
  `SocketException` → `NetworkFailure`; JSON parse errors → `UnknownFailure`.
- Repositories take `ApiClient` and return `Future<ApiResult<Model>>`. No use-case layer.
- The client adds headers itself (CONTEXT §5.1) reading `AppPrefs` for language and token; `Authorization` only when a token exists (D10).

### 4.3 State
- Each screen has one Cubit in `<screen>_cubit.dart`, with an immutable state class (extends `Equatable`, `copyWith`).
- Common fields: `ViewStatus status` (`initial, loading, success, failure`) and `ApiFailure? failure` from `core/network/api_result.dart`.
- One-shot effects (navigate, toast) are separate status values or fields like `actionStatus`; the screen reacts in a
  `BlocListener` and the Cubit resets them. Never navigate from inside a Cubit.
- App-wide state only in `SessionCubit` (T10): `isLoggedIn`, `languageCode`, `UserData? user`.
- Android activity-scoped shared ViewModels are **replaced** by: arguments passed in route `extra`; results returned
  from `showModalBottomSheet`/`context.push<T>()`; and `SessionCubit`. Each task says which.

### 4.4 Errors shown to the user (port of `CommonUtils.handleAllKindOfExceptions` + `EmptyErrorDelegateImp`)
- `showFailureToast(context, failure)` (T04): `ServerFailure` → toast its message (failed style);
  `NetworkFailure` → `l10n.connectionError`; `UnknownFailure` → its message or `l10n.connectionError` if empty.
- `StateView` widget (T04) = the empty/error layout: `StateView.serverError(...)`, `StateView.connectionLost(onRetry)`,
  `StateView.empty(icon, title, body, buttonTitle?, onButton?)`.
- Each screen task states which one to use where (copy the Android fragment's `observeAllErrors`).

### 4.5 Navigation
- `go_router`. All paths are constants in `lib/router/routes.dart`. T10 registers **every** route of the app with a
  `PlaceholderScreen`; each screen task replaces its placeholder builder. Never add a route outside `app_router.dart`.
- Typed arguments go in `extra` (classes in `routes.dart`); numeric ids go in path params.
- Bottom sheets and dialogs are **not** routes: each is a function `Future<T?> showXxxSheet(BuildContext, ...)` in its feature folder.
- "Start Main clearing the stack" = `context.go(Routes.home)`. "Start Auth on top" (AuthActivity.start without finish)
  = `context.push(Routes.authStart)`. "Start Auth and finish" = `context.go(Routes.authStart)`.
- Android back-button overrides (`onBackPressedDispatcher`) become `PopScope(canPop: false, onPopInvokedWithResult: ...)`.

### 4.6 UI
- Read the Android layout XML for each screen (binding class name → layout file, e.g. `FragmentHomeBinding` →
  `app/src/main/res/layout/fragment_home.xml`, follow `<include>`s). Reproduce sizes (dp → logical px, sp → font size),
  colors, fonts, paddings, corner radii, icons.
- Colors only via `AppColors`, text styles via `AppTextStyles`, icons/images via `AppAssets`.
- Strings only via `context.l10n.<key>` (keys = Android string names in lowerCamelCase, generated in T02).
- Numbers/prices: `core/utils/number_utils.dart` (English digits always). Dates/times: `core/utils/date_utils.dart`.
- RTL comes from the locale; use `EdgeInsetsDirectional`/`AlignmentDirectional`, never left/right, unless the Android layout forces it.
- Status bar: Android sets colors per screen; use `AnnotatedRegion<SystemUiOverlayStyle>` with the same color/icon brightness.

### 4.7 Tests
- Unit tests for models (`fromJson` with realistic JSON), storage, ApiClient error mapping, repository request building,
  date/number utils, validators, and non-trivial Cubit logic. No widget-golden tests. No tests just for coverage.

### 4.8 Work rules
- One task per session. Do not start the next task. Do not change Android files. Do not commit.
- If the task file is wrong or blocked, stop and report — do not redesign.
- At the end: run the "Done when" checks, tick the box below, append a `## Notes` section to the task file.

---

## 5. Task checklist (in order)

### Setup and foundation
- [x] T01 - Flutter project setup (depends on: -)
- [x] T02 - Strings and localization (depends on: T01)
- [x] T03 - Assets, fonts and theme (depends on: T01)
- [x] T04 - Shared utils and widgets (depends on: T02, T03)

### Models and data layer
- [x] T05 - Data models (depends on: T01)
- [x] T06 - Local storage (depends on: T05)
- [x] T07 - Network client (depends on: T06)
- [x] T08 - Repositories: auth, profile, general, notifications (depends on: T07)
- [x] T09 - Repositories: home, specialities, search, doctor, booking, favorites, offers (depends on: T07)

### Navigation shell
- [x] T10 - Session, router and bottom-nav shell (depends on: T04, T08)

### Screens
- [x] T11 - Splash and onboarding (depends on: T10)
- [x] T12 - Start now and login (depends on: T10)
- [ ] T13 - Register (depends on: T12)
- [x] T14 - OTP and success dialog (depends on: T12)
- [ ] T15 - Forget password, new password, success screen (depends on: T14)
- [x] T16 - Home (depends on: T09, T10)
- [x] T17 - All specialities (depends on: T16)
- [x] T18 - Offers list and offer details (depends on: T16)
- [x] T19 - Search (last search and results) (depends on: T16)
- [x] T20 - Search details and sort sheet (depends on: T19)
- [ ] T21 - Filter screen and subspecialties sheet (depends on: T20)
- [ ] T22 - Doctor details: header, info tab, reviews tab (depends on: T20)
- [ ] T23 - Doctor details: booking time tab and day/time picker (depends on: T22)
- [ ] T24 - Book appointment, change appointment sheet, successful request (depends on: T23)
- [ ] T25 - Appointment type sheet, book with offer, successful request with offer (depends on: T24)
- [ ] T26 - Bookings tab (list, tabs, search, filters) (depends on: T24)
- [ ] T27 - Booking actions: confirmation, rebook/change, add comment (depends on: T26)
- [ ] T28 - Appointment details and report download (depends on: T27)
- [ ] T29 - Session details (depends on: T28)
- [ ] T30 - Favorites (depends on: T22)
- [ ] T31 - Notifications screen (depends on: T28, T29)
- [ ] T32 - Profile tab, logout/delete sheet, language sheet (depends on: T10)
- [ ] T33 - Edit profile and change phone OTP (depends on: T32, T14)
- [ ] T34 - Change password flows from profile (depends on: T33)
- [ ] T35 - Contact us, about app, about us, terms, privacy (depends on: T32)
- [ ] T36 - My offers and my offer details (depends on: T29, T32)
- [ ] T37 - Purchase offer (Tap payment) and successful purchase (depends on: T18, T35)
- [ ] T38 - My reports (depends on: T28, T32)

### Native features and SDKs
- [ ] T39 - Firebase and push notifications (depends on: T31, T36, T38)
- [ ] T40 - Deep links for doctor pages (depends on: T22)

### Release
- [ ] T41 - Release config: icons, native splash, signing, version, Crashlytics, manifest (depends on: T39, T40)

### Final
- [ ] T42 - Parity check against the Android app (depends on: all)

---

## 6. Coverage table (Android → task)

| Android screen / feature | Android file | Task |
|---|---|---|
| Project config, applicationId, minSdk | `app/build.gradle.kts` | T01, T41 |
| BuildConfig URLs/keys | `app/build.gradle.kts`, `README.md` | T01 |
| strings en/ar | `res/values*/strings.xml` | T02 |
| Locale switching at runtime | `ParentActivity.kt`, `CommonUtils.changeLanguage` | T02, T10, T32 |
| Colors, fonts, theme, dimens | `res/values/*`, `res/font/*` | T03 |
| Drawables, GIFs, Lottie, launcher icon | `res/drawable*`, `res/raw`, `res/mipmap*` | T03, T41 |
| Toaster / custom toasts | `utils/views/Toaster.kt` | T04 |
| ProgressButton | `utils/views/ProgressButton*.kt` | T04 |
| CustomRatingBar | `utils/views/rateBar/*` | T04 |
| Empty/error view | `base/delegate/emptyOrError/*` | T04 |
| Global error handling | `CommonUtils.handleAllKindOfExceptions` | T04, T07 |
| Date/number helpers | `utils/extensions/ViewExtFunctions.kt`, `CommonUtils.kt` | T04 |
| SuccessDialog | `presentation/auth/success/SuccessDialog.kt` | T04 (widget), T14, T27 |
| MustLoginSheet | `presentation/sheets/screen/MustLoginSheetFragment.kt` | T04 |
| Models | `data/models/**` | T05 |
| Preferences + proto DataStore | `data/datasource/local/**`, `proto/data.proto` | T06 |
| Retrofit/OkHttp client, NetworkResponse | `di/AppModule.kt`, `data/datasource/remote/**` | T07 |
| Auth/profile/general/notifications APIs | `ServiceApi.kt`, `data/repository/*` | T08 |
| Home/specialities/search/doctor/booking/favorites/offers APIs | `ServiceApi.kt`, `data/repository/*` | T09 |
| GeneralViewModel, login state | `base/GeneralViewModel.kt` | T10 |
| Nav graphs, nav controllers | `res/navigation/*`, `*NavigationController.kt` | T10 (+ each screen task) |
| MainActivity bottom nav | `presentation/home/MainActivity.kt`, `res/menu/main_menu.xml` | T10 |
| SplashActivity | `presentation/splash/SplashActivity.kt` | T11 |
| OnboardingActivity | `presentation/onboarding/screen/OnboardingActivity.kt` | T11 |
| StartNowFragment | `presentation/auth/startnow/` | T12 |
| LoginFragment | `presentation/auth/login/` | T12 |
| RegisterFragment | `presentation/auth/register/` | T13 |
| OtpFragment | `presentation/auth/otp/` | T14 |
| AuthViewModel (timer, save session) | `presentation/auth/AuthViewModel.kt` | T12, T14 |
| ForgetPassword / NewPassword / SuccessFragment | `presentation/auth/newPassword/`, `auth/success/SuccessFragment.kt` | T15 |
| HomeFragment + adapters | `presentation/home/` | T16 |
| AllSpecialitiesFragment | `presentation/allspecialities/` | T17 |
| OffersFragment | `presentation/offers/` | T18 |
| OfferDetailsFragment | `presentation/offerdetails/` | T18 |
| LastSearchFragment, SearchResultFragment | `presentation/lastsearch/` | T19 |
| SearchDetailsFragment | `presentation/searchdetails/` | T20 |
| SortBySheet | `presentation/filter/sheet/SortBySheet.kt` | T20 |
| FilterFragment, SubSpecialtiesSheet | `presentation/filter/` | T21 |
| DoctorDetailsFragment, GeneralInfoFragment, ReviewsFragment | `presentation/doctordetails/`, `generalinfo/`, `reviews/` | T22 |
| Certificates image viewer | `utils/helpers/zoom/CertificateHelper.kt` | T22 |
| Share doctor link | `DoctorDetailsFragment.kt` | T22 |
| BookingAppointmentsFragment, BookingDaysAdapter, AvailableTimesAdapter, calendar picker | `presentation/bookingappointments/`, `utils/utilities/AvailableDatesValidator.kt` | T23 |
| CalenderDateAndTimeSheet | `presentation/filter/sheet/CalenderDateAndTimeSheet.kt` | T23 (not reachable from any UI; replaced by date picker) |
| BookAppointmentFragment | `presentation/bookappointment/` | T24 |
| ChangeAppointmentSheetFragment | `presentation/sheets/screen/ChangeAppointmentSheetFragment.kt` | T24 |
| SuccessfulAppointmentRequestFragment | `presentation/successfulappointmenttrequest/` | T24 |
| AppointmentTypeSheetFragment | `presentation/appointmenttype/` | T25 |
| BookAppointmentWithOfferFragment | `presentation/bookappointmentwithoffer/` | T25 |
| SuccessfulAppointmentRequestFragmentWithOffer | `presentation/successfulappointmentrequestwithoffer/` | T25 |
| BookingsFragment, BookingAdapter, BookingSearchViewModel | `presentation/bookings/`, `bookingsearch/screen/BookingSearchViewModel.kt` | T26 |
| FilterByDateSheet, FilterByTypeSheet | `presentation/sheets/screen/` | T26 |
| ConfirmationSheetFragment | `presentation/sheets/screen/` | T27 |
| ChooseRebookAppointmentSheetFragment | `presentation/sheets/screen/` | T27 |
| AddCommentSheetFragment | `presentation/addComment/` | T27 |
| AppointmentDetailsFragment | `presentation/appointmentdetails/` | T28 |
| File download (DownloadManager) | Appointment/Session details, MyReports | T28, T29, T38 |
| SessionDetailsFragment | `presentation/sessiondetails/` | T29 |
| FavoritesFragment | `presentation/favorites/` | T30 |
| NotificationsFragment + paging | `presentation/notifications/`, `data/paging/` | T31 |
| ProfileFragment | `presentation/profile/screen/` | T32 |
| GeneralSheet (logout/delete) | `presentation/profile/sheet/GeneralSheet.kt` | T32 |
| ChangeLanguageSheet | `presentation/profile/sheet/ChangeLanguageSheet.kt` | T32 |
| Rate the app → Play Store | `ProfileFragment.kt` | T32 |
| EditProfile (image upload) | `presentation/profile/editProfile/EditProfile.kt`, `utils/UploadImages.kt` | T33 |
| OtpChangePhoneFragment | `presentation/profile/editProfile/otp/` | T33, T34 |
| SuccessChangePhoneSheet | `presentation/profile/sheet/SuccessChangePhoneSheet.kt` | T33 |
| EditProfileAddNewPasswordFragment, ForgetPasswordForEditPasswordFragment | `presentation/profile/addNewPassword/` | T34 |
| ContactUsFragment (WhatsApp) | `presentation/profile/contactUs/` | T35 |
| AboutFragment, AboutUsFragment | `presentation/profile/about*/` | T35 |
| TermsOfUseFragment, PrivacyPolicyFragment | `presentation/profile/privacypolicy/` | T35 |
| MyOffersFragment | `presentation/myoffers/` | T36 |
| MyOfferDetailsFragment (+ bookings & info tabs) | `presentation/myofferdetails/` | T36 |
| PurchaseOfferFragment, TapPaymentHelper | `presentation/purchaseoffer/`, `utils/tapPayment/` | T37 |
| SuccessfulOfferPurchaseFragment | `presentation/successfulofferpurchase/` | T37 |
| MyReportsFragment | `presentation/myreports/` | T38 |
| FCM service, token, notification display | `fcm/*` | T39 |
| Notification tap routing | `MainActivity.handleNotificationNavigation` | T39 |
| App Links `/doctor/{id}` | `AndroidManifest.xml`, `MainActivity.handelAppLinks` | T40 |
| Crashlytics | `app/build.gradle.kts` | T41 |
| Signing, versionCode, launcher icon, splash theme | `app/build.gradle.kts`, `res/mipmap*`, `Theme.Splash` | T41 |
| Unused code (maps, location, camera, socket, room, worker, …) | see CONTEXT §8 | not ported (D6) |
