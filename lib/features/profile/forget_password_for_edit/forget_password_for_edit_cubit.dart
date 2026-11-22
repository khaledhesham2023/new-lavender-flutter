import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/session/session_cubit.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../data/models/requests/auth_requests.dart';
import '../../../shared/domain/repositories/auth_repository.dart';
import '../../../app/router/route_args.dart';

enum ForgetPasswordForEditEvent {
  none,

  /// Password changed: show the success sheet, then call [ForgetPasswordForEditCubit.logout].
  changed,

  /// Logged out: go to Start now.
  loggedOut,

  /// The logout call failed: the session stays; toast, then back to Profile.
  logoutFailed,
}

class ForgetPasswordForEditState extends Equatable {
  final bool loading;
  final ForgetPasswordForEditEvent event;
  final ApiFailure<dynamic>? failure;

  const ForgetPasswordForEditState({
    this.loading = false,
    this.event = ForgetPasswordForEditEvent.none,
    this.failure,
  });

  @override
  List<Object?> get props => [loading, event, failure];
}

/// Port of `ForgetPasswordForEditPasswordFragment` + `AuthViewModel.changePassword`,
/// and of the logout Android runs through Profile's `markedForLogout`.
class ForgetPasswordForEditCubit extends Cubit<ForgetPasswordForEditState> {
  ForgetPasswordForEditCubit(this._auth, this._session, this._prefs, this._args)
    : super(const ForgetPasswordForEditState());

  final AuthRepository _auth;
  final SessionCubit _session;
  final AppPrefs _prefs;
  final NewPasswordArgs _args;

  /// `args.phoneCode.substring(1)`: the arg is `+966`, the API wants `966`.
  String get _apiPhoneCode => _args.phoneCode.startsWith('+')
      ? _args.phoneCode.substring(1)
      : _args.phoneCode;

  /// Android sends the raw text of the fields (and `password_confirmation`).
  Future<void> submit(String password, String passwordConfirmation) async {
    if (state.loading) return;
    emit(const ForgetPasswordForEditState(loading: true));
    final result = await _auth.changePassword(
      AuthRequest(
        phone: _args.phone,
        phoneCode: _apiPhoneCode,
        password: password,
        passwordConfirmation: passwordConfirmation,
        otp: _args.otp,
      ),
    );
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        emit(ForgetPasswordForEditState(failure: result));
      case ApiSuccess():
        emit(
          const ForgetPasswordForEditState(
            event: ForgetPasswordForEditEvent.changed,
          ),
        );
    }
  }

  /// Runs after the success sheet. Android stays logged in when this call fails.
  Future<void> logout() async {
    final result = await _auth.logout(_prefs.deviceToken);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        await _session.onLoggedOut();
        if (isClosed) return;
        emit(
          const ForgetPasswordForEditState(
            event: ForgetPasswordForEditEvent.loggedOut,
          ),
        );
      case ApiFailure():
        emit(
          ForgetPasswordForEditState(
            event: ForgetPasswordForEditEvent.logoutFailed,
            failure: result,
          ),
        );
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(const ForgetPasswordForEditState());
}
