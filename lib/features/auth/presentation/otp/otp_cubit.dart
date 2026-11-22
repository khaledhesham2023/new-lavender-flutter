import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/push/device_info.dart';
import '../../../../core/push/device_token.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import '../../../../app/router/route_args.dart';

/// One-shot effect the screen reacts to (then calls [OtpCubit.consumeEvent]).
enum OtpEvent {
  none,

  /// Account verified and session saved: toast [OtpState.message], success dialog, Home.
  verifiedWithMessage,

  /// Reset-password code accepted: open the new-password screen with [OtpState.otp].
  navigateNewPassword,
}

class OtpState extends Equatable {
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;
  final OtpEvent event;
  final String message;
  final String otp;

  /// Inline "this code is invalid" line under the boxes (Android `tvCodeError`).
  final bool codeError;

  const OtpState({
    this.status = ViewStatus.initial,
    this.failure,
    this.event = OtpEvent.none,
    this.message = '',
    this.otp = '',
    this.codeError = false,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, failure, event, message, otp, codeError];
}

/// Port of `OtpFragment` + `AuthViewModel.verifyPhone/verifyForgetPassword`.
class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._auth, this._session, this._deviceToken, this._args)
    : super(const OtpState());

  final AuthRepository _auth;
  final SessionCubit _session;
  final DeviceTokenProvider _deviceToken;
  final OtpArgs _args;

  /// `args.phoneCode.substring(1)`: the arg is `+966`, the API wants `966`.
  String get _apiPhoneCode => _args.phoneCode.startsWith('+')
      ? _args.phoneCode.substring(1)
      : _args.phoneCode;

  Future<void> verify(String otp) async {
    if (state.isLoading) return;
    emit(const OtpState(status: ViewStatus.loading));

    if (_args.fromDestination == OtpDestination.resetPassword) {
      await _verifyForgetPassword(otp);
    } else {
      await _verifyPhone(otp);
    }
  }

  Future<void> _verifyForgetPassword(String otp) async {
    final result = await _auth.verifyForgetPassword(
      AuthRequest(phone: _args.phone, phoneCode: _apiPhoneCode, otp: otp),
    );
    if (isClosed) return;

    switch (result) {
      case ApiFailure():
        _emitVerifyFailure(result);
      case ApiSuccess():
        emit(
          OtpState(
            status: ViewStatus.success,
            event: OtpEvent.navigateNewPassword,
            otp: otp,
          ),
        );
    }
  }

  Future<void> _verifyPhone(String otp) async {
    final token = await _deviceToken.getToken();
    final result = await _auth.verifyPhone(
      AuthRequest(
        phone: _args.phone,
        phoneCode: _apiPhoneCode,
        deviceToken: token,
        deviceType: deviceType,
        otp: otp,
      ),
    );
    if (isClosed) return;

    switch (result) {
      case ApiFailure():
        _emitVerifyFailure(result);
      case ApiSuccess(:final data, :final message):
        if (data.isVerified == true) {
          if (token != null) await _deviceToken.saveToken(token);
          await _session.onAuthenticated(data);
          if (isClosed) return;
          emit(
            OtpState(
              status: ViewStatus.success,
              event: OtpEvent.verifiedWithMessage,
              message: message,
            ),
          );
        } else {
          // Android does nothing here: the boxes stay as they are.
          emit(const OtpState());
        }
    }
  }

  /// Android `errorVerify`: any server answer shows the inline "invalid code" line and
  /// the screen clears the boxes. Connection problems keep the generic failure toast.
  void _emitVerifyFailure(ApiFailure<dynamic> failure) {
    if (failure is ServerFailure) {
      emit(const OtpState(status: ViewStatus.failure, codeError: true));
    } else {
      emit(OtpState(status: ViewStatus.failure, failure: failure));
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() =>
      emit(OtpState(status: ViewStatus.initial, codeError: state.codeError));
}
