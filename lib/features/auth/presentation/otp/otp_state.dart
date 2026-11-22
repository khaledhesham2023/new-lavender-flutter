import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'otp_event.dart';

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
