// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: asIntOrZero(json['id']),
  offerId: asIntOrZero(json['offer_id']),
  isActive: asIntOrZero(json['is_active']),
  startDate: asStringOrEmpty(json['start_date']),
  endDate: asStringOrEmpty(json['end_date']),
  image: asStringOrEmpty(json['image']),
);

NextReservationModel _$NextReservationModelFromJson(
  Map<String, dynamic> json,
) => NextReservationModel(
  id: const IntConv().fromJson(json['id']),
  day: const StrConv().fromJson(json['day']),
  time: const StrConv().fromJson(json['time']),
  datetime: const StrConv().fromJson(json['datetime']),
  doctor: json['doctor'] == null
      ? null
      : DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>),
  difference: const IntConv().fromJson(json['difference']),
);

HomeData _$HomeDataFromJson(Map<String, dynamic> json) => HomeData(
  notificationsCount: const IntConv().fromJson(json['notifications_count']),
  nextReservation: json['next_reservation'] == null
      ? null
      : NextReservationModel.fromJson(
          json['next_reservation'] as Map<String, dynamic>,
        ),
  userName: const StrConv().fromJson(json['user_name']),
  userImage: const StrConv().fromJson(json['user_image']),
  banners:
      (json['bannars'] as List<dynamic>?)
          ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  specialties:
      (json['specialties'] as List<dynamic>?)
          ?.map((e) => SpecialityModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  doctors:
      (json['doctors'] as List<dynamic>?)
          ?.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  offers:
      (json['offers'] as List<dynamic>?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);
