# T34 - Change password flows from profile

## Goal
Port "Password" from the profile menu: change password with the current one, and its "forgot password" branch (code to own phone →
OTP → new password → success → logout).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/addNewPassword/EditProfileAddNewPasswordFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/addNewPassword/ForgetPasswordForEditPasswordFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/sheet/SuccessChangePhoneSheet.kt` (type `ForgetPasswordForEditPasswordFragment` → logout)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/screen/ProfileFragment.kt` (`observeOnMarkedForLogout`)
- Layouts: `res/layout/fragment_edit_profile_add_new_password.xml`, `fragment_forget_password_for_edit_password.xml` (check binding names)
- `docs/migration/CONTEXT.md` §7.4 (Change password (profile), Forget password for edit rows)
- `lib/features/profile/otp_change_phone/*` (T33), `lib/features/profile/success_sheet.dart`

## Build
- `lib/features/profile/change_password/change_password_screen.dart`, `change_password_cubit.dart`
- `lib/features/profile/forget_password_for_edit/forget_password_for_edit_screen.dart`, `forget_password_for_edit_cubit.dart`
- Router: replace `changePassword`, `forgetPasswordForEdit`.

## Steps
1. Change password screen: current / new / confirm (`PasswordField` rules from the Kotlin `isValid`). Submit → `changeUserPassword(AuthRequest(current_password, password, password_confirmation))`
   → `await showProfileSuccessSheet(changePassword)` → `context.pop()`.
   "Forgot password" link → `resetPassword(AuthRequest(phone: args.phone, phone_code: args.code.substring(1)))` → success →
   `context.push(Routes.otpChangePhone, extra: OtpArgs(args.phone, args.code, OtpDestination.editProfileAddNewPassword))`.
2. Forget password for edit screen: new password + confirm → `AuthRepository.changePassword(AuthRequest(phone, phone_code: phoneCode.substring(1), password, otp))`
   (check whether Kotlin also sends `password_confirmation`) → `await showProfileSuccessSheet(forgetPasswordForEdit)` → logout:
   `AuthRepository.logout(deviceToken)` then `session.onLoggedOut()` → `context.go(Routes.authStart)` (Android triggers Profile's logout through `markedForLogout`; on API failure Android stays logged in — copy: on failure toast and `context.go(Routes.profile)`).
   Back → `context.go(Routes.profile)` (Android `ForgetPasswordToProfile`).
3. Errors → toast. Loading on buttons.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: change password with the right current password → success sheet → back on Profile; wrong current password → server toast;
  forgot path → OTP on own phone → new password → success → logged out to Start now; login with the new password works.

## Out of scope
- Auth-graph reset password (T15).

## Gotchas
- `ChangePasswordArgs.code` is `"+966"`; strip the `+` before sending.
