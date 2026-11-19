# T23 - Doctor details: booking time tab and day/time picker

## Goal
Build the reusable day + time picker (horizontal days, times grid, "open calendar" restricted to active dates) and use it as
the Booking-time tab of doctor details. The same widget is reused by the change-appointment (T24) and rebook (T27) sheets.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/bookingappointments/screen/BookingAppointmentsFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/bookingappointments/adapter/BookingDaysAdapter.kt`, `AvailableTimesAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/utilities/AvailableDatesValidator.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/filter/sheet/CalenderDateAndTimeSheet.kt` (defined in the graph but no UI opens it — not ported)
- Layouts: `res/layout/fragment_booking_appointments.xml`, `recycler_appointment_day_selected.xml`, `recycler_available_time_item.xml`,
  drawables `bg_btn_primary_color.xml`, `bg_rect_rounded_16_color_white_stroke_grey.xml`
- `docs/migration/CONTEXT.md` §7.4 (Booking time tab row), §5.4 (WorkTimeModel, TimeModel)
- `lib/core/utils/date_utils.dart`

## Build
- `lib/features/booking/widgets/day_time_picker.dart` — `DayTimePicker({required List<WorkTimeModel> days, WorkTimeModel? selectedDay, TimeModel? selectedTime, required ValueChanged<WorkTimeModel?> onDayChanged, required ValueChanged<TimeModel?> onTimeChanged, bool showCalendarButton = true})`
- `lib/features/booking/widgets/day_chip.dart`, `time_chip.dart`
- `lib/features/booking/day_time_logic.dart` — pure functions: `initialDay(days)`, `findDayForDate(days, DateTime)`, `activeDates(days)`
- Update `doctor_details_screen.dart` tab 0 to use `DayTimePicker` with `doctor.workTimes`.
- `test/features/booking/day_time_logic_test.dart`

## Steps
1. Pure logic (test it):
   - `initialDay`: first element of the list (Android `submitList` always selects index 0, even if inactive — then shows "no available times today" when `is_active == 0` or times empty).
   - `activeDates`: dates of days with `isActive == 1`, parsed from ISO, date-only (UTC).
   - `findDayForDate(days, date)`: the day whose `convertIsoToDateOnly(date)` equals the picked date; return it only if `isActive != 0`.
2. Day chip (`recycler_appointment_day_selected.xml`): `day_translated` + `formatDateToDayMonth(date)`. Inactive → white bg grey stroke, text `cE6E6E6`, not tappable.
   Active selected → primary rounded bg, white texts; active unselected → white bg grey stroke, day `c3D4C5E`, date `c251836`. Tapping the selected day does nothing.
3. Time chip (`recycler_available_time_item.xml`): shows `time`. Reserved → grey look, not tappable. Selected → primary bg white text. Tapping the selected time unselects it.
4. Picker behavior (port `BookingAppointmentsFragment`):
   - On new `days`: select `initialDay`, clear time; if `days` empty → hide days/times/"select appointment"/separator/calendar button and show
     `StateView.empty(icon: ic_no_available_bookings, title: noAvailableTimesToday)`; if first day inactive or has no times → show days but replace the times grid with that empty view.
   - Changing day clears the time and shows that day's times or the empty view.
   - "Open calendar" (`tvOpenCalender`) → `showDatePicker(initialDate: first active date or today, firstDate: earliest active, lastDate: latest active, selectableDayPredicate: date in activeDates, helpText: l10n.calender)`.
     Result → `findDayForDate`: null or inactive → toast `selectedDayNotAvailableYet` (failed); else select it, scroll the days list to it, clear time, show its times/empty view.
5. Parent wiring: `onDayChanged` → `cubit.selectDay`, `onTimeChanged` → `cubit.selectTime`. The value sent later is `TimeModel.timeFormatted` and the day's `date`/`formated_date`/`day_translated` (draft fields in T22).
6. Scroll the selected day into view (use a `ScrollController` and fixed item extent from the layout).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device next to Android with the same doctor: same days/greyed days, first day preselected, reserved times greyed, unselect by second tap, calendar allows only active dates,
  picking a day selects/scrolls it; Book button now proceeds (to placeholder) only with day+time selected.

## Out of scope
- Book appointment screen (T24). Work-times API loading (only used by the sheets in T24/T27; this tab uses `doctor.work_times`).

## Gotchas
- Android `AvailableDatesValidator` compares UTC midnight millis; compare `DateTime(y, m, d)` values, not instants, to avoid timezone shifts.
- `selectedDate` in Android picker is formatted with `Locale.ENGLISH` — keep English digits in any string you build.

## Notes
- Done: `lib/features/booking/day_time_logic.dart` (`initialDay`, `activeDates`, `findDayForDate`, plus `dayHasTimes`), `widgets/day_chip.dart`, `time_chip.dart`, `day_time_picker.dart`; doctor details tab 0 now uses `DayTimePicker(days: doctor.workTimes, ...)`. Tests in `test/features/booking/day_time_logic_test.dart`.
- `DayTimePicker` is controlled by the parent (`selectedDay`/`selectedTime`). On first build and when `days` changes it calls `onDayChanged(initialDay)` + `onTimeChanged(null)` in a post-frame callback; picking a day also clears the time. T24/T27 sheets can reuse it with `showCalendarButton` as needed.
- Deviation from step 6: days are a plain horizontal `Row` with a `GlobalKey` per chip and `Scrollable.ensureVisible` (chips are wrap-content like Android, so no fixed extent).
- The empty view is inside a fixed 240-high box (`StateView` centers in bounded space only). With no days, the days row, separator, and calendar button are hidden but the "Appointments available" title stays, like Android.
- Date picker uses the platform `showDatePicker`; `selectableDayPredicate` compares date-only values, so no timezone shift.
- Not verified on a device.
