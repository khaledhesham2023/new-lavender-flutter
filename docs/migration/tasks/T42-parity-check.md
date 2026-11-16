# T42 - Parity check against the Android app

## Goal
Verify, screen by screen and flow by flow, that the Flutter app behaves like the Android app, and produce a list of remaining
differences for the owner. No new features.

## Read first
- `docs/migration/PLAN.md` §6 (coverage table) and every task file's `## Notes`
- `docs/migration/CONTEXT.md` §7, §11

## Build
- `D:\flutter\New folder\lavenderk\docs\migration\PARITY.md` — results table (create it next to PLAN.md).
- Small fixes only if they are clearly a missed port detail inside an already-finished task's scope (one-line style/string/condition fixes). Anything bigger → listed, not fixed.

## Steps
1. Install the Android app (`./gradlew installGoogleDebug` from `D:\flutter\New folder\lavenderk`, or the owner's build) and the Flutter debug app on two emulators/devices with the same account and language.
2. For every row of PLAN §6 (except "not ported") and every flow below, compare and record `OK` / `DIFF: <what>` / `N/A`:
   - First launch → onboarding → guest → browse home, specialities, offers, search, doctor details, must-login prompts.
   - Register → OTP → home; logout → onboarding on next launch; login unverified → OTP; reset password flow.
   - Book normal appointment (incl. change slot), book with offer, success screens and back behavior.
   - Bookings: every tab, search, both filters, cancel / edit / rebook / rate from the list and from details (appointment and session).
   - Favorites add/remove from home, search details, doctor details; favorites tab.
   - Notifications: list, paging, swipe delete, switch, tap routing; push in foreground/background/killed; tap routing cold/warm.
   - Profile: edit profile (photo, name, email, phone + OTP), change password (+ forgot path), language switch both ways, contact us + WhatsApp, about app/us, terms, privacy, rate app, delete account (on a throwaway account).
   - My offers, my offer details tabs, purchase with a Tap **test** card, success screen.
   - My reports, downloads (appointment/session/report).
   - Deep link `/doctor/<id>` cold/warm logged in and guest.
   - Arabic RTL and English LTR on: home, booking flow, bookings, profile.
   - Error states: airplane mode on home, doctor details, bookings, offers; server error (wrong id) on offer details (404 view).
3. Check the decisions D8–D10 are implemented (channel + permission, Play Store, no `Authorization: null` — verify with the debug log of one guest request).
4. Run final checks and record versions in PARITY.md: `flutter --version`, package versions (`flutter pub deps --style=compact | head`), APK size.
5. List open questions collected from all task Notes (e.g. timer initial text).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; release and debug builds succeed.
- `docs/migration/PARITY.md` exists with every row filled and a "Remaining differences" and "Open questions" section.

## Out of scope
- Redesigns, new features, iOS.

## Gotchas
- Use the same server data for both apps at the same time; bookings change state, so compare right after each action.
