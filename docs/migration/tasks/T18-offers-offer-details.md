# T18 - Offers list and offer details

## Goal
Port the medical offers list (filtered by specialty tabs) and the offer details screen with the "get offer" button that
leads to purchase (logged in) or the must-login sheet (guest).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/offers/screen/OffersFragment.kt`, `OffersViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/offers/adapter/OffersAdapter.kt`, `OffersTabAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/offerdetails/screen/OfferDetailsFragment.kt`
- Layouts: `res/layout/fragment_offers.xml`, the item layouts used by `OffersAdapter`/`OffersTabAdapter` (see their binding classes), `fragment_offer_details.xml`
- `docs/migration/CONTEXT.md` §7.4 (Offers, Offer details rows)

## Build
- `lib/features/offers/offers_screen.dart`, `offers_cubit.dart`, `widgets/offer_card.dart`, `widgets/specialty_tabs.dart`
- `lib/features/offers/offer_details_screen.dart`, `offer_details_cubit.dart`
- Router: replace `offers`, `offerDetails`.

## Steps
1. `OffersCubit(SpecialitiesRepository, OffersRepository)`: `load()` → specialties; select the first; `selectTab(id)` → `bySpecialty(id)`.
   Two independent statuses: `tabsStatus` (whole-screen loading/error) and `listStatus` (list area loading/error/empty).
2. Offers screen: transparent status bar, content under it (Android uses `LAYOUT_FULLSCREEN`) — check the header in `fragment_offers.xml`.
   Horizontal specialty chips (selected style from `OffersTabAdapter`), tapping scrolls the tapped chip into view and loads its offers.
   List cards from `OffersAdapter` (rotated discount like Home, language dependent). Empty → `StateView.empty(title: noOffersTitle, body: noOffersBody)`
   (icon from the Kotlin). Pull to refresh reloads the selected tab. Tap → `context.push(Routes.offerDetails(id))`. Back → pop.
   Errors: tabs → serverError / connectionLost(retry load); list → serverError / connectionLost (no retry button in Android — keep).
3. `OfferDetailsCubit(OffersRepository, int id)` → `details(id)`.
4. Offer details screen: transparent status bar with **light** icons over the banner image. Banner, name, description, discount badge
   (rotated −10° ar / +10° en for label and value), old price strikethrough, final price, duration `"${start_date}:${end_date}"`,
   bookings count: `number == 1` → `oneTime`, `0` → `none`, else `moreThanOneTimeWithValue(number)`, details text.
   Errors: `ServerFailure(404)` → `StateView.empty(title: l10n.thisOfferNoLongerAvailable, buttonTitle: l10n.back, onButton: pop)` (icon from Kotlin);
   other server → serverError; network → connectionLost(retry).
5. "Get offer" `ProgressButton`: logged in → `context.push(Routes.purchaseOffer, extra: offer)`; guest → `showMustLoginSheet(context)`.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: tabs switch lists; empty specialty shows empty view; details look like Android incl. rotated badge in ar/en; invalid id shows "no longer available"; guest gets the must-login sheet.

## Out of scope
- Purchase and payment (T37).

## Gotchas
- Offer details can be opened by a notification with `offerId` (T39) — keep the route id-based.
- `start_date`/`end_date` are shown raw (no formatting).
