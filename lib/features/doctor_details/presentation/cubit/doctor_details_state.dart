part of 'doctor_details_cubit.dart';

class DoctorDetailsState extends Equatable {
  final ViewStatus status;
  final DoctorModel? doctor;
  final bool isFav;
  final ApiFailure<dynamic>? failure;

  /// One-shot: the favorite request failed (the screen toasts it, then calls
  /// [DoctorDetailsCubit.consumeFavoriteFailure]).
  final ApiFailure<dynamic>? favoriteFailure;

  /// Set by the Booking-time tab (T23).
  final WorkTimeModel? selectedDay;
  final TimeModel? selectedTime;

  const DoctorDetailsState({
    this.status = ViewStatus.initial,
    this.doctor,
    this.isFav = false,
    this.failure,
    this.favoriteFailure,
    this.selectedDay,
    this.selectedTime,
  });

  DoctorDetailsState copyWith({
    ViewStatus? status,
    DoctorModel? doctor,
    bool? isFav,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
    ApiFailure<dynamic>? favoriteFailure,
    bool clearFavoriteFailure = false,
    WorkTimeModel? selectedDay,
    bool clearSelectedDay = false,
    TimeModel? selectedTime,
    bool clearSelectedTime = false,
  }) {
    return DoctorDetailsState(
      status: status ?? this.status,
      doctor: doctor ?? this.doctor,
      isFav: isFav ?? this.isFav,
      failure: clearFailure ? null : (failure ?? this.failure),
      favoriteFailure: clearFavoriteFailure
          ? null
          : (favoriteFailure ?? this.favoriteFailure),
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      selectedTime: clearSelectedTime
          ? null
          : (selectedTime ?? this.selectedTime),
    );
  }

  @override
  List<Object?> get props => [
    status,
    doctor,
    isFav,
    failure,
    favoriteFailure,
    selectedDay,
    selectedTime,
  ];
}
