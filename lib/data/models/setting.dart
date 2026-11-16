import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'setting.g.dart';

/// Response of `GET general/settings`.
@JsonSerializable(createToJson: false)
@StrConv()
@BoolOrNullConv()
class SettingModel extends Equatable {
  final bool? allowNotification;
  @JsonKey(name: 'whats_app_number')
  final String? whatsAppNumber;

  const SettingModel({this.allowNotification, this.whatsAppNumber});

  factory SettingModel.fromJson(Map<String, dynamic> json) =>
      _$SettingModelFromJson(json);

  @override
  List<Object?> get props => [allowNotification, whatsAppNumber];
}
