# T12 - Start now and login

## Goal
Port the auth entry screen and login with all its field validation and the "not verified → resend code → OTP" branch.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/startnow/StartNowFragment.kt` + `res/layout/fragment_start_now.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/login/LoginFragment.kt` + `res/layout/fragment_login.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthViewModel.kt` (`login`, `resendCode`)
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthNavigationController.kt` (`LoginToStartNow`, `LoginToForgetPassword`, `LoginToOtp`)
- `app/src/main/java/com/alalmiya/lavender/utils/constants/Constants.kt` (`phoneCode = "+966"`, `DEVICE_TYPE = "android"`)
- `docs/migration/CONTEXT.md` §7.3 (Start now, Login rows)
- `lib/core/utils/validators.dart`, `lib/core/session/session_cubit.dart`, `lib/data/repositories/auth_repository.dart`

## Build
- `lib/features/auth/start_now_screen.dart`
- `lib/features/auth/login/login_screen.dart`, `login_cubit.dart`
- `lib/features/auth/widgets/phone_field.dart` (reused by register/forget password/edit profile), `password_field.dart`, `auth_header.dart` if the layouts share a header
- Router: replace `authStart`, `authLogin` placeholders.
- `test/features/auth/login_cubit_test.dart`

## Steps
1. Start now: layout 1:1 (logo/art, two buttons, underlined "continue as guest"). White status bar dark icons.
   Sign in → `context.push(Routes.authLogin)`; Create account → `context.push(Routes.authRegister)`; guest → `context.go(Routes.home)` (nothing saved).
2. `PhoneField`: fixed prefix label `+966` (not editable), digits only, max 9 chars, label color `c7E94B0` → primary when focused,
   underline view `cD9DBE9` → `cED1C24` on error, error text below. Rules (port exactly):
   - while typing: if the first char is not `5` → clear the field and show `thePhoneNumberIsInvalidPleaseStartWith5`.
   - on focus lost: empty → `pleaseEnterThePhoneNumber`; < 9 → `thePhoneNumberMustBeAtLeast9CharactersLong`; else clear error.
3. `PasswordField`: obscured with eye toggle (check layout `passwordToggleEnabled`), rules:
   - while typing: if the first char is not a letter/digit → strip leading non-alnum chars, show `passwordMustStartWithALetter`.
   - on focus lost: empty → `pleaseEnterThePassword`; < 8 → `passwordMustBeAtLeast8CharactersLong`.
4. Login submit validation (order): phone empty, phone < 9, phone not starting with 5, password empty, password < 8 → show error on the field, no request.
5. `LoginCubit(AuthRepository, SessionCubit, DeviceTokenProvider)`:
   - `submit(phone, password)`: status loading; `token = await deviceTokenProvider.getToken()`; save it to prefs; call `login(AuthRequest(phone, phone_code: '966', device_token: token, device_type: 'android', password))`.
   - success & `user.isVerified == true` → `session.onAuthenticated(user)` → emit `navigateHome`.
   - success & not verified → call `resendCode(AuthRequest(phone: user.phone ?? phone, phone_code: '966'))`; on success emit `navigateOtp(phone)`; on failure emit failure.
   - failure → emit failure (screen shows `showFailureToast`).
6. Screen: `BlocListener` → `navigateHome`: `context.go(Routes.home)`; `navigateOtp`: `context.push(Routes.authOtp, extra: OtpArgs(phone, '+966', OtpDestination.login))`.
   The login button is a `ProgressButton` with loading during the whole chain.
7. "Forgot password" → `context.push(Routes.authForgetPassword)`.
8. Back (arrow and system): Android navigates to Start now popping to the graph start → `context.go(Routes.authStart)` when Login was reached
   from Start now; implement as `context.pop()` if `context.canPop()` else `context.go(Routes.authStart)`.
9. Tests: verified login → session saved + navigateHome; unverified → resend called → navigateOtp; server failure passes through.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: all validation messages appear exactly as in Android (type `4…` → cleared + error; short phone; short password; leading `@` stripped);
  valid wrong password → red top toast with the server message; valid account → Home (shell placeholder) and relaunch skips auth;
  unverified account → OTP placeholder with the phone.

## Out of scope
- Register (T13), OTP (T14), forget password (T15).

## Gotchas
- `phone_code` is sent **without** `+` (`tvLoginCode.text.substring(1)` → `966`).
- Android gets a fresh FCM token before login; until T39, `DeviceTokenProvider` returns the stored value (may be null → omitted).
- Login screen sets `adjustPan` on destroy; Flutter handles the keyboard with `resizeToAvoidBottomInset` + scroll view — make the form scrollable.
