import 'edit_profile_state.dart';

/// One-shot effect the screen reacts to (then calls [EditProfileCubit.consumeEvent]).
enum EditProfileEvent {
  none,

  /// Profile fetched: the screen refills its fields from the state.
  loaded,

  /// Update succeeded: toast [EditProfileState.message], then go back.
  saved,

  /// Code sent to the new phone: open the OTP screen with [EditProfileState.newPhone].
  phoneCodeSent,

  /// The picked file was rejected (a gif or unreadable).
  invalidImage,
}
