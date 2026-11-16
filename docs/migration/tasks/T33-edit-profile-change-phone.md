# T33 - Edit profile and change phone OTP

## Goal
Port Edit profile (photo upload, name/email update, phone change, delete account entry), the change-phone OTP screen and the
"success" sheet shown after phone/password changes. The OTP screen also serves the profile forgot-password flow finished in T34.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/editProfile/EditProfile.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/editProfile/otp/OtpChangePhoneFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/sheet/SuccessChangePhoneSheet.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/UploadImages.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/ProfileViewModel.kt` (`uploadImage`, `updateProfile`, `changePhone`, `getProfileData`)
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthViewModel.kt` (`verifyChangedPhone`, `verifyForgetPassword`, `resendCode`)
- Layouts: `res/layout/fragment_edit_profile.xml`, `fragment_otp_change_phone.xml`, `sheet_success_change_phone.xml`
- `docs/migration/CONTEXT.md` §7.4 (Edit profile, OTP change phone, Success sheet rows)
- `lib/features/auth/widgets/otp_input.dart`, `resend_timer.dart`, `phone_field.dart`

## Build
- `lib/features/profile/edit_profile/edit_profile_screen.dart`, `edit_profile_cubit.dart`
- `lib/features/profile/otp_change_phone/otp_change_phone_screen.dart`, `otp_change_phone_cubit.dart`
- `lib/features/profile/success_sheet.dart` — `Future<void> showProfileSuccessSheet(BuildContext, ProfileSuccessType type)` with `enum ProfileSuccessType { changePhone, changePassword, forgetPasswordForEdit }`
- Router: replace `editProfile`, `otpChangePhone`.

## Steps
1. `flutter pub add image_picker`.
2. `EditProfileCubit(ProfileRepository, GeneralRepository, SessionCubit)`: `load()` → `getProfile()` (fills name, email, phone, phoneCode, image; also `session.updateUser`).
   `pickedImage(String path)` → `uploadImage(path)` → keep returned name in state (`uploadedImage`); failure → toast.
   `save(name, email)` → `updateProfile(AuthRequest(full_name, email, image: uploadedImage))` → success → `session.updateUser(...)` → emit `saved`.
   `changePhone(phone)` → `updatePhone(phone, '966')` → emit `phoneCodeSent(phone)`.
3. Screen from `fragment_edit_profile.xml`: avatar with "change image" → `ImagePicker().pickImage(source: gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80)` (this
   resizes and fixes EXIF rotation like `UploadImages`); reject `.gif` → toast `invalidImage`; show the local file immediately, then upload.
   Name/email fields (email optional hint like Register). Phone with `+code` from the profile; the "Update phone" button is visible only when the typed phone differs from the
   current one and passes the phone rules (port `textChangeListener`: invalid first digit → clear + error, hide button). Save button → `save`; on `saved` → `context.pop()`.
   "Delete account" text → `showGeneralSheet(context, GeneralType.deleteAccount)` (T32).
4. On `phoneCodeSent` → `context.push(Routes.otpChangePhone, extra: OtpArgs(phone, '+966', OtpDestination.editProfile))`.
5. OTP change phone screen (same UI pieces as T14, layout `fragment_otp_change_phone.xml`, shows `phoneCode + phone`): auto-submit at 4 digits;
   - `editProfile` → `verifyChangedPhone(AuthRequest(phone, phone_code: '966', otp))` → success → `session.updateUser(phone: phone)` →
     `await showProfileSuccessSheet(changePhone)` → pop back to Edit profile (Android pops twice/thrice — end on Edit profile, which reloads).
   - `editProfileAddNewPassword` → `verifyForgetPassword(AuthRequest(phone, '966', otp))` → `context.push(Routes.forgetPasswordForEdit, extra: NewPasswordArgs(phone, phoneCode, otp))` (screen in T34).
   - resend → `resendCode(AuthRequest(phone, '966'))` + toast + timer restart.
6. Success sheet: success GIF, text `phoneChangedSuccessfully` for changePhone else `passwordChangedSuccessfully`; not dismissible; closes after 2 s.
7. Errors: toasts (the Kotlin shows toasts for these screens). Back → pop.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: change avatar → shows instantly → saved → Profile header updates; edit name/email → back with new name; change phone → OTP → success sheet → Edit profile shows the new phone;
  "Delete account" opens the red sheet.

## Out of scope
- Change password screens (T34). Account deletion logic (T32).

## Gotchas
- `image_picker` on Android 13+ uses the Photo Picker — no storage permission needed; do not add READ_MEDIA_* permissions.
- The uploaded image is only applied when the user presses Save (Android sends `image = userImage` with the update) — check the Kotlin; if the upload alone updates the avatar, copy that.
