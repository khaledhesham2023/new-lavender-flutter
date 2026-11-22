import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/appointment.dart';

class AppointmentRequestedState extends Equatable {
  final ViewStatus status;
  final AppointmentData? appointment;
  final ApiFailure<dynamic>? failure;

  const AppointmentRequestedState({
    this.status = ViewStatus.initial,
    this.appointment,
    this.failure,
  });

  @override
  List<Object?> get props => [status, appointment, failure];
}
