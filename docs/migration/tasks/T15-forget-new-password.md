# T15 - Forget password, new password, success screen

## Goal
Finish the auth graph: request a reset code, set the new password, show the success screen and return to login.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/newPassword/screen/ForgetPasswordFragment.kt` + `res/layout/fragment_forget_password.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/newPassword/screen/NewPasswordFragment.kt` + `res/layout/fragment_new_password.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/success/SuccessFragment.kt` + `res/layout/fragment_success.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthNavigationController.kt` (`NewPasswordTOSuccessFragment`, `SuccessFragmentTOLogin`, `NewPasswordTOLogin`)
- `docs/migration/CONTEXT.md` §7.3

## Build
- `lib/features/auth/forget_password/forget_password_screen.dart`, `forget_password_cubit.dart`
- `lib/features/auth/new_password/new_password_screen.dart`, `new_password_cubit.dart`
- `lib/features/auth/success/auth_success_screen.dart`
- Router: replace `authForgetPassword`, `authNewPassword`, `authSuccess`.

## Steps
1. Forget password: `PhoneField` + button; validation as Login's phone rules. Cubit → `resetPassword(AuthRequest(phone, phone_code: '966'))`;
   success → `context.push(Routes.authOtp, extra: OtpArgs(phone, '+966', OtpDestination.resetPassword))`. Back → pop.
2. New password: password + confirm with the same rules as Register; cubit → `changePassword(AuthRequest(phone, phone_code: '966', password, password_confirmation, otp))`;
   success → `context.go(Routes.authSuccess)` (Android navigates forward; since back from success goes to login, a `go` is fine).
   The back arrow on this screen → Login (`NewPasswordTOLogin`): `context.go(Routes.authLogin)` — check in the Kotlin which control triggers it.
3. Success screen: success GIF, texts from the layout, button → `context.go(Routes.authLogin)`; system back → same.
   But Login's back must still reach Start now: when Login was opened with `go`, its back handler `go`es to Start now (T12 step 8) — verify.
4. No tests needed beyond analyzer (simple pass-through cubits); add one cubit test for the new-password request body.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: full reset flow with a test number: phone → OTP (reset texts) → new password → success → login with the new password works.

## Out of scope
- Change password from profile (T34).

## Gotchas
- The OTP screen calls `verifyForgetPassword` for this flow, not `verifyPhone` (T14 already handles via `OtpDestination.resetPassword`).
