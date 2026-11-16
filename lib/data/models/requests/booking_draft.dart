import 'package:equatable/equatable.dart';

/// Screen-to-screen booking object (port of `BookingRequestModel`; no JSON).
class BookingDraft extends Equatable {
  final int? doctorId;
  final String? doctorImage;
  final String? doctorName;
  final String? doctorSpecialization;
  final double? stars;
  final double? rate;
  final int? reviewsCount;

  /// ISO date.
  final String? date;
  final String? formattedDate;

  /// Translated day name.
  final String? day;

  /// `time_formatted`.
  final String? time;
  final String? examinationPrice;
  final int? userOfferId;
  final String? duration;

  const BookingDraft({
    this.doctorId,
    this.doctorImage,
    this.doctorName,
    this.doctorSpecialization,
    this.stars,
    this.rate,
    this.reviewsCount,
    this.date,
    this.formattedDate,
    this.day,
    this.time,
    this.examinationPrice,
    this.userOfferId,
    this.duration,
  });

  /// Passing null keeps the current value (a field cannot be reset to null).
  BookingDraft copyWith({
    int? doctorId,
    String? doctorImage,
    String? doctorName,
    String? doctorSpecialization,
    double? stars,
    double? rate,
    int? reviewsCount,
    String? date,
    String? formattedDate,
    String? day,
    String? time,
    String? examinationPrice,
    int? userOfferId,
    String? duration,
  }) =>
      BookingDraft(
        doctorId: doctorId ?? this.doctorId,
        doctorImage: doctorImage ?? this.doctorImage,
        doctorName: doctorName ?? this.doctorName,
        doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
        stars: stars ?? this.stars,
        rate: rate ?? this.rate,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        date: date ?? this.date,
        formattedDate: formattedDate ?? this.formattedDate,
        day: day ?? this.day,
        time: time ?? this.time,
        examinationPrice: examinationPrice ?? this.examinationPrice,
        userOfferId: userOfferId ?? this.userOfferId,
        duration: duration ?? this.duration,
      );

  @override
  List<Object?> get props => [
        doctorId,
        doctorImage,
        doctorName,
        doctorSpecialization,
        stars,
        rate,
        reviewsCount,
        date,
        formattedDate,
        day,
        time,
        examinationPrice,
        userOfferId,
        duration,
      ];
}
