# T16 - Home

## Goal
Port the Home tab: greeting, notifications badge, search bar, next-reservation card (or guest card), banners, specialties
grid, newly added doctors with favorite toggle and special offers. It is the first real tab and defines widgets reused later
(doctor card, specialty item).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/home/screen/HomeFragment.kt`, `HomeViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/home/adapter/BannersAdapter.kt`, `SpecialitiesAdapter.kt`, `DoctorsAdapter.kt`, `SpecialOffersAdapter.kt`
- Layouts: `res/layout/fragment_home.xml`, `recycler_next_reservation.xml`, `recycler_item_banners.xml`, `recycler_offer_item.xml`,
  `recycler_item_specialities.xml`, `recycler_item_speciality.xml`, `recycler_item_newly_added_doctors.xml`, `recycler_item_doctor.xml`,
  `recycler_item_special_offers.xml`, `recycler_item_special_offer.xml` (open each `<include>`/item layout referenced)
- `docs/migration/CONTEXT.md` §7.4 (Home row), §11 items 9, 11
- `lib/data/repositories/home_repository.dart`, `general_repository.dart`

## Build
- `lib/features/home/home_screen.dart`, `home_cubit.dart`
- `lib/features/home/widgets/greeting_header.dart`, `next_reservation_card.dart`, `guest_card.dart`, `banners_section.dart`,
  `specialities_section.dart`, `speciality_item.dart` (reused T17/T19), `doctor_card.dart` (reused T20/T30), `special_offer_card.dart`, `section_header.dart`
- Router: replace `home` placeholder (inside the shell).
- `test/features/home/home_cubit_test.dart`

## Steps
1. `HomeCubit(HomeRepository, GeneralRepository, AppPrefs)`: `load()` → status loading; call `getHome()`; in parallel `getSettings()` and on success
   save `prefs.allowNotifications` and `prefs.whatsAppNumber` (ignore its failure). State: `HomeData? data`, `List<DoctorModel> doctors`, status, failure.
   `toggleFavorite(int index)`: flip `doctors[index].isFav` immediately (optimistic), call `toggleFavorite(id)`; on failure flip back and expose the failure for a toast.
2. Header: avatar (logged in: `user_image` circle with loader; guest: `ic_guest_profile`), greeting by hour (0–11 `goodMorning`, 12–17 `goodAfternoon`, else `goodEvening`)
   with argument `", <first word of user_name>"` (guest: `""`), notifications bell → `context.push(Routes.notifications)`, badge text
   hidden if null/0, `"+99"` if > 99. Search box (not editable) → `context.go(Routes.search)` (Android navigates to the search destination; with tabs, `go` selects the Search tab).
3. Next reservation (logged in, `next_reservation != null`): hours = `difference ~/ 3600`, minutes = `(difference % 3600) ~/ 60`, labels `hour`/`minute`,
   doctor image/name, `sub_specialty ?? specialty`, read-only `StarRating(rate)`, text `rateNumberOfReviewsWithValues(truncate(rate,1), reviewsWithNumber(reviews_count))`.
   Tap → `context.push(Routes.appointmentDetails(id))`. Guest: guest card with a tappable text → `context.push(Routes.authStart)`.
4. Sections (each hidden when its list is **empty**; shown if null like Android's `isEmpty() == true` check — null shows an empty section; prefer hiding for null too and note it):
   - Banners: horizontal list (`recycler_offer_item.xml`), tap → `context.push(Routes.offerDetails(banner.offerId))`.
   - Specialities: build list = `[SpecialityModel(id: 0, name: l10n.medicalOffers)] + (list.length >= 8 ? list.take(7) : list)`.
     Index 0 shows `ic_gift` and `medicalOffers` → `context.push(Routes.offers)`. Index 7 shows `ic_more` + `more` → `context.push(Routes.allSpecialities)`.
     Others: network image + name → `context.push(Routes.searchDetails, extra: speciality)`. "Show all" → all specialities.
   - Doctors (`recycler_item_doctor.xml`): image, name, brief, StarRating, `(rate) N reviews` text, duration `minValues(duration)`, price `formatDecimal`,
     heart only when logged in with a scale bounce animation (1 → 1.4 → 1, 180 ms, overshoot), tap card → `context.push(Routes.doctorDetails(id))`.
   - Special offers (`recycler_item_special_offer.xml`): image, title, brief, old price strikethrough, new price, discount badge rotated
     +10° (en) / −10° (ar) for both label and value (match the Kotlin: label `en ? 10 : -10`, value `ar ? -10 : 10`), "show all" → offers, tap → offer details.
5. Loading: full-screen `LoadingView`, content hidden. Errors: `ServerFailure` → `StateView.serverError(title: l10n.somethingWrongHappen)`;
   `NetworkFailure` → `StateView.connectionLost(onRetry: load)`; Unknown → toast. Favorite failure → revert + toast.
6. Load on first build; also reload when coming back? Android loads in `initializeComponents` (every time the view is recreated, i.e. every time
   you return to the Home tab). Reload on each tab selection of Home: call `load()` in `initState` (the shell rebuilds the tab child on `go`).
7. Status bar white with dark icons.
8. Tests: specialities list building (0 → offers item, >= 8 → 7 + more), favorite optimistic toggle and revert on failure, settings saved.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device side-by-side with the Android app (same account): same greeting, badge, next reservation countdown, sections and order, same item looks in ar and en;
  guest mode shows guest card and no hearts; airplane mode → connection-lost view with Retry.

## Out of scope
- Destination screens (placeholders until their tasks). Notification count refresh from push (T39).

## Gotchas
- `difference` is seconds (Long).
- The Android specialities adapter shows "More" only on Home (`inHome`), not on All specialities.
- Prices use English digits; the doctor `price` is a String — parse with `double.tryParse`.
