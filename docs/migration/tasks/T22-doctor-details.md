# T22 - Doctor details: header, info tab, reviews tab

## Goal
Port the doctor details screen shell (header, favorite, share, three custom tabs, "Book an appointment" button rules) and the
Info and Reviews tabs. The Booking-time tab content comes in T23; this task leaves a placeholder in tab 0 and keeps the
selection fields in the Cubit ready.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/doctordetails/screen/DoctorDetailsFragment.kt`, `DoctorDetailsViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/doctordetails/DoctorDetailsSharedViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/generalinfo/screen/GeneralInfoFragment.kt`, `generalinfo/adapter/CertificatesAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/reviews/screen/ReviewsFragment.kt`, `reviews/adapter/ReviewsAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/helpers/zoom/CertificateHelper.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/extensions/ViewExtFunctions.kt` (`showMoreText`, `formatDecimalString`)
- Layouts: `res/layout/fragment_doctor_details.xml`, `fragment_general_info.xml`, `fragment_reviews.xml`, item layouts of the two adapters, `bg_selected_tab.xml`, `bg_unselected_tab.xml`
- `docs/migration/CONTEXT.md` §7.4 (Doctor details, Info tab, Reviews tab rows)

## Build
- `lib/features/doctor_details/doctor_details_screen.dart`, `doctor_details_cubit.dart`
- `lib/features/doctor_details/widgets/doctor_header.dart`, `detail_tabs.dart`, `info_tab.dart`, `reviews_tab.dart`, `review_item.dart`, `rating_summary.dart`
- `lib/features/doctor_details/widgets/expandable_text.dart` (port of `showMoreText`/`showLessText`, 4 lines)
- Router: replace `doctorDetails`.
- `test/features/doctor_details/doctor_details_cubit_test.dart`

## Steps
1. `flutter pub add photo_view share_plus`.
2. `DoctorDetailsCubit(DoctorRepository, int id)`: state `doctor`, `isFav`, status, failure, and **selection**: `WorkTimeModel? selectedDay`, `TimeModel? selectedTime`
   (set by T23's tab). `load()`, `toggleFavorite()` (Android flips only **after** success here, unlike Home — copy), `selectDay`, `selectTime`.
   `BookingDraft? buildDraft()` returns the draft from the doctor + selection (fields as in `btnBookAnAppointment` in the Kotlin; `doctorSpecialization = sub_specialty ?? specialty`).
3. Header from `fragment_doctor_details.xml`: back, share icon → `SharePlus.instance.share(ShareParams(text: '${Env.hostUrl}/doctor/${id}'))`, image, name, brief,
   read-only rating + `"(rate1) reviewsWithNumber(n)"`, duration `minValues(duration)`, price `formatDecimal`, experience `"${formatDecimalString(experience)}+"`,
   heart (logged in only) with the 1.4× bounce and `ic_heart_btn_active/inactive`.
4. Tabs: three text buttons (Booking time / Info / Reviews) styled with `bg_selected_tab` (white text) / `bg_unselected_tab` (`c3D4C5E` text);
   content in an `IndexedStack` (no swipe, keeps state). Tab 0 shows a `Placeholder` text until T23.
5. Info tab: `ExpandableText(about ?? l10n.noInformationAvailable, maxLines: 4, linkColor: primary)`, work days `doctor_work_times_days.join('-')`,
   certificates grid (hidden when empty) → tap opens a full-screen `PhotoViewGallery` starting at the tapped index (black background, close button, swipe between).
6. Reviews tab: if no reviews → `tvRates = l10n.reviews`, `StateView.empty(icon: ic_no_reviews, title: noReviews)`. Else: `ratesWithValue("(${reviews.length})")`, big rate (1 decimal truncated),
   stars, `basedOnNoOfReviews(reviews_count ?? 0)`, five bars (5→1) with percentage `((countN ?? 0) / reviews.length * 100).toInt()` animated 0 → value over 2500 ms
   (`TweenAnimationBuilder`), review list (`ReviewsAdapter`: avatar, name, date, stars, comment).
7. Book button rules: guest → `showMustLoginSheet`; `selectedDay == null` → toast `pleaseSelectDay` (failed); `selectedTime == null` → `pleaseSelectTime`;
   doctor has `user_offers` not empty → `// T25: appointment type sheet` (for now push book appointment); else → `context.push(Routes.bookAppointment, extra: cubit.buildDraft())`.
8. Errors: loading full screen; server → serverError; network → connectionLost(retry); unknown → serverError (Kotlin `else` shows server error view). Favorite failure → toast.
9. Back → `context.pop()`. Status bar white/dark icons.
10. Tests: draft building; toggle favorite only after success.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: same doctor shows identical header/info/reviews as Android; certificates open the zoomable viewer; share sheet text is the doctor URL; guest gets must-login on Book.

## Out of scope
- Booking-time tab (T23), appointment type sheet (T25), deep link (T40).

## Gotchas
- Selection must reset when the doctor reloads (Android adapters reselect the first day on submit — T23 handles; keep `selectDay(null)` on load).
- `stars` is used for the summary rating bar, `rate` for the numeric value.

## Notes
- Done: `DoctorDetailsCubit` (doctor, `isFav` flipped only after success, `selectedDay`/`selectedTime`, `buildDraft()`), screen with header/tabs/footer, Info tab (`ExpandableText`, certificates + `photo_view` gallery), Reviews tab (summary + 2500 ms bars + list). Route `doctorDetails` replaced. Packages added: `photo_view`, `share_plus`.
- T23: tab 0 is a text placeholder in the `IndexedStack`. Call `cubit.selectDay(day)` / `cubit.selectTime(time)` from it; `selectDay` clears the time and `load()` clears both. `buildDraft()` maps `day = dayTranslated`, `date = date`, `formattedDate = formatedDate`, `time = timeFormatted`; adjust there if T23 needs other fields.
- T25: the Book button has a `// T25` branch for `user_offers` that currently pushes `Routes.bookAppointment` like the no-offer case.
- Header shows 0 when `rate`/`reviews_count` are null (Android printed "null").
- Not verified on a device.
