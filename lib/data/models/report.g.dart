// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  id: const IntConv().fromJson(json['id']),
  file: const StrConv().fromJson(json['file']),
  title: const StrConv().fromJson(json['title']),
  type: const StrConv().fromJson(json['type']),
  createdAt: const StrConv().fromJson(json['created_at']),
);

DayReportsModel _$DayReportsModelFromJson(Map<String, dynamic> json) =>
    DayReportsModel(
      date: const StrConv().fromJson(json['date']),
      reports:
          (json['reports'] as List<dynamic>?)
              ?.map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
