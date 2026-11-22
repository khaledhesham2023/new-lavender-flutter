import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/utils/date_utils.dart';
import '../../core/enums/enums.dart';
import '../../data/models/requests/appointment_requests.dart';
import '../../data/models/responses/doctor.dart';
import '../domain/repositories/booking_repository.dart';

/// Arguments of `ChooseRebookAppointmentSheetFragment`.
class RebookArgs extends Equatable {
  final int appointmentId;
  final int doctorId;
  final BookingStatus status;

  /// `"book"` (change a pending / confirmed booking) or `"rebook"`.
  final String type;
  final bool forOffer;

  const RebookArgs({
    required this.appointmentId,
    required this.doctorId,
    required this.status,
    required this.type,
    this.forOffer = false,
  });

  @override
  List<Object?> get props => [appointmentId, doctorId, status, type, forOffer];
}

/// What the rebook sheet resolves to.
sealed class RebookOutcome {
  const RebookOutcome();
}

/// Pending / confirmed: the new slot, still to be confirmed by the caller.
class ChangeRequested extends RebookOutcome {
  final UpdateAppointmentRequest request;
  const ChangeRequested(this.request);
}

/// Completed / canceled / rejected: the new appointment was created.
class Rebooked extends RebookOutcome {
  final int newId;
  final bool forOffer;
  const Rebooked(this.newId, this.forOffer);
}

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

/// Result of [RebookCubit.confirm].
sealed class RebookConfirm {
  const RebookConfirm();
}

class RebookNeedsDay extends RebookConfirm {
  const RebookNeedsDay();
}

class RebookNeedsTime extends RebookConfirm {
  const RebookNeedsTime();
}

class RebookDone extends RebookConfirm {
  final RebookOutcome outcome;
  const RebookDone(this.outcome);
}

class RebookFailed extends RebookConfirm {
  final ApiFailure<dynamic> failure;
  const RebookFailed(this.failure);
}

/// Port of `ChooseRebookAppointmentSheetFragment`'s state: loads the doctor's
/// work times, keeps the day / time selection and, on confirm, either returns the
/// requested change (pending / confirmed) or creates the rebooking.
class RebookCubit extends Cubit<RebookState> {
  RebookCubit(this._repo, this.args) : super(const RebookState());

  final BookingRepository _repo;
  final RebookArgs args;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        clearFailure: true,
        clearSelectedDay: true,
        clearSelectedTime: true,
      ),
    );
    final result = await _repo.workTimes(args.doctorId);
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

  Future<RebookConfirm> confirm() async {
    final day = state.selectedDay;
    final time = state.selectedTime;
    if (day == null) return const RebookNeedsDay();
    if (time == null) return const RebookNeedsTime();
    if (state.submitting) return const RebookNeedsTime();

    final date = convertIsoToDateOnly(day.date ?? '');
    final timeText = time.timeFormatted ?? '';

    switch (args.status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
      case BookingStatus.processing:
        return RebookDone(
          ChangeRequested(
            UpdateAppointmentRequest(
              doctorId: args.doctorId,
              day: date,
              time: timeText,
            ),
          ),
        );
      case BookingStatus.completed:
      case BookingStatus.canceled:
      case BookingStatus.rejected:
        emit(state.copyWith(submitting: true));
        final result = await _repo.rebook(
          args.appointmentId,
          RebookRequest(day: date, time: timeText),
        );
        if (isClosed) return const RebookNeedsTime();
        emit(state.copyWith(submitting: false));
        switch (result) {
          case ApiSuccess(:final data):
            final newId = data.id;
            if (newId == null) return const RebookFailed(UnknownFailure());
            return RebookDone(Rebooked(newId, args.forOffer));
          case ApiFailure():
            return RebookFailed(result);
        }
    }
  }
}
