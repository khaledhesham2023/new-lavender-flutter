import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'doctor.dart';
import '../../json/json_converters.dart';
import 'speciality.dart';

part 'search.g.dart';

@JsonSerializable(createToJson: false)
class SearchResultsData extends Equatable {
  @JsonKey(defaultValue: [])
  final List<DoctorModel> doctors;
  @JsonKey(defaultValue: [])
  final List<SpecialityModel> specialties;

  const SearchResultsData({
    this.doctors = const [],
    this.specialties = const [],
  });

  factory SearchResultsData.fromJson(Map<String, dynamic> json) =>
      _$SearchResultsDataFromJson(json);

  @override
  List<Object?> get props => [doctors, specialties];
}

/// `SearchResultModel` in Kotlin.
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class RecentSearchModel extends Equatable {
  final int? id;
  final String? search;

  const RecentSearchModel({this.id, this.search});

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) =>
      _$RecentSearchModelFromJson(json);

  @override
  List<Object?> get props => [id, search];
}
