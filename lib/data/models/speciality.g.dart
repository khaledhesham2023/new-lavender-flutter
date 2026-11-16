// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speciality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecialityModel _$SpecialityModelFromJson(Map<String, dynamic> json) =>
    SpecialityModel(
      id: asIntOrZero(json['id']),
      image: const StrConv().fromJson(json['image']),
      name: const StrConv().fromJson(json['name']),
      appointmentsCount: json['appointments_count'] == null
          ? 0
          : asIntOrZero(json['appointments_count']),
    );

SubSpecialtyModel _$SubSpecialtyModelFromJson(Map<String, dynamic> json) =>
    SubSpecialtyModel(
      id: const IntConv().fromJson(json['id']),
      image: const StrConv().fromJson(json['image']),
      name: const StrConv().fromJson(json['name']),
    );

FilterData _$FilterDataFromJson(Map<String, dynamic> json) => FilterData(
  specialties:
      (json['specialties'] as List<dynamic>?)
          ?.map((e) => SubSpecialtyModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  maxPrice: const DoubleConv().fromJson(json['max_price']),
  minPrice: const DoubleConv().fromJson(json['min_price']),
);

DoctorsBySpecialityData _$DoctorsBySpecialityDataFromJson(
  Map<String, dynamic> json,
) => DoctorsBySpecialityData(
  doctors:
      (json['doctors'] as List<dynamic>?)
          ?.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  count: const IntConv().fromJson(json['count']),
);
