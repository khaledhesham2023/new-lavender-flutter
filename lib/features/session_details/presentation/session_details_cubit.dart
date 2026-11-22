import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/appointment.dart';
import '../../../data/models/responses/offer.dart';
import '../../../shared/domain/repositories/offers_repository.dart';

class SessionDetailsState extends Equatable {
  final ViewStatus status;
  final SessionDetailsModel? session;
  final ApiFailure<dynamic>? failure;

  const SessionDetailsState({
    this.status = ViewStatus.initial,
    this.session,
    this.failure,
  });

  @override
  List<Object?> get props => [status, session, failure];
}

/// Port of `OffersViewModel.handleGetSessionDetails` for the session screen.
class SessionDetailsCubit extends Cubit<SessionDetailsState> {
  SessionDetailsCubit(this._repository, this.id)
    : super(const SessionDetailsState());

  final OffersRepository _repository;
  final int id;

  /// Only the newest request may update the state.
  int _requestId = 0;

  Future<void> load() async {
    final request = ++_requestId;
    emit(const SessionDetailsState(status: ViewStatus.loading));
    final result = await _repository.session(id);
    if (isClosed || request != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(SessionDetailsState(status: ViewStatus.success, session: data));
      case ApiFailure():
        emit(SessionDetailsState(status: ViewStatus.failure, failure: result));
    }
  }

  /// Refetches after an action changed the session.
  Future<void> reload() => load();
}

/// The fields `BookingActions` needs. A session is always booked with an
/// offer, so the result always has one (rebook is then `forOffer`).
AppointmentData sessionToAppointment(SessionDetailsModel session) {
  return AppointmentData(
    id: session.id,
    doctor: session.doctor,
    status: session.status,
    statusTrans: session.statusTrans,
    from: session.from,
    to: session.to,
    dateTimeStamp: session.dateTimeStamp,
    formatedDate: session.formatedDate,
    notes: session.notes,
    isReviewed: session.isReviewed,
    report: session.report,
    offer: session.offer ?? const OfferModel(),
    canReschedule: session.canReschedule,
  );
}
