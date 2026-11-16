// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferModel _$OfferModelFromJson(Map<String, dynamic> json) => OfferModel(
  id: const IntConv().fromJson(json['id']),
  name: const StrConv().fromJson(json['name']),
  description: const StrConv().fromJson(json['description']),
  details: const StrConv().fromJson(json['details']),
  price: const DoubleConv().fromJson(json['price']),
  specialty: const StrConv().fromJson(json['specialty']),
  discount: const DoubleConv().fromJson(json['discount']),
  finalPrice: const DoubleConv().fromJson(json['final_price']),
  number: const IntConv().fromJson(json['number']),
  image: const StrConv().fromJson(json['image']),
  usedNumber: const IntConv().fromJson(json['used_number']),
  createdAt: const StrConv().fromJson(json['created_at']),
  startDate: const StrConv().fromJson(json['start_date']),
  endDate: const StrConv().fromJson(json['end_date']),
  specialtyModel: json['specialty_model'] == null
      ? null
      : SpecialityModel.fromJson(
          json['specialty_model'] as Map<String, dynamic>,
        ),
  appointments:
      (json['appointments'] as List<dynamic>?)
          ?.map((e) => AppointmentData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

MyOffersData _$MyOffersDataFromJson(Map<String, dynamic> json) => MyOffersData(
  availableOffers:
      (json['available_offers'] as List<dynamic>?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  completedOffers:
      (json['completed_offers'] as List<dynamic>?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

SessionDetailsModel _$SessionDetailsModelFromJson(Map<String, dynamic> json) =>
    SessionDetailsModel(
      id: const IntConv().fromJson(json['id']),
      doctor: json['doctor'] == null
          ? null
          : DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>),
      offer: json['offer'] == null
          ? null
          : OfferModel.fromJson(json['offer'] as Map<String, dynamic>),
      formatedDate: const StrConv().fromJson(json['formated_date']),
      canReschedule: json['can_reschedule'] == null
          ? false
          : const BoolConv().fromJson(json['can_reschedule']),
      dateTimeStamp: const StrConv().fromJson(json['date_timeStamp']),
      notes: const StrConv().fromJson(json['notes']),
      status: const StrConv().fromJson(json['status']),
      statusTrans: const StrConv().fromJson(json['status_trans']),
      from: const StrConv().fromJson(json['from']),
      to: const StrConv().fromJson(json['to']),
      number: const IntConv().fromJson(json['number']),
      usedNumber: const IntConv().fromJson(json['used_number']),
      isReviewed: json['is_reviewed'] == null
          ? false
          : const BoolConv().fromJson(json['is_reviewed']),
      report: const StrConv().fromJson(json['report']),
    );
