import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'report.g.dart';

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class ReportModel extends Equatable {
  final int? id;
  final String? file;
  final String? title;
  final String? type;
  final String? createdAt;

  const ReportModel({this.id, this.file, this.title, this.type, this.createdAt});

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  @override
  List<Object?> get props => [id, file, title, type, createdAt];
}

@JsonSerializable(createToJson: false)
@StrConv()
class DayReportsModel extends Equatable {
  final String? date;
  @JsonKey(defaultValue: [])
  final List<ReportModel> reports;

  const DayReportsModel({this.date, this.reports = const []});

  factory DayReportsModel.fromJson(Map<String, dynamic> json) =>
      _$DayReportsModelFromJson(json);

  @override
  List<Object?> get props => [date, reports];
}
