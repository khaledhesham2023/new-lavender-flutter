import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'appointment.dart';
import 'doctor.dart';
import 'json_converters.dart';
import 'speciality.dart';

part 'offer.g.dart';

@JsonSerializable(createToJson: false)
@IntConv()
@DoubleConv()
@StrConv()
class OfferModel extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final String? details;
  final double? price;
  final String? specialty;
  final double? discount;
  final double? finalPrice;
  final int? number;
  final String? image;
  final int? usedNumber;
  final String? createdAt;
  final String? startDate;
  final String? endDate;
  final SpecialityModel? specialtyModel;
  @JsonKey(defaultValue: [])
  final List<AppointmentData> appointments;

  const OfferModel({
    this.id,
    this.name,
    this.description,
    this.details,
    this.price,
    this.specialty,
    this.discount,
    this.finalPrice,
    this.number,
    this.image,
    this.usedNumber,
    this.createdAt,
    this.startDate,
    this.endDate,
    this.specialtyModel,
    this.appointments = const [],
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) =>
      _$OfferModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        details,
        price,
        specialty,
        discount,
        finalPrice,
        number,
        image,
        usedNumber,
        createdAt,
        startDate,
        endDate,
        specialtyModel,
        appointments,
      ];
}

/// `data` of `GetMyOffersResponse`.
@JsonSerializable(createToJson: false)
class MyOffersData extends Equatable {
  @JsonKey(defaultValue: [])
  final List<OfferModel> availableOffers;
  @JsonKey(defaultValue: [])
  final List<OfferModel> completedOffers;

  const MyOffersData({
    this.availableOffers = const [],
    this.completedOffers = const [],
  });

  factory MyOffersData.fromJson(Map<String, dynamic> json) =>
      _$MyOffersDataFromJson(json);

  @override
  List<Object?> get props => [availableOffers, completedOffers];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
@BoolConv()
class SessionDetailsModel extends Equatable {
  final int? id;
  final DoctorModel? doctor;
  final OfferModel? offer;
  final String? formatedDate;
  final bool canReschedule;
  @JsonKey(name: 'date_timeStamp')
  final String? dateTimeStamp;
  final String? notes;
  final String? status;
  final String? statusTrans;
  final String? from;
  final String? to;
  final int? number;
  final int? usedNumber;
  final bool isReviewed;
  final String? report;

  const SessionDetailsModel({
    this.id,
    this.doctor,
    this.offer,
    this.formatedDate,
    this.canReschedule = false,
    this.dateTimeStamp,
    this.notes,
    this.status,
    this.statusTrans,
    this.from,
    this.to,
    this.number,
    this.usedNumber,
    this.isReviewed = false,
    this.report,
  });

  factory SessionDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$SessionDetailsModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        doctor,
        offer,
        formatedDate,
        canReschedule,
        dateTimeStamp,
        notes,
        status,
        statusTrans,
        from,
        to,
        number,
        usedNumber,
        isReviewed,
        report,
      ];
}

/// Body of `BuyOfferRequest`.
@JsonSerializable(createFactory: false)
class BuyOfferRequest extends Equatable {
  final int? offerId;

  const BuyOfferRequest({this.offerId});

  Map<String, dynamic> toJson() => _$BuyOfferRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [offerId];
}
