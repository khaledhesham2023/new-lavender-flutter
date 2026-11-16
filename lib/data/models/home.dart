import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'doctor.dart';
import 'json_converters.dart';
import 'offer.dart';
import 'speciality.dart';

part 'home.g.dart';

@JsonSerializable(createToJson: false)
class BannerModel extends Equatable {
  @JsonKey(fromJson: asIntOrZero)
  final int id;
  @JsonKey(fromJson: asIntOrZero)
  final int offerId;
  @JsonKey(fromJson: asIntOrZero)
  final int isActive;
  @JsonKey(fromJson: asStringOrEmpty)
  final String startDate;
  @JsonKey(fromJson: asStringOrEmpty)
  final String endDate;
  @JsonKey(fromJson: asStringOrEmpty)
  final String image;

  const BannerModel({
    required this.id,
    required this.offerId,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.image,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  @override
  List<Object?> get props => [id, offerId, isActive, startDate, endDate, image];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class NextReservationModel extends Equatable {
  final int? id;
  final String? day;
  final String? time;
  final String? datetime;
  final DoctorModel? doctor;

  /// Seconds until the reservation.
  final int? difference;

  const NextReservationModel({
    this.id,
    this.day,
    this.time,
    this.datetime,
    this.doctor,
    this.difference,
  });

  factory NextReservationModel.fromJson(Map<String, dynamic> json) =>
      _$NextReservationModelFromJson(json);

  @override
  List<Object?> get props => [id, day, time, datetime, doctor, difference];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class HomeData extends Equatable {
  final int? notificationsCount;
  final NextReservationModel? nextReservation;
  final String? userName;
  final String? userImage;

  /// The backend key is misspelled.
  @JsonKey(name: 'bannars', defaultValue: [])
  final List<BannerModel> banners;
  @JsonKey(defaultValue: [])
  final List<SpecialityModel> specialties;
  @JsonKey(defaultValue: [])
  final List<DoctorModel> doctors;
  @JsonKey(defaultValue: [])
  final List<OfferModel> offers;

  const HomeData({
    this.notificationsCount,
    this.nextReservation,
    this.userName,
    this.userImage,
    this.banners = const [],
    this.specialties = const [],
    this.doctors = const [],
    this.offers = const [],
  });

  factory HomeData.fromJson(Map<String, dynamic> json) =>
      _$HomeDataFromJson(json);

  @override
  List<Object?> get props => [
        notificationsCount,
        nextReservation,
        userName,
        userImage,
        banners,
        specialties,
        doctors,
        offers,
      ];
}
