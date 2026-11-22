import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/domain/repositories/offers_repository.dart';
import 'session_requested_state.dart';

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
        emit(
          SessionRequestedState(status: ViewStatus.failure, failure: result),
        );
    }
  }
}
