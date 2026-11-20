# T26 - Bookings tab (list, tabs, search, filters)

## Goal
Port the Bookings tab: guest state, six status tabs, keyword search, filter by period and by type, pull-to-refresh, and the
booking card with its per-status buttons. The button **actions** (cancel/edit/rebook/rate sheets) are wired in T27; here
they call stub callbacks.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/bookings/screen/BookingsFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/bookings/adapter/BookingAdapter.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/bookingsearch/screen/BookingSearchViewModel.kt` (`handleGetBookingByStatus`)
- `app/src/main/java/com/alalmiya/lavender/presentation/sheets/screen/FilterByDateSheet.kt`, `FilterByTypeSheet.kt`
- Layouts: `res/layout/fragment_bookings.xml`, the item layout of `BookingAdapter` (binding name in the adapter), `sheet_filter_by_date.xml`, `sheet_filter_by_type.xml`
- `docs/migration/CONTEXT.md` §7.4 (Bookings, Filter by date / type rows)

## Build
- `lib/features/bookings/bookings_screen.dart`, `bookings_cubit.dart`
- `lib/features/bookings/widgets/booking_card.dart` (reused by T36 "my offer bookings" if the layout matches — check), `status_tabs.dart`
- `lib/features/bookings/filter_by_date_sheet.dart` — `Future<FilterSheetResult<String?>?> showFilterByDateSheet(context, {String? current})`
- `lib/features/bookings/filter_by_type_sheet.dart` — same for type
  (`FilterSheetResult` wraps the value so "confirmed with null (delete all)" differs from "dismissed")
- Router: replace `bookings` (shell tab).
- `test/features/bookings/bookings_cubit_test.dart`

## Steps
1. `BookingsCubit(BookingRepository)`: state `BookingStatus status` (default pending), `String? month`, `String? type`, `String? keyword`, `List<AppointmentData> items`, `viewStatus`, `failure`.
   `load()` → `list(status: status.value, month, keyword, type)` (clear items first, like Android). `selectTab(BookingStatus)`, `setKeyword(String?)` (debounced 1000 ms in the screen; blank → null),
   `setMonth`, `setType` → each calls `load()`. `removeAt(int)` and `reload()` for T27.
2. Guest (not logged in): transparent status bar, the guest action bar from the layout, no search/filter, `StateView.empty(icon: ic_must_login, title: youMustLoginTitle,
   body: youHaveToLoginFirstBodyReservationsAndTrackFavorites, buttonTitle: login, onButton: context.push(Routes.authStart))`, refresh disabled.
3. Logged in: white status bar; title `myBookings`; search field; filter-by-date icon (`ivFilter`) with red dot when `month != null`; filter-by-type icon (`ivFilterByType`) with red dot when
   `type != null && type != 'default'`; scrollable tab row in the order Pending, Confirmed, Processing, Completed, Canceled, Rejected
   (strings `pendingForConfirmation`, `confirmed`, `processing`, `completed`, `canceled`, `rejected`); list; `RefreshIndicator` → `load()`.
4. List states: loading → `LoadingView` in the list area; empty → `StateView.empty(icon: ic_empty_bookings_list, title: noReservationsTitle, body: noReservationsBody)`;
   ServerFailure → `StateView.serverError(body: serverErrorBody2)` (icon `ic_server_error_2`); NetworkFailure → `StateView.connectionLost` (body `noInternetConncetionBody2`, no retry button in Android here — show without button);
   Unknown → toast.
5. Booking card (from the adapter layout): date/time text (`tvTimeOfBooking`), offer badge visible if `offer != null`, doctor image/name/brief/rating text, buttons by status:
   | Status | Buttons |
   |---|---|
   | pending | Cancel → `onCancel`, Edit (enabled + primary bg only if `canReschedule`, else grey) → `onEdit` |
   | confirmed | Cancel, Edit (same rule) |
   | completed | Rate (`rateBooking`, star icon; if `isReviewed` → disabled, text `reviewed`, solid star) → `onRate`; Rebook → `onRebook` |
   | canceled / rejected | Rebook |
   | processing | none |
   Card tap → `offer != null` → `context.push(Routes.sessionDetails(id))` else `context.push(Routes.appointmentDetails(id))`; after returning call `load()` (details may have changed it).
   For now `onCancel/onEdit/onRate/onRebook` show a `// TODO(T27)` toast.
6. Filter by date sheet: three options 3 / 6 / 12 months (strings from the layout), checkbox style, "delete all" clears, confirm returns the value (`"3"`, `"6"`, `"12"` or null).
   Filter by type sheet: all (`default`), normal (`not_offer`), offers (`offer`), "delete all", confirm. Both dismissible.
7. Keep the selected tab and keyword when the user comes back to the tab during the session? Android restores `selectedTabPosition`/`keywordSearch` only while the fragment instance lives
   (back stack). With `go` the screen is rebuilt; keep it simple: defaults on each visit (record in Notes).
8. Back → shell (Home).
9. Tests: tab/month/type/keyword → repository args; blank keyword → null; red-dot conditions.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device with an account with bookings in several statuses: each tab lists the same items as Android, correct buttons per status, Edit disabled when `can_reschedule=false`,
  search after 1 s, both filters work and show red dots, guest sees the login prompt.

## Out of scope
- Cancel / edit / rebook / rate actions (T27). Details screens (T28/T29).

## Gotchas
- Android `BOOKING_ITEM_CANCEL_CLICK_PENDING` sends type `"pending"`, confirmed sends `"confirmed"` — T27 needs the status, so pass the item and its status to the callbacks.
- The keyword search runs only when the field is focused (avoid firing when the text is set programmatically).

## Notes
- Done: `BookingsCubit`, `BookingsScreen` (guest + logged-in views), `BookingCard`, `StatusTabs`, filter by date / type sheets; the `bookings` shell route now builds `BookingsScreen`.
- Filter sheets share `widgets/filter_options_sheet.dart` (`showFilterOptionsSheet`, `FilterSheetResult<T>`, `FilterOption`). `showFilterByDateSheet` / `showFilterByTypeSheet` re-export `FilterSheetResult`. Result is null when dismissed, `FilterSheetResult(null)` for "remove all" + confirm.
- Callbacks `onCancel / onEdit / onRate / onRebook` of `BookingCard` take the `AppointmentData` (its `status`, `id`, `doctor`, `offer` are what T27 needs). The screen currently toasts `TODO(T27)` for them (`_BookingsList` in `bookings_screen.dart`). T27 should use `BookingsCubit.removeAt(index)` / `reload()`; `removeAt` does not show the empty view by itself — the list screen shows it when `items` is empty.
- Defaults on every visit (tab pending, no keyword/filters): the screen is rebuilt on each tab switch, as decided in step 7. Guest -> login flips `SessionCubit.isLoggedIn`, which swaps in the logged-in view and loads.
- Network failure in the list uses `StateView.empty(icon_network_error_2, ...)` instead of `StateView.connectionLost`, because the latter always shows a Retry button and Android shows none here.
- Search uses `DebouncedSearchField(debounce: 1000 ms)`; `TextField.onChanged` only fires on user input, so programmatic changes never trigger a load.
- Only the newest `load()` may update state (stale responses are dropped). Re-tapping the selected tab does nothing.
- Spacing under the date row is approximated (13dp when the offer badge shows, 23dp otherwise) to mimic the ConstraintLayout separator position.
- Not verified on a device / with a real account (no emulator run): checks done are `flutter analyze`, `flutter test` (325 pass), debug APK build.
- Review fixes: the logged-in Bookings screen uses a transparent status bar over the white page (a solid white bar stayed bright above sheets' dimmed barrier). `DebouncedSearchField` (shared with search details) now uses height 1.4 with evenly distributed leading, so the hint/text stay centered and descenders are not clipped.
- `convertTo24HourTime` / `reverseConvertTo24HourTime` now keep only the leading `HH:mm` (Android's lenient `SimpleDateFormat` accepts `HH:mm:ss`; strict parsing returned '' and the booking date line lost its time). Also affects the appointment/session requested screens.
