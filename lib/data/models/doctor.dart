import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';
import 'offer.dart';

part 'doctor.g.dart';

@JsonSerializable(createToJson: false)
@StrConv()
@BoolConv()
class TimeModel extends Equatable {
  /// Displayed only.
  final String? time;
  final bool isReserved;

  /// This is what gets sent to the API as `time`.
  final String? timeFormatted;

  const TimeModel({this.time, this.isReserved = false, this.timeFormatted});

  factory TimeModel.fromJson(Map<String, dynamic> json) =>
      _$TimeModelFromJson(json);

  @override
  List<Object?> get props => [time, isReserved, timeFormatted];
}

@JsonSerializable(createToJson: false)
@StrConv()
class WorkTimeModel extends Equatable {
  final String? day;
  final String? dayTranslated;

  /// ISO `yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'`.
  final String? date;
  @JsonKey(defaultValue: [])
  final List<TimeModel> times;
  final String? formatedDate;
  @JsonKey(fromJson: asIntOrZero)
  final int isActive;

  const WorkTimeModel({
    this.day,
    this.dayTranslated,
    this.date,
    this.times = const [],
    this.formatedDate,
    this.isActive = 0,
  });

  factory WorkTimeModel.fromJson(Map<String, dynamic> json) =>
      _$WorkTimeModelFromJson(json);

  @override
  List<Object?> get props =>
      [day, dayTranslated, date, times, formatedDate, isActive];
}

@JsonSerializable(createToJson: false)
@IntConv()
@DoubleConv()
@StrConv()
class ReviewModel extends Equatable {
  final int? id;
  final double? rate;

  /// JSON key `created_at`.
  @JsonKey(name: 'created_at')
  final String? date;
  final String? comment;
  final String? clientName;
  final String? clientImage;

  const ReviewModel({
    this.id,
    this.rate,
    this.date,
    this.comment,
    this.clientName,
    this.clientImage,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  @override
  List<Object?> get props => [id, rate, date, comment, clientName, clientImage];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class CertificateModel extends Equatable {
  final int? id;
  final String? media;

  const CertificateModel({this.id, this.media});

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      _$CertificateModelFromJson(json);

  @override
  List<Object?> get props => [id, media];
}

@JsonSerializable(createToJson: false)
@IntConv()
@DoubleConv()
@StrConv()
@BoolConv()
class DoctorModel extends Equatable {
  final int? id;
  final String? name;
  final String? about;
  final String? specialty;
  final String? subSpecialty;
  final String? image;
  final String? gender;
  final String? duration;
  final String? price;
  final String? experience;
  @JsonKey(defaultValue: [])
  final List<WorkTimeModel> workTimes;
  final bool isFav;
  @JsonKey(fromJson: asStringListOrEmpty)
  final List<String> doctorWorkTimesDays;
  final int? reviewsCount;
  @JsonKey(defaultValue: [])
  final List<ReviewModel> reviews;
  final double? rate;
  final double? stars;
  final double? five;
  @JsonKey(defaultValue: [])
  final List<OfferModel> userOffers;
  final double? four;
  final double? three;
  final double? two;
  final double? one;
  @JsonKey(defaultValue: [])
  final List<CertificateModel> certificates;

  const DoctorModel({
    this.id,
    this.name,
    this.about,
    this.specialty,
    this.subSpecialty,
    this.image,
    this.gender,
    this.duration,
    this.price,
    this.experience,
    this.workTimes = const [],
    this.isFav = false,
    this.doctorWorkTimesDays = const [],
    this.reviewsCount,
    this.reviews = const [],
    this.rate,
    this.stars,
    this.five,
    this.userOffers = const [],
    this.four,
    this.three,
    this.two,
    this.one,
    this.certificates = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorModelFromJson(json);

  DoctorModel copyWith({bool? isFav}) => DoctorModel(
        id: id,
        name: name,
        about: about,
        specialty: specialty,
        subSpecialty: subSpecialty,
        image: image,
        gender: gender,
        duration: duration,
        price: price,
        experience: experience,
        workTimes: workTimes,
        isFav: isFav ?? this.isFav,
        doctorWorkTimesDays: doctorWorkTimesDays,
        reviewsCount: reviewsCount,
        reviews: reviews,
        rate: rate,
        stars: stars,
        five: five,
        userOffers: userOffers,
        four: four,
        three: three,
        two: two,
        one: one,
        certificates: certificates,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        about,
        specialty,
        subSpecialty,
        image,
        gender,
        duration,
        price,
        experience,
        workTimes,
        isFav,
        doctorWorkTimesDays,
        reviewsCount,
        reviews,
        rate,
        stars,
        five,
        userOffers,
        four,
        three,
        two,
        one,
        certificates,
      ];
}

/// Body of `ToggleFavoriteRequest`; `doctor_id` is sent as a **String**.
class ToggleFavoriteRequest extends Equatable {
  final int doctorId;

  const ToggleFavoriteRequest(this.doctorId);

  Map<String, dynamic> toJson() => {'doctor_id': doctorId.toString()};

  @override
  List<Object?> get props => [doctorId];
}
