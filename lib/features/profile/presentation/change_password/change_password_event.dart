
enum ChangePasswordEvent {
  none,

  /// Password changed: show the success sheet, then pop.
  changed,

  /// Code sent to the own phone: open the OTP screen.
  codeSent,
}
