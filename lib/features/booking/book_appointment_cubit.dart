import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/requests/appointment_requests.dart';
import '../../data/models/requests/booking_draft.dart';
import '../../data/repositories/booking_repository.dart';

class BookAppointmentState extends Equatable {
  /// The booking being confirmed; day / time are replaced by [BookAppointmentCubit.changeTo].
  final BookingDraft draft;

  /// Text of the "Date" line: the draft's formatted date until the day is changed.
  final String dayText;

  /// `loading` while saving; `success` once [bookedId] is set.
  final ViewStatus status;
  final int? bookedId;
  final ApiFailure<dynamic>? failure;

  const BookAppointmentState({
    required this.draft,
    required this.dayText,
    this.status = ViewStatus.initial,
    this.bookedId,
    this.failure,
  });

  bool get saving => status == ViewStatus.loading;

  BookAppointmentState copyWith({
    BookingDraft? draft,
    String? dayText,
    ViewStatus? status,
    int? bookedId,
    ApiFailure<dynamic>? failure,
    bool clearBookedId = false,
    bool clearFailure = false,
  }) => BookAppointmentState(
    draft: draft ?? this.draft,
    dayText: dayText ?? this.dayText,
    status: status ?? this.status,
    bookedId: clearBookedId ? null : (bookedId ?? this.bookedId),
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [draft, dayText, status, bookedId, failure];
}

/// Port of `BookAppointmentsViewModel` + the day/time part of
/// `BookAppointmentFragment` (`BookingRequestModel` and the change-sheet result
/// become [BookingDraft] and [changeTo]).
class BookAppointmentCubit extends Cubit<BookAppointmentState> {
  BookAppointmentCubit(this._repository, BookingDraft draft)
    : super(
        BookAppointmentState(draft: draft, dayText: draft.formattedDate ?? ''),
      );

  final BookingRepository _repository;

  /// Applies the day/time chosen in the change-appointment sheet. [lang] is the
  /// UI language used for the readable date (`"<dayName>,<dd MMMM yyyy>"`).
  void changeTo(ChangeAppointmentRequest r, {required String lang}) {
    final readable = convertDateToReadableFormat(
      convertIsoToDateOnly(r.day),
      lang,
    );
    emit(
      state.copyWith(
        draft: state.draft.copyWith(date: r.day, day: r.dayName, time: r.time),
        dayText: '${r.dayName},$readable',
      ),
    );
  }

  /// Saves the appointment; the result is [BookAppointmentState.bookedId] or
  /// [BookAppointmentState.failure] (the screen reacts, then calls [consume]).
  Future<void> book(String notes) async {
    if (state.saving) return;
    final draft = state.draft;
    final trimmed = notes.trim();
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        clearFailure: true,
        clearBookedId: true,
      ),
    );
    final result = await _repository.save(
      SaveAppointmentRequest(
        doctorId: draft.doctorId,
        day: convertIsoToDateOnly(draft.date ?? ''),
        time: draft.time,
        // Set only by the book-with-offer screen (T25); null for a normal booking.
        userOfferId: draft.userOfferId,
        notes: trimmed.isEmpty ? null : trimmed,
      ),
    );
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        final id = data.id;
        if (id == null) {
          // Android navigates only when the response carries an id.
          emit(state.copyWith(status: ViewStatus.initial));
        } else {
          emit(state.copyWith(status: ViewStatus.success, bookedId: id));
        }
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// Clears the one-shot result after the screen handled it.
  void consume() => emit(
    state.copyWith(
      status: ViewStatus.initial,
      clearBookedId: true,
      clearFailure: true,
    ),
  );
}
