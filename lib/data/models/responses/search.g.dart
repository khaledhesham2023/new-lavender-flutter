// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultsData _$SearchResultsDataFromJson(Map<String, dynamic> json) =>
    SearchResultsData(
      doctors:
          (json['doctors'] as List<dynamic>?)
              ?.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      specialties:
          (json['specialties'] as List<dynamic>?)
              ?.map((e) => SpecialityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

RecentSearchModel _$RecentSearchModelFromJson(Map<String, dynamic> json) =>
    RecentSearchModel(
      id: const IntConv().fromJson(json['id']),
      search: const StrConv().fromJson(json['search']),
    );
