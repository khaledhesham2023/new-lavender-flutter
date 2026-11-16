import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'doctor.dart';
import 'json_converters.dart';
import 'offer.dart';

part 'appointment.g.dart';

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
@BoolConv()
class AppointmentData extends Equatable {
  final int? id;
  final DoctorModel? doctor;
  final String? day;
  final String? status;
  final String? statusTrans;
  final String? from;
  final String? to;

  /// JSON key `date_timeStamp`.
  @JsonKey(name: 'date_timeStamp')
  final String? dateTimeStamp;
  final String? formatedDate;
  final String? notes;
  final bool isReviewed;
  final String? report;
  final OfferModel? offer;
  @JsonKey(fromJson: asBoolDefaultTrue)
  final bool canReschedule;

  const AppointmentData({
    this.id,
    this.doctor,
    this.day,
    this.status,
    this.statusTrans,
    this.from,
    this.to,
    this.dateTimeStamp,
    this.formatedDate,
    this.notes,
    this.isReviewed = false,
    this.report,
    this.offer,
    this.canReschedule = true,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) =>
      _$AppointmentDataFromJson(json);

  @override
  List<Object?> get props => [
        id,
        doctor,
        day,
        status,
        statusTrans,
        from,
        to,
        dateTimeStamp,
        formatedDate,
        notes,
        isReviewed,
        report,
        offer,
        canReschedule,
      ];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class QuickComment extends Equatable {
  final int? id;
  final String? text;

  const QuickComment({this.id, this.text});

  factory QuickComment.fromJson(Map<String, dynamic> json) =>
      _$QuickCommentFromJson(json);

  @override
  List<Object?> get props => [id, text];
}

@JsonSerializable(createFactory: false)
class SaveAppointmentRequest extends Equatable {
  final int? doctorId;
  final String? day;
  final String? time;
  final int? userOfferId;
  final String? notes;

  const SaveAppointmentRequest({
    this.doctorId,
    this.day,
    this.time,
    this.userOfferId,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$SaveAppointmentRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [doctorId, day, time, userOfferId, notes];
}

@JsonSerializable(createFactory: false)
class UpdateAppointmentRequest extends Equatable {
  final int doctorId;
  final String day;
  final String time;

  const UpdateAppointmentRequest({
    required this.doctorId,
    required this.day,
    required this.time,
  });

  Map<String, dynamic> toJson() =>
      {..._$UpdateAppointmentRequestToJson(this), '_method': 'put'};

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [doctorId, day, time];
}

@JsonSerializable(createFactory: false)
class RebookRequest extends Equatable {
  final String? day;
  final String? time;

  const RebookRequest({this.day, this.time});

  Map<String, dynamic> toJson() => _$RebookRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [day, time];
}

@JsonSerializable(createFactory: false)
class AddCommentRequest extends Equatable {
  /// Null when 0 stars.
  final double? rate;
  final String? comment;
  final int? doctorId;
  final int? quickCommentId;
  final int? clientAppointmentId;

  const AddCommentRequest({
    this.rate,
    this.comment,
    this.doctorId,
    this.quickCommentId,
    this.clientAppointmentId,
  });

  Map<String, dynamic> toJson() => _$AddCommentRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props =>
      [rate, comment, doctorId, quickCommentId, clientAppointmentId];
}

@JsonSerializable(createFactory: false)
class ChangeAppointmentRequest extends Equatable {
  final int doctorId;
  final String day;
  @JsonKey(name: 'dayName')
  final String dayName;
  final String time;

  const ChangeAppointmentRequest({
    required this.doctorId,
    required this.day,
    required this.dayName,
    required this.time,
  });

  Map<String, dynamic> toJson() => _$ChangeAppointmentRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [doctorId, day, dayName, time];
}

/// Query of `GetBookingsRequest`.
@JsonSerializable(createFactory: false)
class GetBookingsRequest extends Equatable {
  final String? status;

  const GetBookingsRequest({this.status});

  Map<String, dynamic> toJson() => _$GetBookingsRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [status];
}

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
