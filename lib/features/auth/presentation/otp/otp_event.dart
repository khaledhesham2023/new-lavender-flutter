import 'otp_state.dart';

/// One-shot effect the screen reacts to (then calls [OtpCubit.consumeEvent]).
enum OtpEvent {
  none,

  /// Account verified and session saved: toast [OtpState.message], success dialog, Home.
  verifiedWithMessage,

  /// Reset-password code accepted: open the new-password screen with [OtpState.otp].
  navigateNewPassword,
}
