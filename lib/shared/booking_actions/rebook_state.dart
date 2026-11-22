import 'package:equatable/equatable.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/doctor.dart';

class RebookState extends Equatable {
  final ViewStatus status;
  final List<WorkTimeModel> days;
  final WorkTimeModel? selectedDay;
  final TimeModel? selectedTime;
  final bool submitting;
  final ApiFailure<dynamic>? failure;

  const RebookState({
    this.status = ViewStatus.initial,
    this.days = const [],
    this.selectedDay,
    this.selectedTime,
    this.submitting = false,
    this.failure,
  });

  RebookState copyWith({
    ViewStatus? status,
    List<WorkTimeModel>? days,
    WorkTimeModel? selectedDay,
    bool clearSelectedDay = false,
    TimeModel? selectedTime,
    bool clearSelectedTime = false,
    bool? submitting,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) => RebookState(
    status: status ?? this.status,
    days: days ?? this.days,
    selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
    selectedTime: clearSelectedTime
        ? null
        : (selectedTime ?? this.selectedTime),
    submitting: submitting ?? this.submitting,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [
    status,
    days,
    selectedDay,
    selectedTime,
    submitting,
    failure,
  ];
}
