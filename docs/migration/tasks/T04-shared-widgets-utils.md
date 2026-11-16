# T04 - Shared utils and widgets

## Goal
Port the helpers and custom views that almost every screen uses: date/number/validation helpers, the top toast,
the progress button, the star rating, the empty/error view, the loader, network/SVG image widgets, the bottom-sheet
frame, the success dialog and the must-login sheet. Building them once now keeps every screen task small and consistent.

## Read first
- `app/src/main/java/com/alalmiya/lavender/utils/extensions/ViewExtFunctions.kt` (date/time/number helpers, lines ~75–540)
- `app/src/main/java/com/alalmiya/lavender/utils/utilities/CommonUtils.kt` (`showCustomToast`, `handleAllKindOfExceptions`,
  `convertSecondsString`, `isValidEmail`, `isValidKsaNumber`, `dropWhileIndexed`)
- `app/src/main/java/com/alalmiya/lavender/utils/views/Toaster.kt` + layouts `res/layout/success_custome_toast.xml`,
  `failed_custome_toast.xml`, `warning_custome_toast.xml`, `normal_custome_toast.xml`, `failed_attempts_custome_toast.xml`
- `app/src/main/java/com/alalmiya/lavender/utils/views/ProgressButton.kt`, `ProgressButtonSmall.kt` + `res/layout/progress_button_layout*.xml`
- `app/src/main/java/com/alalmiya/lavender/utils/views/rateBar/CustomRatingBar.kt`, `CustomRatingBarSmall.kt`
- `app/src/main/java/com/alalmiya/lavender/base/delegate/emptyOrError/EmptyErrorDelegateImp.kt` + `res/layout/error_empty_layout.xml`
- `res/layout/loader_layout.xml`
- `app/src/main/java/com/alalmiya/lavender/base/ParentSheetFragment.kt`, `res/values/themes.xml` (`AppBottomSheetDialogTheme`)
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/success/SuccessDialog.kt` + `res/layout/dialog_success.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/sheets/screen/MustLoginSheetFragment.kt` + `res/layout/fragment_must_login_sheet.xml`
- `app/src/main/java/com/alalmiya/lavender/utils/extensions/ImageExtensions.kt` (`loadImageFromInternet`: placeholder/error + loader overlay)
- `docs/migration/CONTEXT.md` §4 (error handling, custom views), §11 items 9–10
- `docs/migration/PLAN.md` §4.2–§4.6

## Build
- `lib/core/network/api_result.dart` — the `ApiResult`/`ApiFailure` types (defined here so widgets can use them; T07 uses them).
- `lib/core/utils/date_utils.dart`, `number_utils.dart`, `validators.dart`.
- `lib/core/widgets/app_toast.dart`, `progress_button.dart`, `star_rating.dart`, `state_view.dart`, `loading_view.dart`,
  `app_network_image.dart`, `app_svg.dart`, `app_back_button.dart`, `bottom_sheet_frame.dart`, `success_dialog.dart`,
  `must_login_sheet.dart`, `failure_toast.dart`, `debounced_search_field.dart`.
- `test/core/utils/date_utils_test.dart`, `number_utils_test.dart`, `validators_test.dart`.

## Steps
1. `flutter pub add cached_network_image`.
2. `api_result.dart`:
   ```dart
   sealed class ApiResult<T> { const ApiResult(); }
   final class ApiSuccess<T> extends ApiResult<T> { final T data; final String message; const ApiSuccess(this.data, {this.message = ''}); }
   sealed class ApiFailure<T> extends ApiResult<T> { const ApiFailure(); }
   final class ServerFailure<T> extends ApiFailure<T> { final int code; final String message; const ServerFailure(this.code, this.message); }
   final class NetworkFailure<T> extends ApiFailure<T> { const NetworkFailure(); }
   final class UnknownFailure<T> extends ApiFailure<T> { final String message; const UnknownFailure([this.message = '']); }
   enum ViewStatus { initial, loading, success, failure }
   ```
   Keep `ApiFailure` generic so a failure of one type can be returned as another: add `ApiFailure<R> cast<R>()` returning the same kind.
3. `date_utils.dart` — port each Android helper as a top-level function with the same semantics (read the Kotlin bodies):
   `formatDateToDayMonth(String iso)`, `convertTo24HourTime(String hhmm, String lang)` (input `HH:mm` → `hh:mm a`, AM/PM localized
   by `lang`, digits always English), `convertTo24HourTime2`, `reverseConvertTo24HourTime`, `convertIsoToDateOnly(String iso)` →
   `yyyy-MM-dd`, `convertDateOnlyToIso(String yyyyMd)` → `yyyy-MM-dd'T'HH:mm:ss.000000'Z'`, `convertDateToReadableFormat(String yyyyMMdd, String lang)`
   → `dd MMMM yyyy`, `parseDateToUtcMillis(String yyyyMMdd)`, `convertSecondsString(int millis)` → `mm:ss`, `toArabicFreeDigits(String)` (replace ٠–٩ with 0–9).
   Use `intl` `DateFormat` with locale `lang`, then `toArabicFreeDigits`. Initialize date symbols with `initializeDateFormatting()` in `main.dart`.
4. `number_utils.dart`: `formatDecimal(num?)` (port `formatDecimalNumber`: English digits, no trailing `.0` when integer — check the Kotlin
   pattern), `formatPercentage(num?)`, `truncateToDecimal(double, int places)` (truncate, not round), `formatDecimalString(String?)`.
5. `validators.dart` (pure functions returning an error *key* enum, not text): `validatePhone(String)` → empty / tooShort (<9) /
   mustStartWith5 / ok; `validatePassword(String)` → empty / tooShort (<8) / ok; `validateConfirm(String p, String c)`; `validateName(String)`
   → empty / tooShort (<2) / ok; `startsWithLetterOrDigit(String)`; `stripLeadingNonAlnum(String)` (port `dropWhileIndexed` use in Login).
6. `app_toast.dart`: `enum ToastType { success, warning, failed, normal, failedAttempts }` and `AppToast.show(BuildContext, String message, ToastType type, {Duration duration = const Duration(seconds: 2)})`.
   Implementation: insert an `OverlayEntry` at the top (below the status bar, full width with horizontal margin like the layouts),
   styled from each `*_custome_toast.xml` (background, icon, text color), fade in/out, remove after `duration`. Only one toast at a time
   (a new one replaces the old one). Android `LENGTH_SHORT` = 2 s.
7. `failure_toast.dart`: `void showFailureToast(BuildContext, ApiFailure f)` as in PLAN §4.4.
8. `progress_button.dart`: `ProgressButton({required String text, required VoidCallback? onPressed, bool loading = false, bool enabled = true, Color? background, Color? textColor, double height = 56, bool small = false})`.
   Look from `progress_button_layout.xml` (rounded rect, primary color, white bold text); while loading show a small white
   `CircularProgressIndicator` instead of the text and ignore taps; disabled = the Android disabled background (check `setEnable`). `small: true` uses the `_small` layout sizes.
9. `star_rating.dart`: `StarRating({required double score, double size = 16, bool readOnly = true, ValueChanged<double>? onChanged, int count = 5})`.
   Use the star drawables the Android view uses (find them in `CustomRatingBar.kt`), partial stars supported for read-only (half/fraction like Android),
   tap/drag to choose whole stars when not read-only.
10. `state_view.dart`: port `error_empty_layout.xml`: icon (SVG/PNG via `AppAssets`), title, body, optional button.
    Factory constructors: `StateView.serverError({String? title, String? body, VoidCallback? onRetry})` (icon `ic_server_error_2`,
    defaults `l10n.serverError` / `l10n.serverErrorBody2`), `StateView.connectionLost({required VoidCallback onRetry})`
    (`ic_network_error_2`, `noInternetConncetion`, `noInternetConncetionBody2`, button `retry`), `StateView.empty({required String icon, required String title, String body = '', String? buttonTitle, VoidCallback? onButton})`.
    Also `StateView.forFailure(ApiFailure f, {VoidCallback? onRetry})` → serverError for ServerFailure/UnknownFailure, connectionLost for NetworkFailure.
11. `loading_view.dart`: port `loader_layout.xml` (centered progress in primary color).
12. `app_network_image.dart`: `AppNetworkImage({String? url, double? width, double? height, BoxFit fit = BoxFit.cover, double radius = 0, bool circle = false, String? errorAsset})`
    using `CachedNetworkImage`, showing `LoadingView` while loading and an error/placeholder image (the Android default error image in `ImageExtensions.kt`).
13. `app_svg.dart`: `AppSvg(String asset, {double? width, double? height, Color? color})` — `SvgPicture.asset`; when `asset` is in
    `autoMirroredSvgs` and `Directionality.of(context) == TextDirection.rtl`, wrap in `Transform.flip(flipX: true)`.
14. `app_back_button.dart`: the back arrow icon used in screen headers (find the drawable in any fragment layout's `ivBack`), mirrored in RTL, `onTap` defaults to `Navigator.maybePop`.
15. `bottom_sheet_frame.dart`: `Future<T?> showAppBottomSheet<T>(BuildContext, {required WidgetBuilder builder, bool isDismissible = true, bool expanded = false})`
    — `showModalBottomSheet` with `isScrollControlled: true`, transparent background, barrier opacity 0.3 (theme `backgroundDimAmount`),
    `isDismissible`/`enableDrag` = Android `isCancel`; content wrapped in a white rounded-top container (radius from the sheet layouts, 24),
    `MediaQuery.viewInsets` bottom padding for the keyboard. `expanded` → `FractionallySizedBox(heightFactor: 0.9)`.
16. `success_dialog.dart`: `Future<void> showSuccessDialog(BuildContext, String title)` — non-dismissible dialog from `dialog_success.xml`
    with `AppAssets.successGif` and the title; closes itself after 2 s. The caller decides what happens next (Android type "auth" → go home).
17. `must_login_sheet.dart`: `Future<void> showMustLoginSheet(BuildContext)` — `StateView.empty` with `ic_must_login`, `youMustLoginTitle`,
    `youMustLoginBody`, button `login` → close sheet then `context.push(Routes.authStart)` (add `// TODO(T10): route constant` and use the
    literal `'/auth/start'` until T10 creates `Routes`).
18. `debounced_search_field.dart`: search text field styled like the Android search boxes (`etSearch` in `fragment_favorites.xml`), with a
    `Duration debounce` parameter and `onChanged` called after the debounce; cancels the timer on dispose.
19. Tests: date utils (each helper with en and ar inputs, digits English), number utils (`formatDecimal(150.0)`, `150.5`, null;
    `truncateToDecimal(4.68, 1) == 4.6`), validators (each rule).
20. Temporarily show a demo of toast/button/rating/state view on the home placeholder, check on device, then remove the demo.

## Done when
- `flutter analyze` → no issues; `flutter test` → all pass; debug APK builds.
- On device (temporary demo): each toast type matches the Android toast look at the top; ProgressButton loading state; StarRating 3.5 renders half star;
  StateView variants; bottom sheet opens with rounded top and dims background; success dialog closes after 2 s; Arabic layout mirrors arrows.

## Out of scope
- Screen-specific widgets (doctor card, booking card, …) — built in their screen tasks. Router (T10).

## Gotchas
- Android toasts appear at the TOP (`Gravity.FILL_HORIZONTAL`, y offset), not bottom snackbars.
- `convertTo24HourTime` name is inverted (returns 12-hour). Keep the Android names so screen tasks can map 1:1.
- Prices/rates use English digits even in Arabic UI.
- Do not import anything from `features/` into `core/`.

## Notes
- Done: `ApiResult`/`ApiFailure` (with `cast<R>()`), date/number/validator utils, and every widget under Build; `initializeDateFormatting()` added to `main.dart`. analyze, test and debug APK pass.
- Step 20 (temporary on-device demo) was not run: no Android device was available. Its checks are covered by `test/core/widgets/shared_widgets_test.dart` (half star, spinner/ignored taps, StateView variants, toast show/replace/auto-remove, success dialog closes after 2 s). Still unchecked visually: toast look vs Android, bottom sheet dim/rounding, RTL arrow mirroring.
- `convertTo24HourTime`, `reverseConvertTo24HourTime`, `convertDateToReadableFormat` take a `lang` argument; all emit English digits (Android's reverse helper kept locale digits).
- `stripLeadingNonAlnum` drops only the first char (matches the Android text watchers). `validators.dart` also has `isValidEmail` and `isValidKsaNumber`.
- `formatDecimal`/`formatPercentage` return only the number text; wrap with `l10n.priceWithValue` / `l10n.sar` in screens.
- `StateView`: `serverError`, `connectionLost`, `empty`, `forFailure`; the serverError button shows only when `onRetry` is given. `StarRating` is stateless: the parent keeps `score` and updates it in `onChanged`; touch input picks whole stars only (task file). Check `app:halfStars` in the Android review layouts before adding half-star input.
- `ProgressButton` shows a spinner instead of the text while loading and takes the grey disabled look; `small` = 50 high / 10sp text.
- `must_login_sheet.dart` uses the literal `'/auth/start'` until T10 adds `Routes`.
- The success dialog's gif has an `errorBuilder`, so a missing asset does not crash it.
