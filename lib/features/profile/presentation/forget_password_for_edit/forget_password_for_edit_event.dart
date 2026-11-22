
enum ForgetPasswordForEditEvent {
  none,

  /// Password changed: show the success sheet, then call [ForgetPasswordForEditCubit.logout].
  changed,

  /// Logged out: go to Start now.
  loggedOut,

  /// The logout call failed: the session stays; toast, then back to Profile.
  logoutFailed,
}
