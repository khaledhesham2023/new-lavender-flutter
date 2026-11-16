// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentData _$AppointmentDataFromJson(Map<String, dynamic> json) =>
    AppointmentData(
      id: const IntConv().fromJson(json['id']),
      doctor: json['doctor'] == null
          ? null
          : DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>),
      day: const StrConv().fromJson(json['day']),
      status: const StrConv().fromJson(json['status']),
      statusTrans: const StrConv().fromJson(json['status_trans']),
      from: const StrConv().fromJson(json['from']),
      to: const StrConv().fromJson(json['to']),
      dateTimeStamp: const StrConv().fromJson(json['date_timeStamp']),
      formatedDate: const StrConv().fromJson(json['formated_date']),
      notes: const StrConv().fromJson(json['notes']),
      isReviewed: json['is_reviewed'] == null
          ? false
          : const BoolConv().fromJson(json['is_reviewed']),
      report: const StrConv().fromJson(json['report']),
      offer: json['offer'] == null
          ? null
          : OfferModel.fromJson(json['offer'] as Map<String, dynamic>),
      canReschedule: json['can_reschedule'] == null
          ? true
          : asBoolDefaultTrue(json['can_reschedule']),
    );

QuickComment _$QuickCommentFromJson(Map<String, dynamic> json) => QuickComment(
  id: const IntConv().fromJson(json['id']),
  text: const StrConv().fromJson(json['text']),
);

Map<String, dynamic> _$SaveAppointmentRequestToJson(
  SaveAppointmentRequest instance,
) => <String, dynamic>{
  'stringify': ?instance.stringify,
  'doctor_id': ?instance.doctorId,
  'day': ?instance.day,
  'time': ?instance.time,
  'user_offer_id': ?instance.userOfferId,
  'notes': ?instance.notes,
};

Map<String, dynamic> _$UpdateAppointmentRequestToJson(
  UpdateAppointmentRequest instance,
) => <String, dynamic>{
  'stringify': ?instance.stringify,
  'doctor_id': instance.doctorId,
  'day': instance.day,
  'time': instance.time,
};

Map<String, dynamic> _$RebookRequestToJson(RebookRequest instance) =>
    <String, dynamic>{
      'stringify': ?instance.stringify,
      'day': ?instance.day,
      'time': ?instance.time,
    };

Map<String, dynamic> _$AddCommentRequestToJson(AddCommentRequest instance) =>
    <String, dynamic>{
      'stringify': ?instance.stringify,
      'rate': ?instance.rate,
      'comment': ?instance.comment,
      'doctor_id': ?instance.doctorId,
      'quick_comment_id': ?instance.quickCommentId,
      'client_appointment_id': ?instance.clientAppointmentId,
    };

Map<String, dynamic> _$ChangeAppointmentRequestToJson(
  ChangeAppointmentRequest instance,
) => <String, dynamic>{
  'stringify': ?instance.stringify,
  'doctor_id': instance.doctorId,
  'day': instance.day,
  'dayName': instance.dayName,
  'time': instance.time,
};

Map<String, dynamic> _$GetBookingsRequestToJson(GetBookingsRequest instance) =>
    <String, dynamic>{
      'stringify': ?instance.stringify,
      'status': ?instance.status,
    };
