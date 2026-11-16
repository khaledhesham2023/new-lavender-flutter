import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'doctor.dart';
import '../../json/json_converters.dart';
import 'offer.dart';

part 'appointment.g.dart';

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
@BoolConv()
class AppointmentData extends Equatable {
  final int? id;
  final DoctorModel? doctor;
  final String? day;
  final String? status;
  final String? statusTrans;
  final String? from;
  final String? to;

  /// JSON key `date_timeStamp`.
  @JsonKey(name: 'date_timeStamp')
  final String? dateTimeStamp;
  final String? formatedDate;
  final String? notes;
  final bool isReviewed;
  final String? report;
  final OfferModel? offer;
  @JsonKey(fromJson: asBoolDefaultTrue)
  final bool canReschedule;

  const AppointmentData({
    this.id,
    this.doctor,
    this.day,
    this.status,
    this.statusTrans,
    this.from,
    this.to,
    this.dateTimeStamp,
    this.formatedDate,
    this.notes,
    this.isReviewed = false,
    this.report,
    this.offer,
    this.canReschedule = true,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) =>
      _$AppointmentDataFromJson(json);

  @override
  List<Object?> get props => [
        id,
        doctor,
        day,
        status,
        statusTrans,
        from,
        to,
        dateTimeStamp,
        formatedDate,
        notes,
        isReviewed,
        report,
        offer,
        canReschedule,
      ];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class QuickComment extends Equatable {
  final int? id;
  final String? text;

  const QuickComment({this.id, this.text});

  factory QuickComment.fromJson(Map<String, dynamic> json) =>
      _$QuickCommentFromJson(json);

  @override
  List<Object?> get props => [id, text];
}
