import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/offer.dart';
import '../../data/repositories/offers_repository.dart';

class SessionRequestedState extends Equatable {
  final ViewStatus status;
  final SessionDetailsModel? session;
  final ApiFailure<dynamic>? failure;

  const SessionRequestedState({
    this.status = ViewStatus.initial,
    this.session,
    this.failure,
  });

  @override
  List<Object?> get props => [status, session, failure];
}

/// Port of `OffersViewModel.GetSessionDetails` as used by
/// `SuccessfulAppointmentRequestFragmentWithOfferFragment`.
class SessionRequestedCubit extends Cubit<SessionRequestedState> {
  SessionRequestedCubit(this._repository, this.id)
    : super(const SessionRequestedState());

  final OffersRepository _repository;
  final int id;

  Future<void> load() async {
    emit(const SessionRequestedState(status: ViewStatus.loading));
    final result = await _repository.session(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(SessionRequestedState(status: ViewStatus.success, session: data));
      case ApiFailure():
        emit(SessionRequestedState(status: ViewStatus.failure, failure: result));
    }
  }
}
