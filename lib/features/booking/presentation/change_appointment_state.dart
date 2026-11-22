import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/doctor.dart';

class ChangeAppointmentState extends Equatable {
  final ViewStatus status;
  final List<WorkTimeModel> days;
  final WorkTimeModel? selectedDay;
  final TimeModel? selectedTime;
  final ApiFailure<dynamic>? failure;

  const ChangeAppointmentState({
    this.status = ViewStatus.initial,
    this.days = const [],
    this.selectedDay,
    this.selectedTime,
    this.failure,
  });

  ChangeAppointmentState copyWith({
    ViewStatus? status,
    List<WorkTimeModel>? days,
    WorkTimeModel? selectedDay,
    bool clearSelectedDay = false,
    TimeModel? selectedTime,
    bool clearSelectedTime = false,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) => ChangeAppointmentState(
    status: status ?? this.status,
    days: days ?? this.days,
    selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
    selectedTime: clearSelectedTime
        ? null
        : (selectedTime ?? this.selectedTime),
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [status, days, selectedDay, selectedTime, failure];
}
