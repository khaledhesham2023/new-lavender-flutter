import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/appointment.dart';
import '../../data/repositories/booking_repository.dart';

class AppointmentDetailsState extends Equatable {
  final ViewStatus status;
  final AppointmentData? appointment;
  final ApiFailure<dynamic>? failure;

  const AppointmentDetailsState({
    this.status = ViewStatus.initial,
    this.appointment,
    this.failure,
  });

  @override
  List<Object?> get props => [status, appointment, failure];
}

/// Port of `AppointmentDetailsViewModel` (`GetAppointmentDetails`).
class AppointmentDetailsCubit extends Cubit<AppointmentDetailsState> {
  AppointmentDetailsCubit(this._repository, this.id)
    : super(const AppointmentDetailsState());

  final BookingRepository _repository;
  final int id;

  /// Only the newest request may update the state.
  int _requestId = 0;

  Future<void> load() async {
    final request = ++_requestId;
    emit(const AppointmentDetailsState(status: ViewStatus.loading));
    final result = await _repository.details(id);
    if (isClosed || request != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          AppointmentDetailsState(
            status: ViewStatus.success,
            appointment: data,
          ),
        );
      case ApiFailure():
        emit(AppointmentDetailsState(status: ViewStatus.failure, failure: result));
    }
  }

  /// Refetches after an action changed the booking (Android reloads the
  /// details instead of removing anything).
  Future<void> reload() => load();
}
