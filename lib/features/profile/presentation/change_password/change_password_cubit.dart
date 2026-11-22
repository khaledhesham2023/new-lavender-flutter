import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../app/router/route_args.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

/// Port of `EditProfileAddNewPasswordFragment` (`ChangePassword` and `ResetPassword`
/// events of `ProfileViewModel`).
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._profile, this._auth, this._args)
    : super(const ChangePasswordState());

  final ProfileRepository _profile;
  final AuthRepository _auth;
  final ChangePasswordArgs _args;

  /// `args.code` is `+966`; the API wants `966`.
  String get _apiPhoneCode =>
      _args.code.startsWith('+') ? _args.code.substring(1) : _args.code;

  /// Android sends the raw text of the three fields.
  Future<void> submit(
    String current,
    String password,
    String confirmation,
  ) async {
    if (state.saving || state.sendingCode) return;
    emit(const ChangePasswordState(saving: true));
    final result = await _profile.changeUserPassword(
      AuthRequest(
        currentPassword: current,
        password: password,
        passwordConfirmation: confirmation,
      ),
    );
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        emit(ChangePasswordState(failure: result));
      case ApiSuccess():
        emit(const ChangePasswordState(event: ChangePasswordEvent.changed));
    }
  }

  /// "Forgot password": sends a code to the account's own phone.
  Future<void> forgotPassword() async {
    if (state.saving || state.sendingCode) return;
    emit(const ChangePasswordState(sendingCode: true));
    final result = await _auth.resetPassword(
      AuthRequest(phone: _args.phone, phoneCode: _apiPhoneCode),
    );
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        emit(ChangePasswordState(failure: result));
      case ApiSuccess():
        emit(const ChangePasswordState(event: ChangePasswordEvent.codeSent));
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(const ChangePasswordState());
}
