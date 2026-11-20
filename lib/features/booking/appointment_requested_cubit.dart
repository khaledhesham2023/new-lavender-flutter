import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/appointment.dart';
import '../../data/repositories/booking_repository.dart';

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

/// Port of `AppointmentDetailsViewModel.GetAppointmentDetails` as used by
/// `SuccessfulAppointmentRequestFragment`.
class AppointmentRequestedCubit extends Cubit<AppointmentRequestedState> {
  AppointmentRequestedCubit(this._repository, this.id)
    : super(const AppointmentRequestedState());

  final BookingRepository _repository;
  final int id;

  Future<void> load() async {
    emit(const AppointmentRequestedState(status: ViewStatus.loading));
    final result = await _repository.details(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          AppointmentRequestedState(
            status: ViewStatus.success,
            appointment: data,
          ),
        );
      case ApiFailure():
        emit(
          AppointmentRequestedState(
            status: ViewStatus.failure,
            failure: result,
          ),
        );
    }
  }
}
