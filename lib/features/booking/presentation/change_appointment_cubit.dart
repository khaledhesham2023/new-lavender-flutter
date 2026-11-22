import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/requests/appointment_requests.dart';
import '../../../data/models/responses/doctor.dart';
import '../../../shared/domain/repositories/booking_repository.dart';

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

/// Result of [ChangeAppointmentCubit.confirm].
sealed class ChangeConfirm {
  const ChangeConfirm();
}

class ChangeConfirmed extends ChangeConfirm {
  final ChangeAppointmentRequest request;
  const ChangeConfirmed(this.request);
}

class ChangeNeedsDay extends ChangeConfirm {
  const ChangeNeedsDay();
}

class ChangeNeedsTime extends ChangeConfirm {
  const ChangeNeedsTime();
}

/// Port of the work-times part of `BookingSearchViewModel` used by
/// `ChangeAppointmentSheetFragment`, plus its day / time selection.
class ChangeAppointmentCubit extends Cubit<ChangeAppointmentState> {
  ChangeAppointmentCubit(this._repository, this.doctorId)
    : super(const ChangeAppointmentState());

  final BookingRepository _repository;
  final int doctorId;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        clearFailure: true,
        clearSelectedDay: true,
        clearSelectedTime: true,
      ),
    );
    final result = await _repository.workTimes(doctorId);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ViewStatus.success, days: data));
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// Choosing another day (or none) clears the chosen time.
  void selectDay(WorkTimeModel? day) => emit(
    state.copyWith(
      selectedDay: day,
      clearSelectedDay: day == null,
      clearSelectedTime: true,
    ),
  );

  void selectTime(TimeModel? time) => emit(
    state.copyWith(selectedTime: time, clearSelectedTime: time == null),
  );

  /// Validates the selection like the Confirm button of the sheet.
  ChangeConfirm confirm() {
    final day = state.selectedDay;
    final time = state.selectedTime;
    if (day == null) return const ChangeNeedsDay();
    if (time == null) return const ChangeNeedsTime();
    return ChangeConfirmed(
      ChangeAppointmentRequest(
        doctorId: doctorId,
        day: day.date ?? '',
        dayName: day.dayTranslated ?? '',
        time: time.timeFormatted ?? '',
      ),
    );
  }
}
