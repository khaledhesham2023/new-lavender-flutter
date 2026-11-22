import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'otp_change_phone_event.dart';

class OtpChangePhoneState extends Equatable {
  final bool loading;
  final bool codeError;
  final OtpChangePhoneEvent event;
  final ApiFailure<dynamic>? failure;
  final String otp;

  const OtpChangePhoneState({
    this.loading = false,
    this.codeError = false,
    this.event = OtpChangePhoneEvent.none,
    this.failure,
    this.otp = '',
  });

  /// Keeps loading / codeError; the one-shot fields reset unless given.
  OtpChangePhoneState copyWith({
    bool? loading,
    bool? codeError,
    OtpChangePhoneEvent event = OtpChangePhoneEvent.none,
    ApiFailure<dynamic>? failure,
    String otp = '',
  }) {
    return OtpChangePhoneState(
      loading: loading ?? this.loading,
      codeError: codeError ?? this.codeError,
      event: event,
      failure: failure,
      otp: otp,
    );
  }

  @override
  List<Object?> get props => [loading, codeError, event, failure, otp];
}
