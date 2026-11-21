# T36 - My offers and my offer details

## Goal
Port the user's purchased offers (valid / completed tabs) and the offer details with its "General info" and "Bookings" tabs.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/myoffers/screen/MyOffersFragment.kt`, `myoffers/adapter/MyOffersAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/myofferdetails/screen/MyOfferDetailsFragment.kt`, `MyOfferBookingsFragment.kt`, `MyOfferGeneralInfoFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/myofferdetails/adapter/MyOfferBookingsAdapter.kt` (incl. `numberToOrdinalWord`)
- Layouts: `res/layout/fragment_my_offers.xml`, `fragment_my_offer_details.xml`, `fragment_my_offer_bookings.xml`, `fragment_my_offer_general_info.xml`, adapter item layouts
- `docs/migration/CONTEXT.md` §7.4 (My offers, My offer details rows)
- `lib/features/appointment_details/widgets/status_pill.dart` (T28)

## Build
- `lib/features/my_offers/my_offers_screen.dart`, `my_offers_cubit.dart`, `widgets/my_offer_card.dart`
- `lib/features/my_offers/my_offer_details_screen.dart`, `my_offer_details_cubit.dart`, `widgets/offer_general_info_tab.dart`, `widgets/offer_bookings_tab.dart`, `widgets/offer_session_card.dart`
- `lib/features/my_offers/ordinal.dart` — port of `numberToOrdinalWord` (+ test)
- Router: replace `myOffers`, `myOfferDetails`.

## Steps
1. My offers: transparent status bar with dark icons (copy Kotlin); toggle Valid / Completed (strings from layout, `completed`); one `myOffers()` call, show
   `available_offers` or `completed_offers` per selection (Android refetches on each toggle — refetch too). Empty state per Kotlin. Card tap → `context.push(Routes.myOfferDetails(id))`. Back → pop.
2. My offer details: `myOfferDetails(id)` → header name/description, image, a "book" button → `context.push(Routes.searchDetails, extra: offer.specialtyModel)` (only if non-null);
   two custom tabs (same tab style as doctor details) "General info" / "Bookings" in an `IndexedStack`.
   - General info: duration `start_date – end_date` (format from Kotlin), subscription date `created_at`, sessions `numberOfSessionsWithValue(used, number)` (check arg order in Kotlin), details.
   - Bookings: list of `appointments`; empty view when empty; each card shows `formated_date`, status pill — for completed the text is `sessionWithValue(ordinal(position+1, lang))`, else `status_trans`;
     doctor info; tap → `context.push(Routes.sessionDetails(appointment.id))`.
3. Errors per Kotlin (server/network + retry). Status bar transparent per `onResume`.
4. Test `ordinal` for 1..10 in ar and en (copy the Kotlin table).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: same offers per tab as Android; details tabs match; completed sessions show "Session first/second…"; tapping a session opens session details.

## Out of scope
- Buying offers (T37).

## Gotchas
- The id can come from a notification of type `user_offer` (T39).

## Notes
- Done: `lib/features/my_offers/*` (cubits, screens, `my_offer_card`, `offer_general_info_tab`, `offer_bookings_tab`, `offer_session_card`, `ordinal.dart`). Routes myOffers/myOfferDetails replaced.
- Kotlin argument order for `numberOfSessionsWithValue` is (number, used_number); the duration is `start_date:end_date` (colon, no spaces); the second tab label is `showBookings`; the button label is `checkTheDoctors`.
- The toggle refetches `myOffers()` on every change (same tab = nothing). Pull to refresh refetches. Unknown failures are only toasted.
- `myOfferDetails` route is id based (user-offer id) so T39 can open it from a notification.
- Tests: `ordinal_test.dart` (1..10 en/ar, compounds, fallbacks) and `my_offers_cubits_test.dart`.
