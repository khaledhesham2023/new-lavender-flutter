import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import '../../../../app/router/route_args.dart';
import 'otp_change_phone_event.dart';
import 'otp_change_phone_state.dart';

/// Port of `OtpChangePhoneFragment` + `AuthViewModel.verifyChangedPhone /
/// verifyForgetPassword`. Resend is intentionally not offered.
class OtpChangePhoneCubit extends Cubit<OtpChangePhoneState> {
  OtpChangePhoneCubit(this._auth, this._session, this._args)
    : super(const OtpChangePhoneState());

  final AuthRepository _auth;
  final SessionCubit _session;
  final OtpArgs _args;

  /// `args.phoneCode.substring(1)`: the arg is `+966`, the API wants `966`.
  String get _apiPhoneCode => _args.phoneCode.startsWith('+')
      ? _args.phoneCode.substring(1)
      : _args.phoneCode;

  Future<void> verify(String otp) async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, codeError: false));

    if (_args.fromDestination == OtpDestination.editProfileAddNewPassword) {
      final result = await _auth.verifyForgetPassword(
        AuthRequest(phone: _args.phone, phoneCode: _apiPhoneCode, otp: otp),
      );
      if (isClosed) return;
      switch (result) {
        case ApiFailure():
          _emitVerifyFailure(result);
        case ApiSuccess():
          emit(
            state.copyWith(
              loading: false,
              event: OtpChangePhoneEvent.navigateNewPassword,
              otp: otp,
            ),
          );
      }
      return;
    }

    final result = await _auth.verifyChangedPhone(
      AuthRequest(phone: _args.phone, phoneCode: _apiPhoneCode, otp: otp),
    );
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        _emitVerifyFailure(result);
      case ApiSuccess():
        await _session.updateUser(phone: _args.phone, phoneCode: _apiPhoneCode);
        if (isClosed) return;
        emit(
          state.copyWith(
            loading: false,
            event: OtpChangePhoneEvent.phoneChanged,
          ),
        );
    }
  }

  /// Android `errorVerify`: any server answer shows the inline "invalid code" line and
  /// the screen clears the boxes. Connection problems keep the generic failure toast.
  void _emitVerifyFailure(ApiFailure<dynamic> failure) {
    if (failure is ServerFailure) {
      emit(state.copyWith(loading: false, codeError: true));
    } else {
      emit(state.copyWith(loading: false, failure: failure));
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(state.copyWith());
}
