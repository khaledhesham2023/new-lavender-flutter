import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/requests/appointment_requests.dart';
import '../../../data/models/responses/appointment.dart';
import '../../../data/repositories/booking_repository.dart';

class AddCommentState extends Equatable {
  final List<QuickComment> quickComments;
  final bool loadingQuickComments;
  final double rate;
  final bool sending;

  /// Server message after a successful send; the sheet toasts it and pops.
  final String? sentMessage;
  final ApiFailure<dynamic>? failure;

  const AddCommentState({
    this.quickComments = const [],
    this.loadingQuickComments = false,
    this.rate = 0,
    this.sending = false,
    this.sentMessage,
    this.failure,
  });

  AddCommentState copyWith({
    List<QuickComment>? quickComments,
    bool? loadingQuickComments,
    double? rate,
    bool? sending,
    String? sentMessage,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) => AddCommentState(
    quickComments: quickComments ?? this.quickComments,
    loadingQuickComments: loadingQuickComments ?? this.loadingQuickComments,
    rate: rate ?? this.rate,
    sending: sending ?? this.sending,
    sentMessage: sentMessage ?? this.sentMessage,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [
    quickComments,
    loadingQuickComments,
    rate,
    sending,
    sentMessage,
    failure,
  ];
}

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
