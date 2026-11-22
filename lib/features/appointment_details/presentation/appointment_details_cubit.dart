import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/domain/repositories/booking_repository.dart';
import 'appointment_details_state.dart';

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
