import 'otp_change_phone_state.dart';

enum OtpChangePhoneEvent {
  none,

  /// New phone confirmed and stored: show the success sheet, then go back.
  phoneChanged,

  /// Forgot-password code accepted: open the new-password screen with [OtpChangePhoneState.otp].
  navigateNewPassword,
}
