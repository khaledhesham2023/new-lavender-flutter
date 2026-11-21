# Lavender — Android app context (source of truth for the Flutter port)

Everything here was learned by reading the Android project. Paths are relative to the repo root.
Kotlin sources live under `app/src/main/java/com/alalmiya/lavender/` — abbreviated below as `K/`.
Resources live under `app/src/main/res/` — abbreviated as `R/`.

---

## 1. What the app is

**Lavender** is a patient-side medical booking app (client: Al-Alamiya, backend host in Doha, phone rules are Saudi).
Users browse specialties and doctors, book / change / cancel / rebook appointments, buy prepaid
"offers" (session packages, paid with Tap Payments), read medical reports (radiology / laboratory PDFs),
receive push notifications, and manage their profile. A guest mode lets users browse without logging in;
booking, favorites, bookings, notifications and offers purchase require login.

Languages: Arabic (default) and English. RTL is supported. Portrait only. Dark mode forced off.

---

## 2. Build setup

| Item | Value | Where |
|---|---|---|
| Modules | single `:app` | `settings.gradle.kts` |
| applicationId / namespace | `com.alalmiya.lavender` | `app/build.gradle.kts` |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 | `app/build.gradle.kts` |
| versionCode / versionName | 1 / "1.0" (Flutter keeps the same — owner decision) | `app/build.gradle.kts` |
| Kotlin / AGP | 1.9.24 / 8.13.1 | `gradle/libs.versions.toml` |
| Flavors | dimension `provider`: `google` (suffix GMS), `huawei` (suffix HMS). Only difference: `R/../google|huawei/res/layout/location_map_fragment_layout.xml` (unused map fragment) | `app/build.gradle.kts`, `app/src/google`, `app/src/huawei` |
| Build types | debug (debug signing), release (release signing, minify off) | `app/build.gradle.kts` |
| Locales packed | `en`, `ar` | `resourceConfigurations` |
| Signing | reads `KEY_STORE_PATH`, `KEY_STORE_PASS`, `KEY_ALIAS_NAME`, `KEY_ALIAS_PASS` from `local.properties`; keystore file `app/PlayStore/key.jks` (committed to git!) | `app/build.gradle.kts`, `README.md` |
| BuildConfig fields | `HOST_URL`, `BASE_URL`, `SOCKET_URL`, `PAYMENT_KEY` (debug = Tap test key, release = Tap live key) from `local.properties` | `app/build.gradle.kts` |
| resValues | `MAP_KEY` (Google Maps key), `HOST` (deep-link host) | `app/build.gradle.kts` |
| Firebase project | `lavender-94083`, file `app/google-services.json` | — |

Current values (from `README.md`): host `lavander.doha.aait-d.com`, base URL `https://lavander.doha.aait-d.com/api/`
for **both** debug and release. Debug and release differ only by the Tap key. **Do not copy the keys
into new committed files** — the Flutter app reads them from an untracked env file (see PLAN.md).

---

## 3. AndroidManifest (`app/src/main/AndroidManifest.xml`)

Activities (all portrait):
- `presentation.splash.SplashActivity` — LAUNCHER, theme `Theme.Splash`.
- `presentation.onboarding.screen.OnboardingActivity`.
- `presentation.auth.AuthActivity` — hosts `R/navigation/auth_nav_graph.xml`.
- `presentation.home.MainActivity` — hosts `R/navigation/main_nav_graph.xml` + bottom navigation. Exported, has
  App Links intent filters: `https://<HOST>/doctor*` (autoVerify) and `http://<HOST>/doctor`.

Service: `fcm.FirebaseMessagingService` (`com.google.firebase.MESSAGING_EVENT`).

Meta-data: Google Maps API key (unused by any screen).

Permissions declared: RECORD_AUDIO, VIBRATE, MODIFY_AUDIO_SETTINGS, READ_MEDIA_AUDIO/IMAGES/VIDEO, CAMERA,
READ/WRITE_EXTERNAL_STORAGE, CALL_PHONE, INTERNET, READ_PHONE_STATE, READ_PHONE_NUMBERS, ACCESS_COARSE/FINE_LOCATION,
READ_CONTACTS, POST_NOTIFICATIONS, ACCESS_NOTIFICATION_POLICY, AD_ID, WAKE_LOCK, BLUETOOTH*, FOREGROUND_SERVICE*,
SYSTEM_ALERT_WINDOW. **Actually needed by used features:** INTERNET, POST_NOTIFICATIONS, (image picker handles its
own media access), VIBRATE optional. Everything else belongs to unused code.

`allowBackup=false`, `supportsRtl=true`.

---

## 4. Architecture

- **Pattern:** MVVM + Clean-ish layers. `presentation/*` (Fragments + ViewModels) → `domain/usecases/*` (one-line
  pass-throughs) → `domain/repository/*` interfaces → `data/repository/*Impl` → `data/datasource/remote/ServiceApi.kt` (Retrofit).
- **DI:** Hilt. `K/di/AppModule.kt` (Retrofit, OkHttp), `K/di/DataStoreModule.kt`, `K/di/RepositoryModule.kt`.
- **Threading:** coroutines; repositories return `Flow<NetworkResponse<T, BaseResponse>>` emitting `Loading` then one result.
- **ViewModels:** extend `K/base/BaseViewModel.kt`. Pattern: `setStateEvent(SomeState)`; success results go to a
  dedicated `MutableSharedFlow`; *everything else* (Loading, ApiError, NetworkError, UnknownError) goes to a shared
  `error` SharedFlow. Fragments collect `error` and switch on the type (Loading → show progress).
- **Shared (activity-scoped) ViewModels pass data between screens:**
  - `K/presentation/doctordetails/DoctorDetailsSharedViewModel.kt` — selected doctor, chosen date/day/time/formatted date,
    `BookingRequestModel`, offers, selected offer, `dateFromCalender`, review data.
  - `K/presentation/bookings/screen/BookingsSharedViewModel.kt` — flags: canceled/confirmed/updated/marked-to-confirm,
    `UpdateAppointmentRequest`, appointment id, filter by date/type, `dateAndTimeFromSheetToBook` (ChangeAppointmentRequest),
    add-comment success.
  - `K/presentation/searchdetails/screen/SearchDetailsSharedViewModel.kt` — filter: subspecialties, sort, gender, min/max price, `filterIsApplied`, `previousSelectedSubSpecialties`.
  - `K/presentation/lastsearch/screen/SearchResultSharedViewModel.kt` — search results + selected tab.
  - `K/presentation/profile/screen/ProfileSharedViewModel.kt` — `markedForLogout`.
- **Navigation:** Jetpack Navigation with Safe Args; every transition goes through
  `K/presentation/auth/AuthNavigationController.kt`, `K/presentation/home/MainNavigationController.kt`,
  `K/presentation/profile/ProfileNavigationController.kt` (sealed event classes → `navController.navigate`).
- **Base classes:** `K/base/ParentActivity.kt` (applies saved locale on every activity create), `ParentFragment.kt`,
  `ParentSheetFragment.kt` (BottomSheetDialogFragment; `isCancel`, `isFull` → expanded), `ParentDialogFragment.kt`.
- **Empty/error view:** `K/base/delegate/emptyOrError/EmptyErrorDelegateImp.kt` — an included layout with icon, title,
  body, optional button. Types: SERVER_ERROR_VIEW, CONNECTION_LOST_VIEW, EMPTY_LIST_VIEW (+ unused ones).
- **Global error toast:** `K/utils/utilities/CommonUtils.kt` → `handleAllKindOfExceptions()`:
  ApiError → parse body as `BaseResponse` and toast `message` (FAILED style); network/timeout/IO errors → toast
  `R.string.connection_error`; other throwable → toast its message. Toasts: `showCustomToast(ctx, msg, MessageStatus)`
  using `K/utils/views/Toaster.kt` custom layouts (`success_custome_toast`, `failed_custome_toast`,
  `warning_custome_toast`, `normal_custome_toast`, `failed_attempts_custome_toast`), shown at the **top** of the screen.
- **Custom views:** `K/utils/views/ProgressButton.kt` / `ProgressButtonSmall.kt` (button with inline spinner,
  `setLoading`, `setEnable`), `rateBar/CustomRatingBar*.kt` (star rating; read-only in most places, interactive in add-comment),
  `EditTextValidation.kt`.

---

## 5. Network

### 5.1 Client (`K/di/AppModule.kt`)
- Base URL `BuildConfig.BASE_URL` (`https://lavander.doha.aait-d.com/api/`).
- Timeouts 25 s connect/read/write. Logging BODY.
- Headers on every request: `Accept: application/json`, `Content-Type: application/json`,
  `lang: <appLanguage or "ar">`, `Accept-Language: <same>`, `os: <deviceType or "android">`, `type: <same>`.
  (deviceType is never saved, so it is effectively always `android`.)
- **Authorization** is passed per endpoint as `@Header("Authorization")` with `dataStoreRepo.bearerToken`.
  The stored token is `"Bearer <token>"`. **Bug:** when no token is stored the getter returns the string `"null"`,
  so guests send `Authorization: null`. → Flutter decision: omit the header when there is no token.
- 401 handling: empty `if` — nothing happens. → Flutter decision: do nothing as well.
- Bodies are JSON (Gson). Multipart only for image upload.

### 5.2 Response wrapper
- `K/data/models/base/BaseResponse.kt`: `{ code: Int?, status: String, message: String }`. All responses extend it and add `data`.
- `K/data/datasource/remote/network/NetworkResponse*.kt`: Success(body) / ApiError(errorBody parsed as BaseResponse, http code)
  / NetworkError(IOException) / UnknownError(throwable). A 2xx with null body → UnknownError. Non-2xx with an
  unparseable or empty body → UnknownError.
- Pagination wrapper (notifications only): `meta {current_page, last_page, per_page, total, ...}`, `links {first,last,prev,next}`.

### 5.3 Endpoints (`K/utils/constants/Urls.kt`, `K/data/datasource/remote/ServiceApi.kt`)
"Auth" = sends Authorization header (when logged in).

| Method | Path | Auth | Params / body | Response `data` |
|---|---|---|---|---|
| POST | `client/login` | – | AuthRequest{phone, phone_code, device_token, device_type, password} | UserModel |
| POST | `client/register` | – | AuthRequest{phone, phone_code, full_name, email, password, password_confirmation, terms_and_conditions=1} | UserModel |
| POST | `client/verify` | – | AuthRequest{phone, phone_code, device_token, device_type, otp} | UserModel |
| POST | `client/resend` | – | AuthRequest{phone, phone_code} | UserModel |
| POST | `client/password/reset` | – | AuthRequest{phone, phone_code} | UserModel |
| POST | `client/password/verify` | Auth | AuthRequest{phone, phone_code, otp} | UserModel |
| POST | `client/password/change` | – | AuthRequest{phone, phone_code, password, password_confirmation?, otp} | – |
| POST | `client/logout` | Auth | AuthRequest{device_token} | – |
| GET | `client/user` | Auth | – | UserModel |
| POST | `client/user/update-profile` | Auth | AuthRequest{full_name?, email?, image?} | UserModel |
| POST | `client/user/update-phone` | Auth | AuthRequest{phone, phone_code} | – |
| POST | `client/user/verify` | Auth | AuthRequest{phone, phone_code, otp} | UserModel |
| POST | `client/user/change-password` | Auth | AuthRequest{current_password, password, password_confirmation} | – |
| DELETE | `client/user` | Auth | – | – (delete account) |
| POST | `client/contact` | Auth | **query** full_name, title, content | – |
| GET | `client/about` | Auth | – | AboutModel (about us: html `name`, `images[]`) |
| GET | `client/about-app` | Auth | – | AboutModel (html `name`, `links[]`) |
| GET | `client/term` | Auth | – | AboutModel (html in `name`) |
| GET | `client/policy` | Auth | – | AboutModel (html in `name`) |
| POST | `client/user/change-lang` | Auth | **query** lang | – |
| GET | `client/notifications` | Auth | query page | NotificationModel[] (+meta/links) |
| GET | `client/notifications/read-all` | Auth | – | (unused by UI) |
| DELETE | `client/notifications/{id}` | Auth | – | – |
| GET | `client/notifications/read/{id}` | Auth | – | – |
| POST | `client/user/allow-notifications` | Auth | query `_method=PUT` | {allow_notification} |
| GET | `client/home` | Auth | – | HomeData |
| POST | `client/fav` | Auth | {doctor_id: String} (toggle) | – |
| GET | `client/fav` | Auth | query doctor_name? | DoctorModel[] |
| GET | `client/specialty` | Auth | – | SpecialityModel[] |
| GET | `client/specialty/{id}` | Auth | query sort_by?, gender?, max_price?, min_price?, doctor_name?, `sub_specialty[0]=id`, `sub_specialty[1]=id`… (encoded=true) | {doctors[], count} |
| GET | `client/search/most` | – | – | SpecialityModel[] |
| GET | `client/search` | Auth | – | SearchResultModel[] (recent) |
| POST | `client/search` | Auth | query keyword | {doctors[], specialties[]} |
| DELETE | `client/search/clear` | Auth | – | – |
| GET | `general/filter-details/{specialtyId}` | Auth | – | FilterData{specialties[] (sub-specialties), max_price, min_price} |
| GET | `general/doctor/{id}` | Auth | – | DoctorModel (full) |
| GET | `general/work-times/{doctorId}` | Auth | – | WorkTimeModel[] (**not wrapped in BaseResponse**; 404 = no times) |
| GET | `general/quick-comments` | Auth | – | QuickComment[] |
| GET | `general/countries` | – | – | (unused by UI) |
| POST | `general/attachments` | – | multipart part `file`; query model=`users`, attachment_type=`image` | String (uploaded file name/url) |
| GET | `general/settings` | Auth | – | {allow_notification, whats_app_number} |
| POST | `client/appointments` | Auth | SaveAppointmentRequest{doctor_id, day (yyyy-MM-dd), time, user_offer_id?, notes?} | AppointmentData |
| GET | `client/appointments` | Auth | query status, month?, keyword?, type? | AppointmentData[] |
| GET | `client/appointments/{id}` | Auth | – | AppointmentData (also used for offer sessions) |
| POST | `client/appointments/{id}` | Auth | no body = **cancel**; body UpdateAppointmentRequest{doctor_id, day, time, _method:"put"} = **change** | – |
| POST | `client/appointments/recreate/{id}` | Auth | RebookRequest{day, time} | AppointmentData |
| POST | `client/reviews` | Auth | AddCommentRequest{rate?, comment, doctor_id, client_appointment_id} (quick_comment_id never sent) | – |
| GET | `client/my-reports` | Auth | query type = radiology/laboratory | DayReportsModel[] |
| GET | `client/offers` | – | query specialty_id | OfferModel[] |
| GET | `client/offers/{id}` | – | – | OfferModel |
| POST | `client/offers` | Auth | {offer_id} (after Tap payment success) | OfferModel (user offer, `id` used next) |
| GET | `client/my-offers` | Auth | – | {available_offers[], completed_offers[]} |
| GET | `client/my-offers/{id}` | Auth | – | OfferModel (with appointments[]) |
| GET | `client/session/{id}` | Auth | – | SessionDetailsModel |
| POST | `""` (UPDATE_DEVICE_TOKEN) | Auth | – | used only by unused `UpdateTokenWorker` — skip |

Note `client/specialty/{id}` query `sub_specialty[i]` keys are sent **unencoded** (`sub_specialty[0]`), not `%5B0%5D`.

### 5.4 Models (`K/data/models/**`)
JSON field names are snake_case exactly as in the Kotlin fields unless `@SerializedName` says otherwise. All fields nullable
unless noted. Key ones:
- **UserModel**: id, name, image, email, country{CountryModel}, city{id,name}, phone_code, phone, gender, lang,
  is_admin_active_user, phone_complete_form, unread_notifications, is_ban, is_verified, allow_notification,
  is_completed_data, token, user_type.
- **CountryModel**: id, name, nationality, phone_code, show_phone_code, image, short_name, phone_number_limit, national_id_limit, prefix[].
- **DoctorModel**: id, name, about, specialty, sub_specialty, image, gender, duration (String), price (String),
  experience (String), work_times[WorkTimeModel], is_fav (bool, default false), doctor_work_times_days[String],
  reviews_count, reviews[ReviewModel], rate (num), stars (num), five/four/three/two/one (num), user_offers[OfferModel],
  certificates[{id, media}].
- **WorkTimeModel**: day, day_translated, date (ISO `yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'`), times[TimeModel], formated_date, is_active (int 0/1). UI-only: isSelected.
- **TimeModel**: time, is_reserved (bool), time_formatted (this is what is **sent** to the API as `time`).
- **ReviewModel**: id, rate, created_at, comment, client_name, client_image.
- **AppointmentData**: id, doctor{DoctorModel}, day, status, status_trans, from, to, date_timeStamp, formated_date,
  notes, is_reviewed (default false), report (String URL), offer{OfferModel}, can_reschedule (default **true**).
- **SessionDetailsModel**: id, doctor, offer, formated_date, can_reschedule (default false), date_timeStamp, notes,
  status, status_trans, from, to, number, used_number, is_reviewed, report.
- **OfferModel**: id, name, description, details, price, specialty, discount, final_price, number, image, used_number,
  created_at, start_date, end_date, specialty_model{SpecialityModel}, appointments[AppointmentData].
- **SpecialityModel**: id (non-null int), image, name, appointments_count (default 0).
- **BannerModel**: id, offer_id, is_active, start_date, end_date, image (all non-null in Kotlin).
- **HomeData**: notifications_count, next_reservation{id, day, time, datetime, doctor, difference (seconds, Long)},
  user_name, user_image, **bannars** (sic), specialties[], doctors[], offers[].
- **NotificationModel**: id (String UUID), title, body, data{notify_id (int), notify_type}, is_readed, read_at,
  sending_time, sending_time_ago, date_formated.
- **FilterData**: specialties[SubSpecialtiesData{id, image, name}], max_price, min_price.
- **SearchResultsData**: doctors[], specialties[]. **SearchResultModel**: id, search.
- **DayReportsModel**: date, reports[ReportModel{id, file, title, type, created_at}].
- **AboutModel**: id, image{id, media}, links[{id, key, value}], name (HTML), images[{id, media}].
- **SettingModel**: allow_notification, whats_app_number.
- Enums (`K/utils/enums/`): BookingStatus pending/confirmed/processing/completed/canceled/rejected;
  AppointmentType default/offer/not_offer; OfferType valid/completed; ReportType radiology/laboratory;
  SortByStatus high_to_low_price/low_to_high_price/high_to_low_rate/low_to_high_rate; GenderType male/female;
  NotificationType appointment/offer/report/user_offer.

---

## 6. Local storage

### 6.1 Preferences DataStore (`K/data/datasource/local/preferences/DataStoreRepoImp.kt`, keys in `Keys.kt`)
Store name `LAVENDER_DATA_STORE_NAME`. Used keys (rest are leftovers from another project):

| Key | Type | Default | Meaning |
|---|---|---|---|
| LAVENDER_APP_LANGUAGE | String | `"ar"` | app language |
| LAVENDER_FIRST_TIME | bool | true | show onboarding |
| LAVENDER_LOGIN_STATUS | bool | false | logged in |
| LAVENDER_BEARER_TOKEN | String | – | stored as `"Bearer <token>"` |
| LAVENDER_DEVICE_TOKEN | String | "" | FCM token |
| ALLOW_NOTIFICATIONS | bool | false | from login + settings |
| WHATS_APP_NUMBER | String | "" | from `general/settings`, used by Contact Us |

Logout / delete account: `clearDataStore()` then `appLanguage = "ar"`. So the language resets to Arabic and the
FIRST_TIME key is removed (default true) → the **next cold start shows onboarding again**. Replicate this.

### 6.2 Proto DataStore (`K/data/datasource/local/protoDataStore/ProtoDataRepositoryImpl.kt`, `app/src/main/proto/data.proto`)
`UserData` message mirrors UserModel (id, name, image, email, country, city, phone_code, phone, gender, lang,
is_admin_active_user, phone_complete_form, unread_notifications, is_ban, is_verify, allow_notification,
is_completed_data, token, user_type). Saved after a verified login/verify; `GET client/user` updates only name, phone,
phone_code, image, email. Cleared on logout/delete.

No Room DB is used. No files besides the cache dir for compressed upload images.

Existing users' data is **not** migrated: the Flutter app starts empty, users log in once.

---

## 7. Screens and navigation

### 7.1 App start (`K/presentation/splash/SplashActivity.kt`)
1. Shows Lottie `R/raw/lavender_logo.json` (speed 2x); when it ends shows `R/drawable/loader.gif` playing once (~3.6 s).
2. Fetches the FCM token and saves it.
3. After the GIF: if `isFirstTime` → Onboarding; else if `isLogin` → Main; else → Auth (Start Now).

### 7.2 Onboarding (`K/presentation/onboarding/screen/OnboardingActivity.kt`, `R/layout/activity_onboarding.xml`)
3 pages (title, body, Lottie). Lottie files depend on language: ar → `onbaording_{1,2,3}_ar.json`, en → `onboarding_{1,2,3}_en.json`.
Dots (tab layout, not clickable). "Next" advances; label becomes "Start now" on page 3; tapping it on page 3 saves
`isFirstTime=false` and opens Auth. No swiping. White status bar.

### 7.3 Auth graph (`R/navigation/auth_nav_graph.xml`, start = StartNow)
| Screen | File | Notes |
|---|---|---|
| Start now | `K/presentation/auth/startnow/StartNowFragment.kt` | Sign in, Create account, underlined "Continue as guest" → Main (no flag saved) |
| Login | `K/presentation/auth/login/LoginFragment.kt` | +966 fixed prefix; phone max 9 digits, must start with 5 (first digit not 5 → field cleared + error); password ≥ 8, must start with letter/digit (leading symbol stripped + error). Gets FCM token then `login`. If `is_verified` → Main (clear stack). Else → `resend` code → OTP (fromDestination LOGIN). Back → Start now (pop to start). |
| Register | `K/presentation/auth/register/RegisterFragment.kt` | name (≥2, must start with letter), email optional, phone (same rules), password ≥8, confirm must match, terms checkbox required (link → Terms of use). Success → OTP (fromDestination LOGIN). |
| Forget password | `K/presentation/auth/newPassword/screen/ForgetPasswordFragment.kt` | phone → `password/reset` → OTP (fromDestination RESET_PASSWORD) |
| OTP | `K/presentation/auth/otp/screen/OtpFragment.kt` | 4 boxes, auto-advance, backspace moves back, **auto-submits when 4 digits**, also button. 60 s countdown (`mm:ss`), then "Resend" enabled. LOGIN/REGISTER → `client/verify` with FCM token; if verified → save login/token/user, toast message, Success dialog (type "auth") → Main. RESET_PASSWORD → `password/verify` → New password. Title/subtitle text depends on destination. |
| New password | `K/presentation/auth/newPassword/screen/NewPasswordFragment.kt` | password + confirm → `password/change` with otp → Success fragment |
| Success fragment | `K/presentation/auth/success/SuccessFragment.kt` | success GIF, button & back → Login |
| Success dialog | `K/presentation/auth/success/SuccessDialog.kt` | GIF + title, not cancellable, auto-closes after 2 s; type "auth" → open Main clearing stack; else just dismiss |
| Terms of use | `K/presentation/profile/privacypolicy/screen/TermsOfUseFragment.kt` | shared with profile |

On verified login/verify: save `isLogin=true`, bearer token, `isFirstTime=false`, UserData, `appLanguage = user.lang ?: "ar"`,
`allowNotification = user.allow_notification ?: false`.

### 7.4 Main graph (`R/navigation/main_nav_graph.xml`, start = Home) — `K/presentation/home/MainActivity.kt`
Bottom navigation (`R/menu/main_menu.xml`): Home, Search (LastSearch), Bookings, Favorites, Account (Profile).
Icons are selectors `home_selector`, `search_selector`, `reservation_selector`, `favorites_selector`, `account_selector`;
label colors `R/color/nav_item_text_selector.xml`; background `bg_bottom_navigation_sheet`; always labeled.
Bottom nav is visible only on these 5 destinations; it slides out (300 ms) everywhere else.
Tapping the current tab does nothing. Tabs are plain `navigate` (stack grows; back on Search/Bookings/Favorites/Profile
pops back to Home; back on Home: logged in → finish app, guest → open Auth and finish).

| Screen | File(s) | Behavior summary |
|---|---|---|
| Home | `K/presentation/home/screen/HomeFragment.kt`, `HomeViewModel.kt`, adapters in `home/adapter/` | Calls `client/home` and `general/settings` (saves allow_notification + whatsapp number). Greeting by hour (0–11 morning, 12–17 afternoon, else evening) + first name. Notification badge (hidden if 0/null, "+99" if >99). Next reservation card: countdown hours/minutes from `difference` seconds, doctor info, tap → Appointment details. Guest: guest avatar, card "login with…" → Auth. Sections hidden when empty: banners (tap → Offer details by `offer_id`), specialties grid (item 0 is always "Medical offers" gift icon → Offers; max 7 specialties + item 7 "More" → All specialities), newly added doctors (heart only when logged in, optimistic toggle with revert on error), special offers (strikethrough price, discount badge rotated ±10° by language). Search bar → Search tab screen. Errors: full-screen error view; network error has Retry. |
| All specialities | `K/presentation/allspecialities/screen/AllSpecialitiesFragment.kt` | `client/specialty`; same adapter (item 0 "Medical offers" → Offers); tap → Search details |
| Offers | `K/presentation/offers/screen/OffersFragment.kt`, `OffersViewModel.kt`, `offers/adapter/*` | horizontal specialty tabs from `client/specialty`; first selected; list `client/offers?specialty_id`; empty state; pull to refresh; tap → Offer details. Transparent status bar. |
| Offer details | `K/presentation/offerdetails/screen/OfferDetailsFragment.kt` | `client/offers/{id}` (id from args or notification). 404 → "offer no longer available" + Back. Banner, name, description, discount, prices, duration `start:end`, bookings count (1 → "one time", 0 → "none", n → "more than one time (n)"), details. "Get offer": logged in → Purchase; guest → Must-login sheet. |
| Purchase offer | `K/presentation/purchaseoffer/screen/PurchaseOfferFragment.kt`, `K/utils/tapPayment/TapPaymentHelper.kt` | Shows offer, price before/after/discount. Button enabled only if terms checkbox AND payment-method radio are checked. Pay → Tap goSell SDK (currency SAR, amount final_price, customer name/phone(966)/email from UserData, 3DS required, save card allowed). On payment success → `POST client/offers {offer_id}` → Successful offer purchase. Terms link → Terms of use. |
| Successful offer purchase | `K/presentation/successfulofferpurchase/SuccessfulOfferPurchaseFragment.kt` | `client/my-offers/{id}`; shows offer; hint "applies on specialty X"; "Go to doctors" → Search details for `specialty_model`; back → pop to Home |
| Search (LastSearch) | `K/presentation/lastsearch/screen/LastSearchFragment.kt`, `SearchResultFragment.kt`, `LastSearchViewModel.kt` | Initially "Most selected" specialties (`client/search/most`). Logged-in + field focused + empty → Recent searches (`GET client/search`) with "Delete all" (`DELETE client/search/clear`); tap recent → fills text. Typing (debounce 500 ms) → `POST client/search?keyword` → two tabs "Specialities"/"Doctors" with results / empty states. Guest never sees recent. Cancel → back. Most-selected item named "Medical offers" → Offers. |
| Search details | `K/presentation/searchdetails/screen/SearchDetailsFragment.kt` + VM + shared VM | Arg: SpecialityModel. `client/specialty/{id}` with current filters; search by doctor name (debounce 1000 ms); Sort button → Sort sheet (red dot when set); Filter button → Filter screen (red dot when any filter set); heart toggle (logged in only); tap → Doctor details. Reloads on resume. Back clears filters. |
| Sort sheet | `K/presentation/filter/sheet/SortBySheet.kt`, `searchdetails/adapter/SortByAdapter.kt` | 4 options (SortByStatus), single choice, preselect current, confirm returns value, clear option |
| Filter | `K/presentation/filter/screen/FilterFragment.kt`, `filter/adapter/*` | `general/filter-details/{id}`: price range slider (min..max, label "n SAR", hidden when min==max), gender radio (male/female), selected subspecialties chips + "choose" → Subspecialties sheet; Apply sets values; Reset clears; back without apply restores previous |
| Subspecialties sheet | `K/presentation/filter/sheet/SubSpecialtiesSheet.kt` | multi-select list; confirm saves |
| Doctor details | `K/presentation/doctordetails/screen/DoctorDetailsFragment.kt` + VM + shared VM | `general/doctor/{id}`. Image, name, sub_specialty ?: specialty, rating + "(rate) n reviews", duration, price, experience "n+". Heart (logged in only). Share → text `"<HOST_URL>/doctor/<id>"`. 3 custom tabs (no swipe): Booking time / Info / Reviews. "Book an appointment": guest → Must-login sheet; no day → toast "please select day"; no time → toast "please select time"; doctor has `user_offers` → Appointment type sheet; else → Book appointment. |
| Booking time tab | `K/presentation/bookingappointments/screen/BookingAppointmentsFragment.kt`, `bookingappointments/adapter/BookingDaysAdapter.kt`, `AvailableTimesAdapter.kt` | Horizontal days from `doctor.work_times` (first auto-selected; inactive days greyed & unclickable); times grid (reserved greyed & unclickable; tap again to unselect). Empty states "no available times today". "Open calendar" → Material date picker allowing only active dates → selects that day. |
| Info tab | `K/presentation/generalinfo/screen/GeneralInfoFragment.kt` | about with "show more" after 4 lines; work days joined by "-"; certificates grid → fullscreen image viewer |
| Reviews tab | `K/presentation/reviews/screen/ReviewsFragment.kt` | empty state; average rate (1 decimal), stars, "based on n reviews", 5 bars animated 2.5 s with percentage = count/reviews.size*100, review list |
| Appointment type sheet | `K/presentation/appointmenttype/sheet/AppointmentTypeSheetFragment.kt`, `doctordetails/adapter/AppointmentTypeAdapter.kt` | first row "Examination booking" (normal, price), then doctor's user offers (remaining sessions). Single select checkbox. Normal → Book appointment; offer → Book appointment with offer |
| Book appointment | `K/presentation/bookappointment/screen/BookAppointmentFragment.kt` | doctor card, day (formatted_date), time, duration, price, notes field. "Change appointment" → Change appointment sheet (returns new day/time, display `"<dayName>,<dd MMMM yyyy>"`). Book → `POST client/appointments` → Successful appointment request |
| Book appointment with offer | `K/presentation/bookappointmentwithoffer/screen/BookAppointmentWithOfferFragment.kt` | same + offer name & remaining sessions, sends `user_offer_id` → Successful request with offer |
| Change appointment sheet | `K/presentation/sheets/screen/ChangeAppointmentSheetFragment.kt` | loads `general/work-times/{doctorId}`; days/times picker + calendar; confirm returns ChangeAppointmentRequest; not cancellable by outside tap |
| Successful appointment request | `K/presentation/successfulappointmenttrequest/SuccessfulAppointmentRequestFragment.kt` | loads `client/appointments/{id}`; shows details; "Go to reservations" → Bookings; back → pop to Home |
| Successful request with offer | `K/presentation/successfulappointmentrequestwithoffer/screen/SuccessfulAppointmentRequestFragmentWithOfferFragment.kt` | loads `client/session/{id}`; "Go to bookings"; back → pop to Home |
| Bookings | `K/presentation/bookings/screen/BookingsFragment.kt`, `bookings/adapter/BookingAdapter.kt`, `bookingsearch/screen/BookingSearchViewModel.kt` | Guest: must-login empty view with Login button. Logged in: 6 tabs Pending/Confirmed/Processing/Completed/Canceled/Rejected → `GET client/appointments?status&month&keyword&type`; search (debounce 1000 ms); filter by date sheet (3/6/12 months) and by type sheet (all/normal/offers) with red dots; pull to refresh; empty/error views. Card buttons by status: pending/confirmed → Cancel + Edit (enabled only if `can_reschedule`); completed → Rate (disabled & "Reviewed" if `is_reviewed`) + Rebook; canceled/rejected → Rebook; processing → none. Offer badge if `offer != null`. Tap card → Session details if offer else Appointment details. Back → pop to Home. |
| Confirmation sheet | `K/presentation/sheets/screen/ConfirmationSheetFragment.kt` | title/body args; confirm by `bookingType`: "pending"/"confirmed" → cancel `POST client/appointments/{id}`; "change_appointment"/"appointment_update_confirmed"/"change_appointment_for_pending" → update with stored UpdateAppointmentRequest |
| Rebook / change sheet | `K/presentation/sheets/screen/ChooseRebookAppointmentSheetFragment.kt` | loads work times; title "pick booking" (type "book") or "pick rebooking". Confirm: pending/confirmed → build UpdateAppointmentRequest, close and open Confirmation sheet ("change_appointment_for_pending" for pending, else "change_appointment"); completed/canceled/rejected → `recreate/{id}` → Successful request (or with offer if forOffer). 404 on work times → "no available times" + Back |
| Filter by date / type sheets | `K/presentation/sheets/screen/FilterByDateSheet.kt`, `FilterByTypeSheet.kt` | single choice, "Delete all", confirm |
| Success dialog (main) | `SuccessDialog` type "main" | after cancel/change: "appointment canceled/changed successfully"; list item removed locally (canceled, confirmed-cancel, confirmed-change) or pending list reloaded (pending-change) |
| Add comment sheet | `K/presentation/addComment/screen/AddCommentSheetFragment.kt` | user avatar from UserData, star rating (0 → null), comment, quick comments chips (fill text), send → `client/reviews` → toast message, close, caller reloads |
| Appointment details | `K/presentation/appointmentdetails/AppointmentDetailsFragment.kt` | `client/appointments/{id}` (id from args or notification). Status pill colors by status, actions as on card, report attachment row with download (DownloadManager) when `report != null`, notes or "no description". Reacts to cancel/change/comment results by reloading + success dialog |
| Session details | `K/presentation/sessiondetails/screen/SessionDetailsFragment.kt` | `client/session/{id}`; like appointment details plus offer name + remaining sessions; rebook with forOffer=true |
| Favorites | `K/presentation/favorites/screen/FavoritesFragment.kt` | guest → must-login view; `client/fav?doctor_name` with search (debounce 1000 ms); empty vs "no results"; un-favorite removes the row; pull to refresh; tap → Doctor details; back → Home |
| Notifications | `K/presentation/notifications/NotificationsFragment.kt`, `NotificationsViewModel.kt`, `NotificationsAdapter.kt`, `K/data/paging/NotificationsPagingSource.kt` | guest → must-login view. Paged (page size 15, next page until empty page). Switch "allow notifications" (`allow-notifications`, shows "notifications disabled" banner when off). Unread dot. Tap → `read/{id}` then navigate by `notify_type` (appointment → Appointment details, offer → Offer details, report → My reports, user_offer → My offer details, id = `notify_id`). Swipe (direction depends on RTL) → delete. Pull to refresh. |
| Must-login sheet | `K/presentation/sheets/screen/MustLoginSheetFragment.kt` | icon, title, body, Login button → Auth |
| Profile | `K/presentation/profile/screen/ProfileFragment.kt`, `ProfileViewModel.kt`, `profile/adapter/*` | Header: logged in → avatar + "Welcome, <first name>" + "update profile" (→ Edit profile); guest → guest header + Login button. Menu (logged in): Password, My offers, Radiology & analysis reports, Notifications, Language, Contact us, Rate the app, Who are we, About app, Logout. Guest: Notifications, Language, Contact us, Rate the app, Who are we, About app. On resume calls `GET client/user` and updates stored user. Back → Home. "Rate the app" currently does nothing → Flutter: open Play Store listing. |
| General sheet | `K/presentation/profile/sheet/GeneralSheet.kt` | type LOGOUT or DELETE_ACCOUNT (red button, other image). Confirm → `logout` / `DELETE client/user` → clear storage, language = ar → Auth (clear stack) |
| Change language sheet | `K/presentation/profile/sheet/ChangeLanguageSheet.kt` | ar/en choice. Logged in → `change-lang` then save; guest → just save. Then restart into Main (clear stack) |
| Edit profile | `K/presentation/profile/editProfile/EditProfile.kt` | loads `client/user`; avatar change via image picker (gif rejected → toast "invalid image"; image resized to max 1024, JPEG 80, EXIF-rotated) → upload → `update-profile {image}`; name/email edit + save → update-profile → back. Phone field: "Update phone" button appears only when phone differs → `update-phone` → OTP change phone (fromDestination EDIT_PROFILE). "Delete account" → General sheet DELETE_ACCOUNT |
| OTP change phone | `K/presentation/profile/editProfile/otp/OtpChangePhoneFragment.kt` | same OTP UI. EDIT_PROFILE → `client/user/verify` → Success sheet "changePhone". From "EditProfileAddNewPasswordFragment" → `password/verify` → Forget-password-for-edit |
| Success sheet | `K/presentation/profile/sheet/SuccessChangePhoneSheet.kt` | GIF, not cancellable, 2 s; "changePhone" → "phone changed"; others → "password changed"; type "ForgetPasswordForEditPasswordFragment" → triggers logout. After close callers pop back |
| Change password (profile) | `K/presentation/profile/addNewPassword/EditProfileAddNewPasswordFragment.kt` | current/new/confirm → `user/change-password` → Success sheet → pop back. "Forgot password" → `password/reset` with own phone → OTP change phone |
| Forget password for edit | `K/presentation/profile/addNewPassword/ForgetPasswordForEditPasswordFragment.kt` | new password + confirm → `password/change` with otp → Success sheet (→ logout) |
| Contact us | `K/presentation/profile/contactUs/ContactUsFragment.kt` | name prefilled from UserData, title, message (each ≥ 2 chars) → `client/contact` → Success dialog. WhatsApp icon → `https://api.whatsapp.com/send?phone=<whats_app_number>` |
| About app | `K/presentation/profile/about/AboutFragment.kt`, `about/adapter/SocialAdapter.kt` | `client/about-app`: HTML text, social icons for keys facebook/twitter/x/youtube/instagram/link (open in browser via chooser), links → Terms of use, Privacy policy |
| About us | `K/presentation/profile/aboutUs/AboutUsFragment.kt` | `client/about`: HTML + up to 3 images |
| Terms / Privacy | `K/presentation/profile/privacypolicy/screen/TermsOfUseFragment.kt`, `PrivacyPolicyFragment.kt` | HTML from `client/term` / `client/policy` |
| My offers | `K/presentation/myoffers/screen/MyOffersFragment.kt` | tabs Valid / Completed from `client/my-offers`; tap → My offer details |
| My offer details | `K/presentation/myofferdetails/screen/*.kt`, `myofferdetails/adapter/MyOfferBookingsAdapter.kt` | `client/my-offers/{id}` (id from args or notification `userOfferId`); header name/description, button "book" → Search details (specialty); 2 tabs: General info (duration, subscription date, sessions used/total, details) and Bookings (sessions list; completed shows "Session <ordinal>"; tap → Session details) |
| My reports | `K/presentation/myreports/screen/MyReportsFragment.kt`, `myreports/adapter/*` | toggle Radiology / Laboratory → `client/my-reports?type`; grouped by date; download icon → DownloadManager with notification |

### 7.5 Deep links & notification taps (`MainActivity.kt`)
- App link `https://<HOST>/doctor/<id>`: if logged in, after 500 ms navigate to Doctor details (pop up to Home). If not logged in nothing happens (guest branch dead code).
- Notification tap extras `destination` (notify_type) + `notificationId`: handled only in `onNewIntent` (app already running). Cold start ignores them (bug). Routes: appointment → Appointment details(`appointmentId`), offer → Offer details(`offerId`), user_offer → My offer details(`userOfferId`), report → My reports, else Home.

---

## 8. Native features & SDKs

| Feature | Where | Notes |
|---|---|---|
| FCM | `K/fcm/FirebaseMessagingService.kt`, `K/fcm/MyInstanceIDService.kt` | data messages: title, body, notify_type, notify_id, notify_status. Builds a local notification on channel `NOTIFICATIONS_CHANNEL_ID` (**channel never created**), high priority, small icon launcher, color primary. Skips if POST_NOTIFICATIONS not granted (**never requested**). Empty data → "FCM"/"We are glade to reach you". `onNewToken` saves token. |
| Tap Payments goSell | `K/utils/tapPayment/TapPaymentHelper.kt` | SDK `com.github.Tap-Payments:goSellSDK-Android:2.16.1`, secret key `PAYMENT_KEY`, bundle id = applicationId, windowed mode, PURCHASE, SAR, customer phone country code 966. Success → listener. |
| Image picker | `EditProfile.kt` (EasyMediaPicker), `K/utils/UploadImages.kt` | resize/compress/rotate before upload |
| File download | Appointment/Session details, My reports | Android DownloadManager with visible notification |
| Share | Doctor details | plain text share chooser |
| External links | Contact us (WhatsApp), About app (social) | ACTION_VIEW |
| Lottie | Splash, onboarding | `R/raw/*.json` |
| GIFs | `R/drawable/loader.gif`, `success_gif.gif`, `intro.gif` (unused?) | Glide |
| Image viewer | `K/utils/helpers/zoom/CertificateHelper.kt` (StfalconImageViewer) | certificates |
| Date picker | MaterialDatePicker with allowed-dates validator | booking |
| Unused in screens | Google/Huawei Maps, location/GPS (`K/base/gps`, `K/base/location`, `K/utils/helpers/maps`), CameraX, ML Kit barcode, Socket.IO, Room, Places, Remote Config (call commented out), Firebase Auth, Analytics/Crashlytics/Perf (deps only), WorkManager `UpdateTokenWorker`, PermissionX, ShowCaseView, Blurry, qrcode, ConnectivityObserver, explosion field, multiswipe, `K/presentation/bookingsearch/screen/*BookingsFragment.kt` (6 orphan fragments), `K/utils/DummyDataFile.kt` | **Not ported** (user decision) |

---

## 9. Resources

- **Strings:** `R/values/strings.xml` (418) and `R/values-ar/strings.xml` (414). No plurals. Format args `%1$s` etc.
  Some HTML/escaped apostrophes. 4 keys exist only in English → fall back to English.
- **Colors:** `R/values/colors.xml` — primary `#6A449A`; many `c_XXXXXX` greys/accents. Most used:
  `c_251836` (dark text), `c_3D4C5E` (secondary text), `c_7E94B0` (labels), `c_D9DBE9` (field underline),
  `c_ED1C24` (error red), `c_50C878` (green/completed), `c_006F98` (processing blue), `c_E6E6E6` (disabled), `white`.
  Selectors: `R/color/nav_item_text_selector.xml`, `R/color/btn_state_reports.xml`.
- **Theme:** `R/values/themes.xml` — Material3 DayNight NoActionBar, default font `urw_din_arabic_medium`, transparent
  status bar with dark icons, bottom sheet styles (transparent background, rounded drawables), text styles
  bold/medium/regular/semi_bold (URW DIN Arabic), `messiri_bold_font`, `discount_font` (Comic Sans bold).
- **Fonts:** `R/font/` — urw_din_arabic_{thin,xlight,light,regular,medium,semi_bold,bold,black}.ttf, messiri_{regular,medium,semibold,bold}.ttf, comic_sans_ms(_bold).ttf.
- **Dimens:** there is no `R/values/dimens.xml`. Phones resolve `R/values-normal/dimens.xml` (screen-size qualifier
  beats density), where the number in the name is the value: `dimen_016dp` = 16 dp, `text_size_14sp` = 14 sp.
  **Rule for Flutter: `dimen_0XXdp` → `XX.0` logical px, `text_size_XXsp` → font size `XX`.** Ignore the
  `values-*dpi` scaled copies.
- **Drawables:** `R/drawable/` 249 XML (vectors, shapes, selectors), 25 PNG, 9 JPG, 3 GIF; `R/drawable-ar/` 6 PNG
  (onboarding art mirrored). Launcher: `R/mipmap-*`, adaptive icon `R/mipmap-anydpi-v26`, background color `R/values/ic_launcher_background.xml`, Play icon `app/src/main/ic_launcher-playstore.png`.
- **Raw:** Lottie JSON (see above), `map_style.json` (unused).
- **Layouts:** 128 XML in `R/layout/` — the visual source of truth for each screen (look up the binding name: e.g. `FragmentHomeBinding` → `R/layout/fragment_home.xml`; included sections like `bannersSection` are `<include>`s).
- **Animations:** `R/anim/` — slide left/right for auth transitions, fade for activity switches.

---

## 10. Tests

There are **no** tests in the Android project (`app/src/test` and `app/src/androidTest` do not exist).

---

## 11. Known quirks to preserve or fix (decisions recorded in PLAN.md)

1. Guest `Authorization: null` → **omit header** (decided).
2. 401 → **do nothing** (decided).
3. Notification channel / Android 13 permission / cold-start tap routing → **fix** (decided).
4. "Rate the app" → **open Play Store** (decided).
5. Saudi phone rules (+966, 9 digits, starts with 5) → **keep** (decided).
6. Logout/delete clears everything and resets language to "ar"; first-time flag is cleared too.
7. `can_reschedule` defaults to true when missing on AppointmentData, false on SessionDetailsModel.
8. Work-times endpoint response is not wrapped in BaseResponse fields but has `data`.
9. Numbers (prices, percentages, rates) are always formatted with English digits (`NumberFormat(Locale.ENGLISH)`);
   rates truncated to 1 decimal (`truncateToDecimalPlace(1)`), prices via `formatDecimalNumber` (see `K/utils/extensions/ViewExtFunctions.kt`).
10. Time helpers in `K/utils/extensions/ViewExtFunctions.kt` have inverted names: `convertTo24HourTime()` converts
    `"HH:mm"` → `"hh:mm a"` (12-hour) and replaces Arabic digits with English ones.
11. Home specialties: item 0 always "Medical offers", at most 7 real specialties shown, item index 7 is "More".
12. Deep link only works when logged in.

---

## 12. Android → Flutter mapping

| Android library / feature | Flutter replacement |
|---|---|
| Activities + Jetpack Navigation + Safe Args | `go_router` (one router; `StatefulShellRoute` not used — see PLAN) |
| BottomNavigationView | custom `BottomNavigationBar`-like widget in a shell route |
| BottomSheetDialogFragment | `showModalBottomSheet` (returns a result via `Navigator.pop(context, value)`) |
| DialogFragment | `showDialog` |
| Hilt | `RepositoryProvider` / `BlocProvider` from `flutter_bloc` (manual construction in `main.dart`) |
| ViewModel + SharedFlow/LiveData | `Cubit` with immutable state classes (`flutter_bloc`) |
| Activity-scoped shared ViewModels | route `extra` objects + sheet/route return values + `SessionCubit` for app-wide state |
| Retrofit + OkHttp + Gson + NetworkResponse adapter | `dio` + hand-written `fromJson` + `ApiResult<T>` sealed class |
| Preferences DataStore + Proto DataStore | `shared_preferences` (user stored as JSON string) |
| Paging 3 (notifications) | `infinite_scroll_pagination` |
| Glide / Coil (network images, rounded, circle) | `cached_network_image` |
| Glide GIF | `Image.asset` (GIFs animate natively) |
| Lottie | `lottie` |
| Vector drawables | converted to SVG by `tool/vd2svg.dart` → `flutter_svg` |
| Shape/selector XML drawables | `BoxDecoration` / widget code |
| Custom Toaster at top | own `AppToast` overlay widget (no package) |
| ProgressButton | own `ProgressButton` widget |
| CustomRatingBar | own `StarRating` widget |
| Material RangeSlider | Flutter `RangeSlider` |
| MaterialDatePicker + validator | `showDatePicker(selectableDayPredicate: …)` |
| TabLayout + ViewPager2 | `TabBar`/custom tab row + `IndexedStack` (no swipe where Android disabled it) |
| SwipeRefreshLayout | `RefreshIndicator` |
| ItemTouchHelper swipe-to-delete | `Dismissible` |
| `strings.xml` en/ar | ARB files via `tool/strings2arb.dart` + `flutter gen-l10n` (`flutter_localizations`, `intl`) |
| App locale (`CommonUtils.changeLanguage`) | `MaterialApp.locale` from `SessionCubit` |
| Date formatting (SimpleDateFormat) | `intl` `DateFormat` + `core/utils/date_utils.dart` |
| Html.fromHtml | `flutter_widget_from_html_core` |
| EasyMediaPicker + resize/EXIF | `image_picker` (`maxWidth/maxHeight 1024, imageQuality 80` handles resize/rotation) |
| DownloadManager | `background_downloader` (notification on completion) |
| Share intent | `share_plus` |
| ACTION_VIEW (WhatsApp, social, Play Store) | `url_launcher` |
| StfalconImageViewer | `photo_view` (`PhotoViewGallery`) |
| FirebaseMessagingService + NotificationCompat | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| POST_NOTIFICATIONS runtime request | `firebase_messaging.requestPermission()` |
| App Links intent filter | `app_links` + manifest intent filter |
| Tap goSell Android SDK | `go_sell_sdk_flutter` (fallback: platform channel to the same Android SDK) |
| Crashlytics (deps only) | `firebase_crashlytics` (added, per decision) |
| Remote Config, Maps, Location, CameraX, ML Kit, Socket.IO, Room, WorkManager, Places, Firebase Auth, Analytics, Perf, PermissionX, ShowCaseView | not ported (unused) |
| `google` / `huawei` flavors | none (single build) |
| BuildConfig fields from `local.properties` | `--dart-define-from-file=env/<debug|release>.json` → `core/config/env.dart` |
