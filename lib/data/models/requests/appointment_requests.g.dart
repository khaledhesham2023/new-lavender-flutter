// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
