// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AboutImage _$AboutImageFromJson(Map<String, dynamic> json) => AboutImage(
  id: const IntConv().fromJson(json['id']),
  media: const StrConv().fromJson(json['media']),
);

SocialLink _$SocialLinkFromJson(Map<String, dynamic> json) => SocialLink(
  id: const IntConv().fromJson(json['id']),
  key: const StrConv().fromJson(json['key']),
  value: const StrConv().fromJson(json['value']),
);

AboutModel _$AboutModelFromJson(Map<String, dynamic> json) => AboutModel(
  id: const IntConv().fromJson(json['id']),
  image: json['image'] == null
      ? null
      : AboutImage.fromJson(json['image'] as Map<String, dynamic>),
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  name: const StrConv().fromJson(json['name']),
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => AboutImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

SettingModel _$SettingModelFromJson(Map<String, dynamic> json) => SettingModel(
  allowNotification: const BoolOrNullConv().fromJson(
    json['allow_notification'],
  ),
  whatsAppNumber: const StrConv().fromJson(json['whats_app_number']),
);
