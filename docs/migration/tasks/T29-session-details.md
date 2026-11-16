# T29 - Session details

## Goal
Port the details screen for an appointment booked with an offer (a "session"): like appointment details plus the offer name and
remaining sessions, with rebook marked `forOffer`.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/sessiondetails/screen/SessionDetailsFragment.kt` (whole file)
- `res/layout/fragment_session_details.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/offers/screen/OffersViewModel.kt` (`handleGetSessionDetails`)
- `docs/migration/CONTEXT.md` §7.4 (Session details row), §5.4 (SessionDetailsModel)
- T28 files (`status_pill.dart`, `file_downloader.dart`), `booking_actions.dart`

## Build
- `lib/features/session_details/session_details_screen.dart`, `session_details_cubit.dart`
- Router: replace `sessionDetails`.

## Steps
1. Cubit loads `OffersRepository.session(id)`.
2. Screen: title `bookingDetailsWithValue("(#id)")`, status pill, doctor card, offer name, `remainingSessions(number, used_number)`, duration, date, from–to,
   notes/`noDescription`, report row (download) when `report != null`.
3. Actions by status via `BookingActions` (convert the session to the fields the actions need: id, doctor id, status, `canReschedule` — **default false** here):
   pending/confirmed → Cancel + Edit; completed → Rate + Rebook (`forOffer: true`); canceled/rejected → Rebook (`forOffer: true`); processing → none.
   After any action result → `reload()`.
4. Errors as T28 with retry → reload. Back → pop.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: a session from an offer booking shows the same data and actions as Android; rebook goes to the session-requested success screen.

## Out of scope
- My offer details list (T36).

## Gotchas
- `SessionDetailsModel.can_reschedule` defaults to **false** (unlike AppointmentData).
