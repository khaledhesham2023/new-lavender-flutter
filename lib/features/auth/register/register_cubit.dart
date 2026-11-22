import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/requests/auth_requests.dart';
import '../../../shared/domain/repositories/auth_repository.dart';

/// One-shot effect the screen reacts to (then calls [RegisterCubit.consumeEvent]).
enum RegisterEvent { none, navigateOtp }

class RegisterState extends Equatable {
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;
  final RegisterEvent event;

  /// Phone from the response, shown on the OTP screen.
  final String? otpPhone;

  const RegisterState({
    this.status = ViewStatus.initial,
    this.failure,
    this.event = RegisterEvent.none,
    this.otpPhone,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, failure, event, otpPhone];
}

/// Port of `RegisterFragment` + `AuthViewModel.register`.
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._auth) : super(const RegisterState());

  /// `Constants.phoneCode` without the `+`.
  static const String phoneCode = '966';

  final AuthRepository _auth;

  /// [email] is sent as-is (`""` when empty, like Android); passwords are trimmed.
  Future<void> submit({
    required String phone,
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (state.isLoading) return;
    emit(const RegisterState(status: ViewStatus.loading));

    final result = await _auth.register(
      AuthRequest(
        phone: phone,
        phoneCode: phoneCode,
        fullName: fullName,
        email: email,
        password: password.trim(),
        passwordConfirmation: passwordConfirmation.trim(),
        termsAndConditions: 1,
      ),
    );
    if (isClosed) return;

    switch (result) {
      case ApiFailure():
        emit(RegisterState(status: ViewStatus.failure, failure: result));
      case ApiSuccess(:final data):
        emit(
          RegisterState(
            status: ViewStatus.success,
            event: RegisterEvent.navigateOtp,
            otpPhone: data.phone ?? '',
          ),
        );
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(const RegisterState(status: ViewStatus.initial));
}
