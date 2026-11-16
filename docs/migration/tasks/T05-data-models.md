# T05 - Data models

## Goal
Port every API model used by the app into immutable Dart classes with hand-written `fromJson` (and `toJson` for
request bodies), plus the enums. The repositories (T08/T09) and all screens depend on them.

## Read first
- All files in `app/src/main/java/com/alalmiya/lavender/data/models/**` (skip `onboarding/OnBoardingItem.kt`, it is UI-only and lives in T11)
- `app/src/main/java/com/alalmiya/lavender/utils/enums/*.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/reviews/screen/ReviewData.kt` (UI aggregate — not needed, compute in T22)
- `docs/migration/CONTEXT.md` §5.4

## Build
Layout under `lib/data/`:
- `models/responses/` (response models):
  - `base_response.dart` — `PaginationMeta`, `PaginationLinks` (only for notifications)
  - `user.dart` — `UserModel`, `CountryModel`, `CityModel`
  - `doctor.dart` — `DoctorModel`, `WorkTimeModel`, `TimeModel`, `ReviewModel`, `CertificateModel`
  - `speciality.dart` — `SpecialityModel`, `SubSpecialtyModel`, `FilterData`
  - `home.dart` — `HomeData`, `BannerModel`, `NextReservationModel`
  - `offer.dart` — `OfferModel`, `MyOffersData`, `SessionDetailsModel`
  - `appointment.dart` — `AppointmentData`, `QuickComment`
  - `search.dart` — `SearchResultsData`, `RecentSearchModel`
  - `notification.dart` — `NotificationModel`, `NotificationTypeData`
  - `report.dart` — `DayReportsModel`, `ReportModel`
  - `about.dart` — `AboutModel`, `AboutImage`, `SocialLink`
  - `setting.dart` — `SettingModel`
- `models/requests/` (request bodies, toJson only):
  - `auth_requests.dart` — `AuthRequest`
  - `appointment_requests.dart` — `SaveAppointmentRequest`, `UpdateAppointmentRequest`, `RebookRequest`, `AddCommentRequest`, `ChangeAppointmentRequest`, `GetBookingsRequest`
  - `offer_requests.dart` — `BuyOfferRequest`
  - `favorite_request.dart` — `ToggleFavoriteRequest`
  - `booking_draft.dart` — `BookingDraft` (port of `BookingRequestModel`; UI state, to move with the booking feature)
- `enums/enums.dart` — `BookingStatus`, `AppointmentType`, `OfferType`, `ReportType`, `SortByStatus`, `GenderType`, `NotificationType` each with a `value` string and `fromValue`
- `json/` — `json_utils.dart` (safe readers), `json_converters.dart` (lenient converters)
Tests mirror this under `test/data/` (`models/responses/`, `enums/`, `json/`).

## Steps
1. `json_utils.dart`: helpers `int? asInt(dynamic)`, `double? asDouble(dynamic)`, `String? asString(dynamic)`, `bool asBool(dynamic, {bool fallback = false})`,
   `List<T> asList<T>(dynamic, T Function(Map<String, dynamic>))`. They must accept: numbers as strings (`"150.00"`), ints for doubles,
   `0/1` and `"0"/"1"` for bools, `null` everywhere. The backend is Laravel and is inconsistent — never cast directly.
2. For each Kotlin model create a Dart class: `final` fields with the same meaning, Dart names in lowerCamelCase, JSON keys exactly as the Kotlin
   field names or their `@SerializedName`. Keep Kotlin defaults: e.g. `AppointmentData.canReschedule` default **true**, `isReviewed` false;
   `SessionDetailsModel.canReschedule` default **false**; `DoctorModel.isFav` false; `SpecialityModel.appointmentsCount` 0;
   `CountryModel.showPhoneCode` "+966", `phoneNumberLimit` 9, `prefix` ["5"]; `WorkTimeModel.isActive` int default 0.
   Keep numeric types as in Kotlin (`DoctorModel.price/duration/experience` are **String**; `rate/stars/five..one` are double).
3. Do **not** port UI-only mutable flags (`isSelected`, `isLoading`, `sessionName`) into models; screens keep selection in Cubit state.
   `DoctorModel.isFav` stays as a field; provide `copyWith(isFav:)`.
4. `HomeData` JSON key for banners is the misspelled `"bannars"`.
5. `NotificationModel.id` is a String; `data.notify_id` int.
6. `BookingDraft` (screen-to-screen object, no JSON): doctorId, doctorImage, doctorName, doctorSpecialization, stars, rate, reviewsCount,
   date (ISO), formattedDate, day (translated day name), time (time_formatted), examinationPrice (String), userOfferId, duration, plus `copyWith`.
7. Request classes get `Map<String, dynamic> toJson()` that **omits null fields** (Gson does that by default). `UpdateAppointmentRequest.toJson`
   includes `"_method": "put"`. `AuthRequest` keys: phone, phone_code, device_token, device_type, password, full_name, email,
   password_confirmation, otp, current_password, image, terms_and_conditions.
8. All model classes extend `Equatable` (props = all fields).
9. Tests: one test file per model file with a realistic JSON sample (write it from the Kotlin fields; include a string number, a null list,
   a missing key) asserting parsed values and defaults; `toJson` of each request omits nulls; `UpdateAppointmentRequest` has `_method`.

## Done when
- `flutter analyze` → no issues; `flutter test` → all model tests pass; debug APK builds.
- Every Kotlin file in `data/models/**` (except `onboarding`, `base/Link.kt`, `notifications/LinksModel.kt` if unused) has a Dart counterpart — list the mapping in Notes.

## Out of scope
- Networking and storage (T06/T07). `UserData` storage mapping (T06).

## Gotchas
- `GetWorkTimesResponse` and `GetDoctorDetailsResponse` / `ShowBookingDetailsResponse` do not extend BaseResponse in Kotlin, but JSON still has `data`.
- `ToggleFavoriteRequest.doctor_id` is sent as a **String**.
- `AddCommentRequest.rate` is a float or null (null when 0 stars).
- `TimeModel.time_formatted` is what gets sent as `time`; `time` is only displayed.

## Notes
Done. `flutter analyze` clean, `flutter test` all pass, debug APK builds.

- Original single-folder layout was restructured, see "Update: restructure" at the bottom.
- Lists are non-null (`[]` when missing/null); scalars stay nullable like Kotlin. Kotlin defaults apply only when a key is missing (`CountryModel`).
- Extra request classes not in the Build list: `ToggleFavoriteRequest` (doctor.dart, sends `doctor_id` as String), `BuyOfferRequest` (offer.dart), `GetBookingsRequest` (appointment.dart); `DoctorsBySpecialityData` is in speciality.dart. `BannerModel` fields are non-null (fallback 0/'').
- Enum members: `AppointmentType.defaultType/offer/notOffer`, `BookingStatus` has `value` + `position`, `SortByStatus` has no l10n key (map in the sort sheet, T20). `NotificationModel.copyWith(isReaded:)` added for T31.
- Kotlin -> Dart mapping: UserModel/CityModel/CountryModel/AuthRequest -> requests/auth_requests.dart; MetaResponse/MetaModel -> PaginationMeta, LinksResponse/LinkModel -> PaginationLinks; DoctorModel, WorkTimeModel, TimeModel, ReviewModel, CertificateModel -> responses/doctor.dart; SpecialityModel, SubSpecialtiesData (SubSpecialtyModel), FilterData, DoctorsBySpecialityData -> responses/speciality.dart; HomeData, BannerModel, NextReservationModel -> responses/home.dart; OfferModel, MyOffersResponseData (MyOffersData), SessionDetailsModel, BuyOfferRequest -> responses/offer.dart; AppointmentData, QuickComment, the booking requests, BookingRequestModel (BookingDraft) -> responses/appointment.dart; SearchResultsData, SearchResultModel (RecentSearchModel) -> responses/search.dart; NotificationModel/NotificationType (NotificationTypeData) -> responses/notification.dart; DayReportsModel, ReportModel -> responses/report.dart; AboutModel, AboutUsImages (AboutImage), LinkSocial (SocialLink) -> responses/about.dart; SettingModel -> responses/setting.dart; utils/enums -> enums.dart.
- Not ported: all `Get*Response`/`*Response` wrappers (repositories read `data`, T08/T09), `BaseResponse`, `LanguageModel/Response`, `UploadImage*` (response `data` is a String), `NotificationToggle*` (read `allow_notification`), `MostSelectedSpecialitiesData`, `GeneralFirebaseModel` (T39), `Link`, `LinksModel`, `AttachmentModelType`, `MessageStatus`, `OnBoardingItem` (T11).

### Update: switched to json_serializable + build_runner (owner decision)
- Hand-written `fromJson`/`toJson` replaced by generated `*.g.dart` (committed). Run `dart run build_runner build --delete-conflicting-outputs` after changing a model. `build.yaml` sets `field_rename: snake`, `include_if_null: false`.
- Lenient parsing lives in `json/json_converters.dart`: class-level `@IntConv()/@DoubleConv()/@StrConv()/@BoolConv()/@BoolOrNullConv()` apply to every field of that type; non-null fields use `@JsonKey(fromJson: asIntOrZero / asStringOrEmpty / asBoolDefaultTrue)`. Add the converters you need to each new model class. `json/json_utils.dart` helpers are still used by them.
- Lists use `@JsonKey(defaultValue: [])` (null/missing -> `[]`; a non-object list element now throws instead of being skipped). Build prints harmless warnings that the constructor default `const []` duplicates the `defaultValue`.
- Request classes use `@JsonSerializable(createFactory: false)` and need `@JsonKey(includeToJson: false)` on the Equatable `props` getter, otherwise `props` leaks into the JSON. `UpdateAppointmentRequest.toJson` adds `_method: put`; `ToggleFavoriteRequest` stays hand-written (String id).
- Equatable `props`, `DoctorModel/NotificationModel/BookingDraft.copyWith` remain hand-written.

### Update: restructure (owner decision)
- `lib/data/models/` now has `responses/` and `requests/`; enums moved to `lib/data/enums/`, converters and readers to `lib/data/json/`; `SettingModel` has its own `setting.dart`. Request classes were split out of the response files (`ToggleFavoriteRequest` -> `requests/favorite_request.dart`, `BookingDraft` -> `requests/booking_draft.dart`).
- Tests mirror the layout under `test/data/`.
