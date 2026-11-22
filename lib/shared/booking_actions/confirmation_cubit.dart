import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../domain/repositories/booking_repository.dart';
import 'confirm_action.dart';
import 'confirmation_state.dart';

/// Port of the cancel / update part of `BookingSearchViewModel` used by
/// `ConfirmationSheetFragment`.
class ConfirmationCubit extends Cubit<ConfirmationState> {
  ConfirmationCubit(this._repo, this.action) : super(const ConfirmationState());

  final BookingRepository _repo;
  final ConfirmAction action;

  Future<void> confirm() async {
    if (state.loading) return;
    emit(const ConfirmationState(loading: true));
    final result = switch (action) {
      CancelAction(:final id) => await _repo.cancel(id),
      UpdateAction(:final id, :final request) => await _repo.update(
        id,
        request,
      ),
    };
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(const ConfirmationState(done: true));
      case ApiFailure():
        emit(ConfirmationState(failure: result));
    }
  }
}
