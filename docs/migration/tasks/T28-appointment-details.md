# T28 - Appointment details and report download

## Goal
Port the appointment details screen (status pill, actions by status, attached medical report download) and the shared
file-download helper used later by session details and my reports.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/appointmentdetails/AppointmentDetailsFragment.kt` (whole file), `AppointmentDetailsViewModel.kt`
- `res/layout/fragment_appointment_details.xml` and the status pill drawables referenced in the Kotlin (`tvStatus.background` per status)
- `docs/migration/CONTEXT.md` §7.4 (Appointment details row), §8 (File download)
- `lib/features/bookings/actions/booking_actions.dart` (T27), `lib/features/booking/widgets/doctor_summary_card.dart` (T24)

## Build
- `lib/features/appointment_details/appointment_details_screen.dart`, `appointment_details_cubit.dart`
- `lib/features/appointment_details/widgets/status_pill.dart` (colors per status; reused by T29/T36)
- `lib/core/utils/file_downloader.dart` — `Future<void> downloadFile(BuildContext, {required String url, required String title})`
- Router: replace `appointmentDetails`.

## Steps
1. `flutter pub add background_downloader`. `downloadFile`: enqueue a `DownloadTask(url: url, filename: <last path segment or "<title>.pdf">, baseDirectory: BaseDirectory.applicationDocuments? ...)`
   — Android uses the public Downloads folder with a system notification "Downloading <title>" and "completed". Use
   `FileDownloader().configureNotification(running: TaskNotification(title, l10n.downloadingWithValue(title)), complete: TaskNotification(title, ...), progressBar: true)` and after completion
   `FileDownloader().moveToSharedStorage(task, SharedStorage.downloads)`. Show a toast on failure (`connectionError`).
   Add to the Android manifest what the package's README requires for notifications/foreground (only what it requires).
2. Cubit loads `BookingRepository.details(id)`; `reload()`.
3. Screen from the layout: title `bookingDetailsWithValue("(#id)")`, status pill text `status_trans` with per-status bg/text color (pending → primary text, confirmed → `c251836`,
   completed → `c50C878`, canceled/rejected → `cED1C24`, processing → `c006F98`; take the backgrounds from the Kotlin), doctor card, date, from–to, duration, price, notes/`noDescription`.
4. Actions by status (same rules as the booking card, through `BookingActions`): pending/confirmed → Cancel + Edit (`canReschedule`); completed → Rate (disabled if reviewed) + Rebook;
   canceled/rejected → Rebook; processing → none. After `removed`/`reload` results → `reload()` (Android reloads details instead of removing).
5. Report row visible when `report != null` (completed): title `medicalReportPdf`, tap the row or the download icon → `downloadFile(url: report, title: l10n.medicalReportPdf)`.
6. Errors: server → serverError with button back (check Kotlin: one branch navigates up); network → connectionLost(retry); unknown → toast.
7. Back → `context.pop()`.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: details match Android per status; all actions work and refresh the screen; a completed appointment with a report downloads the PDF into Downloads with a notification.

## Out of scope
- Session details (T29), opening from notifications (T39).

## Gotchas
- On Android 13+ the download notification needs POST_NOTIFICATIONS, which is requested in T39 — the download itself must work without it.
- The appointment id can also come from a notification (`appointmentId` extra in Android) — the route path id covers both.

## Notes
- Built on the T27 branch (`T27-T28-booking-actions-appointment-details`); T27 changes there are still uncommitted/unticked.
- `AppointmentDetailsScreen` + `AppointmentDetailsCubit` (load/reload), `StatusPill` / `statusPillColors(BookingStatus?)` in `features/appointment_details/widgets/status_pill.dart` (reuse in T29/T36).
- Actions go through `BookingActions`; any `removed`/`reload` result reloads the details. Rebook pushes the requested screen (no reload).
- Errors: 404 → "no data to preview" + Back; other server → server error (no button, like Android); network → retry; unknown → toast.
- `downloadFile(context, url:, title:)` in `core/utils/file_downloader.dart` (`background_downloader`): downloads into app documents, then `moveToSharedStorage(downloads)`; running/complete notifications are configured globally on each call; failure → `connectionError` toast. File name = last URL segment if it has an extension, else `<title>.pdf`.
- Manifest: added `POST_NOTIFICATIONS` (per the package docs); the runtime request is T39 and the download works without it.
- Not verified on a device (analyze, 338 tests and the debug APK build pass).
