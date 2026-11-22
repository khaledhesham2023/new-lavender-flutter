import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/booking_draft.dart';
import '../../../../data/models/responses/doctor.dart';
import '../../domain/repositories/doctor_repository.dart';

part 'doctor_details_state.dart';

/// Port of `DoctorDetailsViewModel` + `DoctorDetailsSharedViewModel`: the doctor,
/// the heart, and the day / time chosen in the Booking-time tab (T23).
class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  DoctorDetailsCubit(this._repository, this.id)
    : super(const DoctorDetailsState());

  final DoctorRepository _repository;
  final int id;

  /// Loads the doctor. The selection is reset (Android re-selects the first day
  /// when the tab receives the new doctor).
  Future<void> load() async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        clearFailure: true,
        clearSelectedDay: true,
        clearSelectedTime: true,
      ),
    );
    final result = await _repository.getDoctor(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            status: ViewStatus.success,
            doctor: data,
            isFav: data.isFav,
          ),
        );
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// Unlike Home, the heart flips only **after** the request succeeds.
  Future<void> toggleFavorite() async {
    final result = await _repository.toggleFavorite(id);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(state.copyWith(isFav: !state.isFav));
      case ApiFailure():
        emit(state.copyWith(favoriteFailure: result));
    }
  }

  void consumeFavoriteFailure() =>
      emit(state.copyWith(clearFavoriteFailure: true));

  /// Choosing another day (or none) clears the chosen time.
  void selectDay(WorkTimeModel? day) => emit(
    state.copyWith(
      selectedDay: day,
      clearSelectedDay: day == null,
      clearSelectedTime: true,
    ),
  );

  void selectTime(TimeModel? time) => emit(
    state.copyWith(selectedTime: time, clearSelectedTime: time == null),
  );

  /// Port of the `BookingRequestModel` built by `btnBookAnAppointment` (no offer).
  BookingDraft? buildDraft() {
    final doctor = state.doctor;
    if (doctor == null) return null;
    final day = state.selectedDay;
    final time = state.selectedTime;
    return BookingDraft(
      doctorId: doctor.id,
      doctorImage: doctor.image,
      doctorName: doctor.name,
      doctorSpecialization: doctor.subSpecialty ?? doctor.specialty,
      stars: doctor.stars,
      rate: doctor.rate,
      reviewsCount: doctor.reviewsCount,
      duration: doctor.duration,
      examinationPrice: doctor.price,
      time: time?.timeFormatted,
      formattedDate: day?.formatedDate,
      day: day?.dayTranslated,
      date: day?.date,
    );
  }
}
