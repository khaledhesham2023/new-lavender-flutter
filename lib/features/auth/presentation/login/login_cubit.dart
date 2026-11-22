import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/push/device_info.dart';
import '../../../../core/push/device_token.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';

/// One-shot effect the screen reacts to (then calls [LoginCubit.consumeEvent]).
enum LoginEvent { none, navigateHome, navigateOtp }

class LoginState extends Equatable {
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;
  final LoginEvent event;

  /// Phone to show on the OTP screen when [event] is [LoginEvent.navigateOtp].
  final String? otpPhone;

  const LoginState({
    this.status = ViewStatus.initial,
    this.failure,
    this.event = LoginEvent.none,
    this.otpPhone,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, failure, event, otpPhone];
}

/// Port of `LoginFragment` + `AuthViewModel.login/resendCode`.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth, this._session, this._deviceToken)
    : super(const LoginState());

  /// `Constants.phoneCode` without the `+` (`tvLoginCode.text.substring(1)`).
  static const String phoneCode = '966';

  final AuthRepository _auth;
  final SessionCubit _session;
  final DeviceTokenProvider _deviceToken;

  Future<void> submit(String phone, String password) async {
    if (state.isLoading) return;
    emit(const LoginState(status: ViewStatus.loading));

    final token = await _deviceToken.getToken();
    if (token != null) await _deviceToken.saveToken(token);

    final result = await _auth.login(
      AuthRequest(
        phone: phone,
        phoneCode: phoneCode,
        deviceToken: token,
        deviceType: deviceType,
        password: password,
      ),
    );
    if (isClosed) return;

    switch (result) {
      case ApiFailure():
        emit(LoginState(status: ViewStatus.failure, failure: result));
      case ApiSuccess(:final data):
        if (data.isVerified == true) {
          await _session.onAuthenticated(data);
          if (isClosed) return;
          emit(
            const LoginState(
              status: ViewStatus.success,
              event: LoginEvent.navigateHome,
            ),
          );
        } else {
          // Backend resend is broken: go straight to the OTP screen.
          emit(
            LoginState(
              status: ViewStatus.success,
              event: LoginEvent.navigateOtp,
              otpPhone: data.phone ?? phone,
            ),
          );
        }
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() {
    emit(const LoginState(status: ViewStatus.initial));
  }
}
