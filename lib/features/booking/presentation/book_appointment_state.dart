import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/requests/booking_draft.dart';

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
