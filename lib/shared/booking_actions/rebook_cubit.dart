import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/utils/date_utils.dart';
import '../../core/enums/enums.dart';
import '../../data/models/requests/appointment_requests.dart';
import '../../data/models/responses/doctor.dart';
import '../domain/repositories/booking_repository.dart';
import 'rebook_args.dart';
import 'rebook_confirm.dart';
import 'rebook_outcome.dart';
import 'rebook_state.dart';

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

  void selectTime(TimeModel? time) =>
      emit(state.copyWith(selectedTime: time, clearSelectedTime: time == null));

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
