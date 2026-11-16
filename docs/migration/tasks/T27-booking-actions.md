# T27 - Booking actions: confirmation, rebook/change, add comment

## Goal
Port the three action sheets used on bookings (and later on appointment/session details): the confirmation sheet (cancel or
apply a change), the rebook/change sheet (pick a new slot), the add-comment sheet (rate), plus the success dialogs, and wire them
into the Bookings list. Android coordinated these through `BookingsSharedViewModel` flags; here each sheet **returns a result**.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/sheets/screen/ConfirmationSheetFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/sheets/screen/ChooseRebookAppointmentSheetFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/addComment/screen/AddCommentSheetFragment.kt`, `addComment/adapters/GetQuickCommentsAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/bookings/screen/BookingsFragment.kt` (`setupPendingObservers`, `setupConfirmedObservers`, `setupCompletedObservers`, `onItemClicked`)
- `app/src/main/java/com/alalmiya/lavender/presentation/bookings/screen/BookingsSharedViewModel.kt`
- Layouts: `res/layout/sheet_confirmation.xml`, `sheet_rebook_appointment.xml`, `fragment_add_comment_sheet.xml`, quick comment item layout
- `docs/migration/CONTEXT.md` §7.4 (Confirmation sheet, Rebook / change sheet, Success dialog (main), Add comment sheet rows)
- `lib/features/booking/widgets/day_time_picker.dart` (T23), `lib/core/widgets/success_dialog.dart`, `star_rating.dart`

## Build
- `lib/features/bookings/actions/confirmation_sheet.dart` (+ cubit) —
  `Future<bool> showConfirmationSheet(BuildContext, {required String title, required String body, required ConfirmAction action})`,
  `sealed class ConfirmAction { Cancel(int id) | Update(int id, UpdateAppointmentRequest req) }`.
- `lib/features/bookings/actions/rebook_sheet.dart` (+ cubit) —
  `Future<RebookOutcome?> showRebookSheet(BuildContext, RebookArgs args)`;
  `RebookArgs(appointmentId, doctorId, BookingStatus status, String type /* "book" | "rebook" */, bool forOffer)`;
  `sealed class RebookOutcome { ChangeRequested(UpdateAppointmentRequest req) | Rebooked(int newId, bool forOffer) }`.
- `lib/features/bookings/actions/add_comment_sheet.dart` (+ cubit) — `Future<bool> showAddCommentSheet(BuildContext, {required int doctorId, required int appointmentId})`.
- `lib/features/bookings/actions/booking_actions.dart` — one helper class with the full flows reused by T26/T28/T29:
  `Future<BookingActionResult> cancel(context, AppointmentData|id, status)`, `edit(...)`, `rebook(...)`, `rate(...)`.
- Wire into `bookings_screen.dart` (replace the T26 TODO toasts).

## Steps
1. Confirmation sheet (dismissible): title + body from args, Confirm `ProgressButton` + Cancel. Confirm → `Cancel(id)` → `BookingRepository.cancel(id)`;
   `Update(id, req)` → `update(id, req)`. Success → `Navigator.pop(context, true)`; failure → toast, stay. Cancel/back → pop false.
2. Rebook sheet (NOT dismissible by outside tap — `isCancel = false`; back button/Cancel close it): title `pickUpBookingAppointment` when type "book" else `pickUpRebookingAppointment`;
   cubit loads `workTimes(doctorId)`: 404 → `StateView.empty(title: noAvailableTimesToday, buttonTitle: back → pop)`; other server → serverError + back; network → connectionLost(retry).
   `DayTimePicker` (T23). Confirm: no day → toast `pleaseSelectDay`; no time → `pleaseSelectTime`; then by status:
   - pending / confirmed → `pop(ChangeRequested(UpdateAppointmentRequest(doctorId, convertIsoToDateOnly(day.date), time.timeFormatted)))`
   - completed / canceled / rejected → `rebook(appointmentId, RebookRequest(day, time))` (confirm button loading) → success `pop(Rebooked(newId, forOffer))`; failure toast.
3. Add comment sheet (dismissible, keyboard-aware): user avatar from `SessionCubit.user.image`, interactive `StarRating` (0 → send `rate: null`), comment field, quick comments
   (`quickComments()` loaded on open; tapping one puts its text in the field), send icon with a small progress while sending →
   `addComment(AddCommentRequest(rate, comment.trim(), doctor_id, client_appointment_id))` → success toast with the server message, `pop(true)`.
4. `BookingActions` flows (port the observers of `BookingsFragment`):
   - **Cancel** (pending or confirmed): `showConfirmationSheet(title: confirmCancelAppointmentTitle, body: confirmCancelAppointmentBody, action: Cancel(id))` →
     true → `showSuccessDialog(appointmentCanceledSuccessfully)` → result `removed`.
   - **Edit** (pending/confirmed): `showRebookSheet(type "book", status)` → `ChangeRequested(req)` → `showConfirmationSheet(confirmChangeAppointmentTitle, confirmChangeAppointmentBody, Update(id, req))`
     → true → `showSuccessDialog(appointmentChangedSuccessfully)` → result: pending → `reload`; confirmed → `removed` (Android removes it from the confirmed list).
   - **Rebook** (completed/canceled/rejected): `showRebookSheet(type "rebook", forOffer: item.offer != null)` → `Rebooked(newId, forOffer)` →
     `context.push(forOffer ? Routes.sessionRequested(newId) : Routes.appointmentRequested(newId))`.
   - **Rate** (completed): `showAddCommentSheet(doctorId, id)` → true → result `reload`.
5. Bookings screen: on `removed` → `cubit.removeAt(index)` (empty → empty state); on `reload` → `cubit.load()`.
6. Tests (cubits): confirmation success/failure; rebook pending returns ChangeRequested without calling the API; rebook completed calls `rebook`; add comment sends `rate: null` for 0.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device (test account, matching Android): cancel a pending booking → confirm → success dialog → item removed; edit a confirmed booking → pick slot → confirm → changed dialog → removed from confirmed;
  edit pending → reloaded; rebook a canceled one → success screen; rate a completed one → list reloads and shows "Reviewed".

## Out of scope
- Appointment/session details screens (T28/T29) — they reuse `BookingActions` there.

## Gotchas
- Android first closes the rebook sheet (`navigateUp`) and then opens the confirmation sheet; do the same order (await the first sheet's result, then show the second).
- Success dialogs are not dismissible and close themselves after 2 s; await them before mutating the list to avoid jumps.
- Use the sheet's own `BuildContext` only inside the sheet; run follow-up flows with the screen's context (check `context.mounted` after every await).
