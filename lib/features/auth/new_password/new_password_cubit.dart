import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/requests/auth_requests.dart';
import '../../../shared/domain/repositories/auth_repository.dart';
import '../../../app/router/route_args.dart';

/// One-shot effect the screen reacts to (then calls [NewPasswordCubit.consumeEvent]).
enum NewPasswordEvent { none, navigateSuccess }

class NewPasswordState extends Equatable {
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;
  final NewPasswordEvent event;

  const NewPasswordState({
    this.status = ViewStatus.initial,
    this.failure,
    this.event = NewPasswordEvent.none,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, failure, event];
}

/// Port of `NewPasswordFragment` + `AuthViewModel.changePassword`.
class NewPasswordCubit extends Cubit<NewPasswordState> {
  NewPasswordCubit(this._auth, this._args) : super(const NewPasswordState());

  final AuthRepository _auth;
  final NewPasswordArgs _args;

  /// `args.phoneCode.substring(1)`: the arg is `+966`, the API wants `966`.
  String get _apiPhoneCode => _args.phoneCode.startsWith('+')
      ? _args.phoneCode.substring(1)
      : _args.phoneCode;

  /// Passwords are trimmed, like Register.
  Future<void> submit(String password, String passwordConfirmation) async {
    if (state.isLoading) return;
    emit(const NewPasswordState(status: ViewStatus.loading));

    final result = await _auth.changePassword(
      AuthRequest(
        phone: _args.phone,
        phoneCode: _apiPhoneCode,
        password: password.trim(),
        passwordConfirmation: passwordConfirmation.trim(),
        otp: _args.otp,
      ),
    );
    if (isClosed) return;

    switch (result) {
      case ApiFailure():
        emit(NewPasswordState(status: ViewStatus.failure, failure: result));
      case ApiSuccess():
        emit(
          const NewPasswordState(
            status: ViewStatus.success,
            event: NewPasswordEvent.navigateSuccess,
          ),
        );
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(const NewPasswordState());
}
