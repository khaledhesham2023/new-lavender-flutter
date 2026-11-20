# T24 - Book appointment, change appointment sheet, successful request

## Goal
Port the normal booking confirmation screen (notes + book), the "change appointment" sheet that re-picks day/time from the
work-times API, and the success screen that loads the created appointment.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/bookappointment/screen/BookAppointmentFragment.kt`, `BookAppointmentsViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/sheets/screen/ChangeAppointmentSheetFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/successfulappointmenttrequest/SuccessfulAppointmentRequestFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/appointmentdetails/AppointmentDetailsViewModel.kt`
- Layouts: `res/layout/fragment_book_appointment.xml`, `sheet_change_appointment.xml`, `fragment_successful_appointment_request.xml`
- `docs/migration/CONTEXT.md` §7.4 (Book appointment, Change appointment sheet, Successful appointment request rows)
- `lib/features/booking/widgets/day_time_picker.dart` (T23)

## Build
- `lib/features/booking/book_appointment_screen.dart`, `book_appointment_cubit.dart`
- `lib/features/booking/widgets/doctor_summary_card.dart` (doctor image/name/brief/rating used on booking & success screens; reused in T25–T29)
- `lib/features/booking/change_appointment_sheet.dart` (+ `change_appointment_cubit.dart`) — `Future<ChangeAppointmentRequest?> showChangeAppointmentSheet(BuildContext, int doctorId)`
- `lib/features/booking/appointment_requested_screen.dart`, `appointment_requested_cubit.dart`
- Router: replace `bookAppointment`, `appointmentRequested`.

## Steps
1. `BookAppointmentCubit(BookingRepository, BookingDraft)`: state = draft (day/time can be replaced), notes, status. `changeTo(ChangeAppointmentRequest r)`
   updates `date = r.day`, `time = r.time`, display texts. `book(notes)` → `save(SaveAppointmentRequest(doctor_id, day: convertIsoToDateOnly(date), time, notes: notes.trim().isEmpty ? null : notes.trim()))`
   → emit `booked(appointmentId)`.
2. Screen from `fragment_book_appointment.xml`: back, `DoctorSummaryCard`, day text (initially `draft.formattedDate`), time `convertTo24HourTime(time)`,
   duration `minValues(duration)`, price `formatDecimal(price)`, notes multi-line field (`etDiagnosis`), "change appointment" link →
   `final r = await showChangeAppointmentSheet(context, draft.doctorId)`; if non-null → `changeTo(r)` and day text = `"${r.dayName},${convertDateToReadableFormat(convertIsoToDateOnly(r.day))}"`.
   Book `ProgressButton` (loading + disabled while saving) → on `booked(id)` → `context.push(Routes.appointmentRequested(id))`. Errors → toast.
3. Change appointment sheet (not dismissible by outside tap/drag, `isCancel = false`): own cubit loads `BookingRepository.workTimes(doctorId)`;
   shows `DayTimePicker`; confirm: no day → toast `pleaseSelectDay`; no time → `pleaseSelectTime`; else `Navigator.pop(context, ChangeAppointmentRequest(doctorId, day: selectedDay.date, dayName: selectedDay.dayTranslated, time: selectedTime.timeFormatted))`.
   Cancel button → pop null. Errors: server → serverError with button `back` → pop; network → connectionLost(retry).
4. Appointment requested screen: cubit loads `BookingRepository.details(id)`. Title `bookingDetailsWithValue("(#id)")` (or `bookingDetails` if id null),
   `formated_date`, `fromToValues(convertTo24HourTime(from), convertTo24HourTime(to))`, price, duration, notes or `noDescription`, doctor card.
   "Go to reservations" → `context.go(Routes.bookings)`. Back arrow / system back → `context.go(Routes.home)` (Android pops to Home).
   Errors: server → serverError; network → connectionLost(retry); unknown → toast.
5. Status bars white with dark icons.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: book a real slot from doctor details → success screen shows the same data as Android; "change appointment" picks another slot and the booking uses it;
  booking a reserved slot shows the server message toast; back on success returns to Home.

## Out of scope
- Booking with an offer and the appointment type sheet (T25). Bookings tab (T26).

## Gotchas
- The draft `date` is the ISO string from `WorkTimeModel.date`; the API wants `yyyy-MM-dd`.
- After returning from the change sheet the time shown is `convertTo24HourTime(time_formatted)` (Android does that) — verify it displays correctly; if `time_formatted` is already 12-hour text, record the observed behavior in Notes.

## Notes
- Done: `book_appointment_{screen,cubit}.dart`, `change_appointment_{sheet,cubit}.dart`, `appointment_requested_{screen,cubit}.dart`, `widgets/doctor_summary_card.dart` (`bordered` for the success-screen card) and `widgets/booking_info_card.dart` (bordered 12-radius card + value/label-value lines, shared with T25+). Router: `bookAppointment` and `appointmentRequested` now build the real screens. Tests: `test/features/booking/booking_cubits_test.dart`. Analyze, tests and debug APK pass; **not run on a device**.
- `BookAppointmentCubit.changeTo(r, lang:)` takes the UI language to build `"<dayName>,<dd MMMM yyyy>"`. Book result is one-shot state (`bookedId` / `failure`); the screen calls `consume()` after handling it.
- Time display uses `convertTo24HourTime(time_formatted, lang)` (it parses `HH:mm`, returns 12-hour). If the API ever sends `time_formatted` as 12-hour text it would show empty: verify on a device.
- Change sheet: Android hides Confirm/Cancel while the selected day has no times (kept); back still closes it with null. Unknown failures also toast; any non-network failure shows the server-error view with a `back` button.
- Footer of both screens is pinned to the bottom when content is short and scrolls with the content otherwise (`SliverFillRemaining`), like Android's `fillViewport`.
- Success screen reuses `SpeedLottie` from `features/auth/widgets/` for the two confetti animations (layout approximated, check visually).
