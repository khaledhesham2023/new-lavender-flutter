import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../shared/domain/repositories/auth_repository.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

/// Port of `ForgetPasswordFragment` + `AuthViewModel.resetPassword`.
class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit(this._auth) : super(const ForgetPasswordState());

  /// `Constants.phoneCode` without the `+`.
  static const String phoneCode = '966';

  final AuthRepository _auth;

  Future<void> submit(String phone) async {
    if (state.isLoading) return;
    emit(const ForgetPasswordState(status: ViewStatus.loading));

    final result = await _auth.resetPassword(
      AuthRequest(phone: phone, phoneCode: phoneCode),
    );
    if (isClosed) return;

    switch (result) {
      case ApiFailure():
        emit(ForgetPasswordState(status: ViewStatus.failure, failure: result));
      case ApiSuccess():
        emit(
          const ForgetPasswordState(
            status: ViewStatus.success,
            event: ForgetPasswordEvent.navigateOtp,
          ),
        );
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(const ForgetPasswordState());
}
