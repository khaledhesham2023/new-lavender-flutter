// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeModel _$TimeModelFromJson(Map<String, dynamic> json) => TimeModel(
  time: const StrConv().fromJson(json['time']),
  isReserved: json['is_reserved'] == null
      ? false
      : const BoolConv().fromJson(json['is_reserved']),
  timeFormatted: const StrConv().fromJson(json['time_formatted']),
);

WorkTimeModel _$WorkTimeModelFromJson(Map<String, dynamic> json) =>
    WorkTimeModel(
      day: const StrConv().fromJson(json['day']),
      dayTranslated: const StrConv().fromJson(json['day_translated']),
      date: const StrConv().fromJson(json['date']),
      times:
          (json['times'] as List<dynamic>?)
              ?.map((e) => TimeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      formatedDate: const StrConv().fromJson(json['formated_date']),
      isActive: json['is_active'] == null ? 0 : asIntOrZero(json['is_active']),
    );

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: const IntConv().fromJson(json['id']),
  rate: const DoubleConv().fromJson(json['rate']),
  date: const StrConv().fromJson(json['created_at']),
  comment: const StrConv().fromJson(json['comment']),
  clientName: const StrConv().fromJson(json['client_name']),
  clientImage: const StrConv().fromJson(json['client_image']),
);

CertificateModel _$CertificateModelFromJson(Map<String, dynamic> json) =>
    CertificateModel(
      id: const IntConv().fromJson(json['id']),
      media: const StrConv().fromJson(json['media']),
    );

DoctorModel _$DoctorModelFromJson(Map<String, dynamic> json) => DoctorModel(
  id: const IntConv().fromJson(json['id']),
  name: const StrConv().fromJson(json['name']),
  about: const StrConv().fromJson(json['about']),
  specialty: const StrConv().fromJson(json['specialty']),
  subSpecialty: const StrConv().fromJson(json['sub_specialty']),
  image: const StrConv().fromJson(json['image']),
  gender: const StrConv().fromJson(json['gender']),
  duration: const StrConv().fromJson(json['duration']),
  price: const StrConv().fromJson(json['price']),
  experience: const StrConv().fromJson(json['experience']),
  workTimes:
      (json['work_times'] as List<dynamic>?)
          ?.map((e) => WorkTimeModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isFav: json['is_fav'] == null
      ? false
      : const BoolConv().fromJson(json['is_fav']),
  doctorWorkTimesDays: json['doctor_work_times_days'] == null
      ? const []
      : asStringListOrEmpty(json['doctor_work_times_days']),
  reviewsCount: const IntConv().fromJson(json['reviews_count']),
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  rate: const DoubleConv().fromJson(json['rate']),
  stars: const DoubleConv().fromJson(json['stars']),
  five: const DoubleConv().fromJson(json['five']),
  userOffers:
      (json['user_offers'] as List<dynamic>?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  four: const DoubleConv().fromJson(json['four']),
  three: const DoubleConv().fromJson(json['three']),
  two: const DoubleConv().fromJson(json['two']),
  one: const DoubleConv().fromJson(json['one']),
  certificates:
      (json['certificates'] as List<dynamic>?)
          ?.map((e) => CertificateModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);
