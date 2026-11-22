import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/requests/appointment_requests.dart';
import '../domain/repositories/booking_repository.dart';
import 'add_comment_state.dart';

/// Port of the comment part of `BookingSearchViewModel` used by
/// `AddCommentSheetFragment`.
class AddCommentCubit extends Cubit<AddCommentState> {
  AddCommentCubit(
    this._repo, {
    required this.doctorId,
    required this.appointmentId,
  }) : super(const AddCommentState());

  final BookingRepository _repo;
  final int doctorId;
  final int appointmentId;

  Future<void> loadQuickComments() async {
    emit(state.copyWith(loadingQuickComments: true, clearFailure: true));
    final result = await _repo.quickComments();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(quickComments: data, loadingQuickComments: false));
      case ApiFailure():
        emit(state.copyWith(loadingQuickComments: false, failure: result));
    }
  }

  void setRate(double rate) => emit(state.copyWith(rate: rate));

  /// Sends the review. 0 stars means `rate: null` (Android).
  Future<void> send(String comment) async {
    if (state.sending) return;
    emit(state.copyWith(sending: true, clearFailure: true));
    final result = await _repo.addComment(
      AddCommentRequest(
        rate: state.rate == 0 ? null : state.rate,
        comment: comment.trim(),
        doctorId: doctorId,
        clientAppointmentId: appointmentId,
      ),
    );
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(sending: false, sentMessage: data));
      case ApiFailure():
        emit(state.copyWith(sending: false, failure: result));
    }
  }
}
