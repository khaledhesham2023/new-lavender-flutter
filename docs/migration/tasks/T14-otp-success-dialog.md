# T14 - OTP and success dialog

## Goal
Port the 4-digit OTP screen used after login/register and in the reset-password flow, with its countdown/resend, auto-submit,
saving the session on a verified account and the "account created" success dialog. The OTP input widget is reused in T33.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/otp/screen/OtpFragment.kt` (whole file, incl. `setupEditTexts`, `GenericKeyEvent`, `GenericTextWatcher`)
- `res/layout/fragment_otp.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthViewModel.kt` (`verifyPhone`, `verifyForgetPassword`, `resendCode`, timer)
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/success/SuccessDialog.kt`
- `docs/migration/CONTEXT.md` §7.3 (OTP, Success dialog rows)
- `lib/core/widgets/success_dialog.dart` (T04)

## Build
- `lib/features/auth/otp/otp_screen.dart`, `otp_cubit.dart`
- `lib/features/auth/widgets/otp_input.dart` — 4 boxes, reusable
- `lib/features/auth/widgets/resend_timer.dart` — countdown + resend link, reusable
- Router: replace `authOtp`.
- `test/features/auth/otp_cubit_test.dart`

## Steps
1. `OtpInput({required ValueChanged<String> onCompleted, ValueChanged<String>? onChanged})`: 4 single-digit boxes styled from the layout,
   LTR order even in Arabic (check the layout: if `layoutDirection="ltr"` is set, force `TextDirection.ltr`), auto-focus first, move forward on input,
   backspace on an empty box clears the previous box and focuses it, backspace on a filled box clears it. Supports paste of 4 digits.
   Calls `onCompleted` when all 4 are filled (Android auto-submits).
2. `ResendTimer`: starts at 60 s, shows `mm:ss` (`convertSecondsString`) next to `l10n.resendWithin`; when it reaches 0 hides the time and shows
   `l10n.resend` as a tappable link. `restart()` method (exposed via a controller or key).
3. Texts by destination: `resetPassword` → title `passwordRecoveryTitle`, subtitle `toRetrieveYourPassword`; else `enterTheConfirmationCode`,
   `toConfirmYourAccount`. Phone display per layout (check `tvPhone`/body strings `enter_otp_body` with `%s`).
4. `OtpCubit(AuthRepository, SessionCubit, DeviceTokenProvider, OtpArgs)`:
   - `verify(otp)`: if `resetPassword` → `verifyForgetPassword(AuthRequest(phone, phone_code: '966', otp))` → success emit `navigateNewPassword(otp)`.
     Else → token = provider.getToken(); `verifyPhone(AuthRequest(phone, phone_code, device_token: token, device_type: 'android', otp))`;
     success with `isVerified == true` → `session.onAuthenticated(user)`, emit `verifiedWithMessage(message)`; success but not verified → nothing (same as Android).
   - `resend()` → `resendCode(AuthRequest(phone, phone_code))` → emit `resent(message)`.
   - Verify errors and resend errors → failure (toast). Ignore a second `verify` while loading.
5. Screen reactions: `verifiedWithMessage` → `AppToast.show(message, success)`, then `await showSuccessDialog(context, l10n.accountCreatedSuccessfully)`,
   then `context.go(Routes.home)`. `navigateNewPassword` → `context.push(Routes.authNewPassword, extra: NewPasswordArgs(phone, phoneCode, otp))`.
   `resent` → success toast + timer restart. Button (`ProgressButton`) also submits when 4 digits entered.
6. Back arrow → `context.pop()`.
7. Tests: verify path for login vs reset; not-verified response does not save session; resend emits message.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: typing 4 digits auto-submits; wrong code → server message toast and boxes kept (check Android: does it reset? `resetCodeInputs` exists — copy behavior);
  timer counts 01:00 → 00:00 then "Resend" works and restarts; correct code → toast + success GIF dialog 2 s → Home; relaunch → logged in.

## Out of scope
- New password / success screen (T15). Change-phone OTP (T33, reuses `OtpInput`/`ResendTimer`).

## Gotchas
- Android timer initial text is `"60:00"` until the first tick; the first tick shows `00:59`. Show `01:00` → `00:59`… (`convertSecondsString(60000)` = `01:00`) — note the difference in Notes if you keep Android's.
- `phoneCode` arg is `+966`; strip the `+` when sending.
- Cancel the timer in `dispose`.
