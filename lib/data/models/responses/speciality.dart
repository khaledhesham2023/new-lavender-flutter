import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'doctor.dart';
import '../../json/json_converters.dart';

part 'speciality.g.dart';

@JsonSerializable(createToJson: false)
@StrConv()
class SpecialityModel extends Equatable {
  @JsonKey(fromJson: asIntOrZero)
  final int id;
  final String? image;
  final String? name;
  @JsonKey(fromJson: asIntOrZero)
  final int appointmentsCount;

  const SpecialityModel({
    required this.id,
    this.image,
    this.name,
    this.appointmentsCount = 0,
  });

  factory SpecialityModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialityModelFromJson(json);

  @override
  List<Object?> get props => [id, image, name, appointmentsCount];
}

/// `SubSpecialtiesData` in Kotlin (without the UI-only `isSelected`).
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class SubSpecialtyModel extends Equatable {
  final int? id;
  final String? image;
  final String? name;

  const SubSpecialtyModel({this.id, this.image, this.name});

  factory SubSpecialtyModel.fromJson(Map<String, dynamic> json) =>
      _$SubSpecialtyModelFromJson(json);

  @override
  List<Object?> get props => [id, image, name];
}

@JsonSerializable(createToJson: false)
@DoubleConv()
class FilterData extends Equatable {
  @JsonKey(defaultValue: [])
  final List<SubSpecialtyModel> specialties;
  final double? maxPrice;
  final double? minPrice;

  const FilterData({this.specialties = const [], this.maxPrice, this.minPrice});

  factory FilterData.fromJson(Map<String, dynamic> json) =>
      _$FilterDataFromJson(json);

  @override
  List<Object?> get props => [specialties, maxPrice, minPrice];
}

/// `data` of `GetDoctorsBySpecialityIdResponse`.
@JsonSerializable(createToJson: false)
@IntConv()
class DoctorsBySpecialityData extends Equatable {
  @JsonKey(defaultValue: [])
  final List<DoctorModel> doctors;
  final int? count;

  const DoctorsBySpecialityData({this.doctors = const [], this.count});

  factory DoctorsBySpecialityData.fromJson(Map<String, dynamic> json) =>
      _$DoctorsBySpecialityDataFromJson(json);

  @override
  List<Object?> get props => [doctors, count];
}
