# T25 - Appointment type sheet, book with offer, successful request with offer

## Goal
When the doctor has user offers (purchased packages), the user chooses between a normal examination and one of the offers;
offer bookings use their own confirmation and success screens.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/appointmenttype/sheet/AppointmentTypeSheetFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/doctordetails/adapter/AppointmentTypeAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/bookappointmentwithoffer/screen/BookAppointmentWithOfferFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/successfulappointmentrequestwithoffer/screen/SuccessfulAppointmentRequestFragmentWithOfferFragment.kt`
- Layouts: `res/layout/fragment_appointment_type_sheet.xml`, `recycler_appointment_type.xml`, `fragment_book_appointment_with_offer.xml`,
  `fragment_successful_appointment_request_with_offer.xml`, drawables `bg_stroke_dashed_dark_purple_rounded_10_light_purple_background.xml`, `bg_stroke_dashed_grey_rounded_10_white_background.xml`
- `docs/migration/CONTEXT.md` §7.4 (Appointment type sheet, Book with offer, Successful request with offer rows)
- `lib/features/booking/book_appointment_screen.dart` (T24 — reuse parts)

## Build
- `lib/features/booking/appointment_type_sheet.dart` — `Future<OfferModel?> showAppointmentTypeSheet(BuildContext, {required String? price, required List<OfferModel> offers})`
  returning a sentinel `OfferModel(id: -1)` for normal examination.
- `lib/features/booking/book_with_offer_screen.dart`, `book_with_offer_cubit.dart`
- `lib/features/booking/session_requested_screen.dart`, `session_requested_cubit.dart`
- `lib/core/widgets/dashed_border_box.dart` (dashed rounded border, used by the type rows) — CustomPainter, no package.
- Update `doctor_details_screen.dart` step-7 branch for offers.
- Router: replace `bookAppointmentWithOffer`, `sessionRequested`.

## Steps
1. Sheet rows: first `OfferModel(id: -1, name: l10n.examinationBook, description: l10n.bookNormalExaminationWithValue(price.toString()))`, then the doctor's `user_offers`.
   Each row: dashed box (selected: dark purple dashed border + light purple fill; else grey dashed + white), name, description, and (not for row 0)
   `remainingSessions(number, used_number)`, a checkbox. Single selection; tapping a checked box unchecks. Confirm: nothing selected → toast `pleaseSelectAppointmentType`;
   else pop with the offer. Back/outside closes (cancellable).
2. Doctor details: if `user_offers` not empty → `final o = await showAppointmentTypeSheet(...)`; `o == null` → nothing; `o.id == -1` → push book appointment with the draft;
   else → `context.push(Routes.bookAppointmentWithOffer, extra: BookWithOfferArgs(draft.copyWith(userOfferId: o.id), o))`.
3. Book with offer screen (same structure as T24): doctor card, offer name (`tvOfferBrief`), remaining sessions text, day/time/duration, notes, change appointment link (same sheet),
   book → `save(... user_offer_id: offer.id)` → `context.push(Routes.sessionRequested(id))`.
   Note Android shows `remainingSessions(number, used_number)` in one observer and `(used_number, number)` in another (`setupViews`) — the last one to run wins on screen;
   check which on the Android app and use that order; record it in Notes.
4. Session requested screen: cubit loads `OffersRepository.session(id)`; shows title `bookingDetailsWithValue`, offer name, `remainingSessions(number, used_number)`, date, from–to,
   duration, notes/`noDescription`, doctor card. "Go to bookings" → `context.go(Routes.bookings)`; back → `context.go(Routes.home)`. Errors as T24.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device with an account that owns an offer for a doctor: Book → type sheet lists normal + offers; choosing normal goes to T24 screen; choosing an offer books with `user_offer_id`
  and the session success screen shows remaining sessions like Android.

## Out of scope
- Purchasing offers (T37), my offers (T36).

## Gotchas
- Android passes `examinationPrice?.toFloat()` into the string → e.g. `150.0`. Keep the same text (`double.tryParse(price).toString()`).
