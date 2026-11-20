import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/requests/appointment_requests.dart';
import '../../../data/repositories/booking_repository.dart';

/// What the confirmation sheet does when Confirm is tapped.
sealed class ConfirmAction {
  const ConfirmAction();
}

class CancelAction extends ConfirmAction {
  final int id;
  const CancelAction(this.id);
}

class UpdateAction extends ConfirmAction {
  final int id;
  final UpdateAppointmentRequest request;
  const UpdateAction(this.id, this.request);
}

class ConfirmationState extends Equatable {
  final bool loading;

  /// Set after a failed confirm; the sheet toasts it and stays open.
  final ApiFailure<dynamic>? failure;

  /// True once the action succeeded; the sheet then pops with `true`.
  final bool done;

  const ConfirmationState({
    this.loading = false,
    this.failure,
    this.done = false,
  });

  @override
  List<Object?> get props => [loading, failure, done];
}

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
