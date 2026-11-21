# T37 - Purchase offer (Tap payment) and successful purchase

## Goal
Port the purchase screen with Tap Payments (goSell) and the post-purchase success screen. This is the riskiest integration:
real money moves in release builds.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/purchaseoffer/screen/PurchaseOfferFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/tapPayment/TapPaymentHelper.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/successfulofferpurchase/SuccessfulOfferPurchaseFragment.kt`
- `app/build.gradle.kts` (`PAYMENT_KEY`, goSell dependency `com.github.Tap-Payments:goSellSDK-Android:2.16.1`)
- Layouts: `res/layout/fragment_purchase_offer.xml` (+ include `lPaymentMethod`), `fragment_successful_offer_purchase.xml`, `charge_status_layout.xml`
- `docs/migration/CONTEXT.md` §7.4 (Purchase offer, Successful offer purchase rows), §8 (Tap)
- `docs/migration/PLAN.md` decision D14
- pub.dev page and README of `go_sell_sdk_flutter` (latest 2.4.x)

## Build
- `lib/features/purchase_offer/purchase_offer_screen.dart`, `purchase_offer_cubit.dart`
- `lib/features/purchase_offer/tap_payment_service.dart` — the only file that imports the Tap plugin: `Future<PaymentOutcome> pay({required double amount, required String lang, String? name, String? phone, String? email})`
  with `sealed class PaymentOutcome { Paid(String chargeId) | Cancelled() | Failed(String message) }`
- `lib/features/purchase_offer/offer_purchased_screen.dart`, `offer_purchased_cubit.dart`
- Router: replace `purchaseOffer`, `offerPurchased`.

## Steps
1. `flutter pub add go_sell_sdk_flutter`. Follow its README for Android setup (minSdk, Gradle repositories such as jitpack, manifest entries). If it requires a higher minSdk than 24
   or does not build with the current Gradle/AGP, **stop and report** (D14).
2. `TapPaymentService.pay`: configure with secret key `Env.paymentKey`, bundle id `com.alalmiya.lavender`, language `lang`; session: transaction mode PURCHASE, currency `SAR`, amount,
   customer (first/middle/last name = full name, email, phone country code `966` + number), `isUserAllowedToSaveCard: true`, `isRequires3DSecure: true`,
   payment type ALL/CARD (Android uses the card form), receipt sms/email false, empty items/metadata, windowed appearance if the plugin supports it.
   Map the plugin result: success → `Paid(chargeId)`, cancelled → `Cancelled`, failure/sdk error → `Failed(message)`.
3. Purchase screen from the layout: offer image/name/brief, old price strikethrough, final price, price before/after discount, discount %, payment method radio row (single "card" option),
   terms checkbox + "terms and conditions" link → `context.push(Routes.terms)`. The pay `ProgressButton` is enabled only when **both** the checkbox and the radio are checked.
4. `PurchaseOfferCubit(OffersRepository, TapPaymentService, SessionCubit)`: `pay(offer)` → `pay(amount: offer.finalPrice ?? 0, lang, name/phone/email from session.user)`;
   `Paid` → `buy(offer.id)` → emit `purchased(userOfferId)`; `Cancelled` → nothing; `Failed` → toast (Android shows a small popup with the message — a failed toast is the substitute; note it).
   On `purchased` → `context.push(Routes.offerPurchased(id))`.
5. Offer purchased screen: `myOfferDetails(id)` → image, name, brief, prices, duration `"${start_date} : ${end_date}"`, bookings count (same rules as offer details),
   hint `thisOfferAppliesOnSpecialty(specialty_model.name)`, button "go to doctors" → `context.push(Routes.searchDetails, extra: specialtyModel)`. Back → `context.go(Routes.home)`.
   Errors: server → serverError; network → connectionLost (retry calls `details` in Android — use `myOfferDetails`, note the Android bug in Notes).
6. Test with the **debug env (Tap test key)** and Tap's test cards only.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device with the debug env: button enables only with both checks; the Tap card sheet opens in Arabic/English; a Tap test card succeeds → `POST client/offers` → success screen shows the offer;
  cancelling the sheet keeps the user on the screen; a declined test card shows an error.

## Out of scope
- Saved cards listing (Android has `listSavedCards` with a hard-coded customer id — unused).

## Gotchas
- **Never** run a payment with `env/release.json` during development (live key).
- Android calls `buyOffer` only after `paymentSucceed`; do not call it on authorization or tokenization callbacks.
- The secret key lives in the app (same as Android). Flag in Notes that this is a security concern for the owner (not to be changed in this task).

## Notes
- **Blocker found (D14); owner decided to keep the vendored patch (no platform channel).** `go_sell_sdk_flutter` 2.4.29 does not build with this project's Gradle 9 / AGP 9.3.1: its `android/build.gradle` calls `jcenter()` (removed in Gradle 9) and pins AGP 8.6.0 / compileSdk 35. I did **not** switch to the platform-channel fallback. To keep going I vendored a patched copy of the plugin at `third_party/go_sell_sdk_flutter/` (pubspec `path:` dependency; only `android/build.gradle` changed: `jcenter()` removed, `mavenCentral()` + jitpack, AGP pin removed, compileSdk 36, Java 17; `example/` and `ios/` dropped; excluded from `flutter analyze`). With it `flutter build apk --debug` succeeds. The owner must choose: keep the vendored patch (needs an update strategy for new plugin versions) or the D14 fallback (platform channel to `goSellSDK-Android`). The plugin uses `goSellSDK-AndroidX:3.19.44`, not Android's `2.16.1`.
- Done: `lib/features/purchase_offer/` — `tap_payment_service.dart` (only file importing the plugin; `PaymentOutcome` = `Paid | Cancelled | Failed`; `paymentOutcomeFromResult` maps the plugin result map and counts only `sdk_result == SUCCESS` with `trx_mode == CHARGE` and a charge id as paid), `purchase_offer_cubit.dart`, `purchase_offer_screen.dart`, `offer_purchased_screen.dart`, `widgets/offer_summary_card.dart`. Routes `purchaseOffer` / `offerPurchased` replaced.
- The success screen reuses `MyOfferDetailsCubit` (same `myOfferDetails(id)` request), so there is no `offer_purchased_cubit.dart`. It shows the "Book an appointment" title like the Android layout (the earlier session-requested screen omits it).
- Plugin quirks: it needs both a production and a sandbox key (the single `Env.paymentKey` is passed for both, `SDKMode.Sandbox` picks that slot); it requires non-null `Reference`/`Receipt`/`AuthorizeAction` objects (empty values, Android passed null); customer id is `''` (new customer); appearance windowed, payment type CARD.
- Failed payment: Android shows a small popup with the Tap message; a failed toast with that message is the substitute (connection-error text when the message is empty).
- If the Tap charge succeeds but `POST client/offers` then fails, the user is only toasted and the button is enabled again (same as Android), so they could pay twice. Worth a backend-side/idempotency discussion with the owner.
- Android bug not copied: the connection-lost retry of the success screen called `GetOfferDetails(userOfferId)`; here it retries `myOfferDetails`.
- Security (for the owner, not changed here): the Tap secret key is compiled into the app (same as Android).
- Tests: `test/features/purchase_offer/purchase_offer_cubit_test.dart` (button rule, paid → buy → id, cancelled, declined never buys, buy failure, result mapping).
- **Not verified on a device**: no Tap card sheet / test-card run was done (needs the debug env and a device). Box in PLAN §5 left unticked for that reason.
