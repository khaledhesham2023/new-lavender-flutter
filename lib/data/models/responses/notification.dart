import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../json/json_converters.dart';

part 'notification.g.dart';

/// Nested `data` of a notification.
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class NotificationTypeData extends Equatable {
  final int? notifyId;
  final String? notifyType;

  const NotificationTypeData({this.notifyId, this.notifyType});

  factory NotificationTypeData.fromJson(Map<String, dynamic> json) =>
      _$NotificationTypeDataFromJson(json);

  @override
  List<Object?> get props => [notifyId, notifyType];
}

@JsonSerializable(createToJson: false)
@StrConv()
@BoolOrNullConv()
class NotificationModel extends Equatable {
  final String? body;
  final NotificationTypeData? data;

  /// UUID string.
  final String? id;
  final bool? isReaded;
  final String? readAt;
  final String? sendingTime;
  final String? sendingTimeAgo;
  final String? title;
  final String? dateFormated;

  const NotificationModel({
    this.body,
    this.data,
    this.id,
    this.isReaded,
    this.readAt,
    this.sendingTime,
    this.sendingTimeAgo,
    this.title,
    this.dateFormated,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  NotificationModel copyWith({bool? isReaded}) => NotificationModel(
        body: body,
        data: data,
        id: id,
        isReaded: isReaded ?? this.isReaded,
        readAt: readAt,
        sendingTime: sendingTime,
        sendingTimeAgo: sendingTimeAgo,
        title: title,
        dateFormated: dateFormated,
      );

  @override
  List<Object?> get props => [
        body,
        data,
        id,
        isReaded,
        readAt,
        sendingTime,
        sendingTimeAgo,
        title,
        dateFormated,
      ];
}
