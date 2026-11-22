import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'register_event.dart';

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
