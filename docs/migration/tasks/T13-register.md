# T13 - Register

## Goal
Port the sign-up form with its field rules, optional email, terms checkbox and link, then hand over to OTP.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/register/RegisterFragment.kt` (all of it: text/focus listeners, `isValid`, `setupClicks`)
- `res/layout/fragment_register.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthViewModel.kt` (`register`)
- `docs/migration/CONTEXT.md` §7.3 (Register row)
- `lib/features/auth/widgets/phone_field.dart`, `password_field.dart` (T12)

## Build
- `lib/features/auth/register/register_screen.dart`, `register_cubit.dart`
- `lib/features/auth/widgets/name_field.dart`, `email_field.dart` (if not generic enough, a shared `LabeledField`)
- Router: replace `authRegister`.
- `test/features/auth/register_cubit_test.dart`

## Steps
1. Layout 1:1 from `fragment_register.xml` (transparent status bar with dark icons, scrollable form).
2. Fields and rules (port the Kotlin exactly):
   - Name: while typing, a non-letter first char is stripped with error `nameMustStartWithALetter`; on blur: empty → `pleaseEnterYourName`, length < 2 → `nameMustBeAtLeast2Characters`.
   - Email: hint is `"${l10n.email} ${l10n.optional}"` where the first part is primary-colored when focused and grey otherwise and "optional" is `c7E94B0`
     (Android `addHintToEmailInputLayout`) — use a `Text.rich` label. Email has the same leading-char rule as in the Kotlin (`isUpdatingEmailText` block) — read it and copy.
   - Phone: `PhoneField` (T12).
   - Password and confirm: `PasswordField`; confirm on blur: empty → `pleaseEnterThePassword`, different → `theConfirmationPasswordDoesNotMatchWithTheOriginalPassword`.
   - Terms checkbox + text with the link part → `context.push(Routes.terms)`.
3. Submit validation order (from `isValid`): name empty, name < 2, phone empty, phone < 9, phone not 5…, password empty, password < 8,
   confirm empty, confirm ≠ password, terms unchecked (check what Android shows for unchecked terms — toast or text — and copy).
4. `RegisterCubit(AuthRepository)`: `submit(...)` → `register(AuthRequest(phone, phone_code: '966', full_name, email (sent as-is, `""` when empty), password (trimmed), password_confirmation (trimmed), termsAndConditions: 1))`.
   Success → emit `navigateOtp(phone: user.phone ?? '')`; failure → toast.
5. On success `context.push(Routes.authOtp, extra: OtpArgs(phone: <from response>, phoneCode: '+966', fromDestination: OtpDestination.login))`
   (Android uses `Destination.LOGIN` for register too).
6. Back arrow / system back → `context.pop()`.
7. Tests: request body (empty email sent as `""`, terms=1, trimmed passwords), success → navigateOtp with response phone.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: every rule shows the same message as Android; terms link opens the Terms placeholder; a real registration (test number) reaches OTP;
  duplicate phone shows the server message in a top toast.

## Out of scope
- OTP verification (T14). Terms content (T35).

## Gotchas
- The keyboard must not cover the button — Android adds padding for the keyboard (`adjustPaddingForKeyboard`); use a scroll view with `viewInsets`.
- Email is optional but, like Android (`email = editEmail.text.toString()`), it is always sent: an empty field sends `"email": ""` (owner decision: keep as the app).
  So in step 4 pass `email: emailText` (not null when empty).
