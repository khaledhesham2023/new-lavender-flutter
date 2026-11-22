import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'login_event.dart';

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
