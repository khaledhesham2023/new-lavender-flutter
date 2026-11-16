// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationTypeData _$NotificationTypeDataFromJson(
  Map<String, dynamic> json,
) => NotificationTypeData(
  notifyId: const IntConv().fromJson(json['notify_id']),
  notifyType: const StrConv().fromJson(json['notify_type']),
);

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      body: const StrConv().fromJson(json['body']),
      data: json['data'] == null
          ? null
          : NotificationTypeData.fromJson(json['data'] as Map<String, dynamic>),
      id: const StrConv().fromJson(json['id']),
      isReaded: const BoolOrNullConv().fromJson(json['is_readed']),
      readAt: const StrConv().fromJson(json['read_at']),
      sendingTime: const StrConv().fromJson(json['sending_time']),
      sendingTimeAgo: const StrConv().fromJson(json['sending_time_ago']),
      title: const StrConv().fromJson(json['title']),
      dateFormated: const StrConv().fromJson(json['date_formated']),
    );
