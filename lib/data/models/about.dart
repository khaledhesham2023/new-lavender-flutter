import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'about.g.dart';

/// `AboutUsImages` in Kotlin.
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class AboutImage extends Equatable {
  final int? id;
  final String? media;

  const AboutImage({this.id, this.media});

  factory AboutImage.fromJson(Map<String, dynamic> json) =>
      _$AboutImageFromJson(json);

  @override
  List<Object?> get props => [id, media];
}

/// `LinkSocial` in Kotlin.
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class SocialLink extends Equatable {
  final int? id;
  final String? key;
  final String? value;

  const SocialLink({this.id, this.key, this.value});

  factory SocialLink.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkFromJson(json);

  @override
  List<Object?> get props => [id, key, value];
}

/// Used by about-us, terms and privacy-policy (`name` is HTML).
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class AboutModel extends Equatable {
  final int? id;
  final AboutImage? image;
  @JsonKey(defaultValue: [])
  final List<SocialLink> links;
  final String? name;
  @JsonKey(defaultValue: [])
  final List<AboutImage> images;

  const AboutModel({
    this.id,
    this.image,
    this.links = const [],
    this.name,
    this.images = const [],
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) =>
      _$AboutModelFromJson(json);

  @override
  List<Object?> get props => [id, image, links, name, images];
}

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
