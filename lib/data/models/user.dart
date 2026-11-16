import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'user.g.dart';

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class CountryModel extends Equatable {
  final int? id;
  final String? name;
  final String? nationality;
  final String? phoneCode;
  @JsonKey(defaultValue: '+966')
  final String? showPhoneCode;
  final String? image;
  final String? shortName;
  @JsonKey(defaultValue: 9)
  final int? phoneNumberLimit;
  final int? nationalIdLimit;
  @JsonKey(fromJson: asPrefixOr5)
  final List<String> prefix;

  const CountryModel({
    this.id,
    this.name,
    this.nationality,
    this.phoneCode,
    this.showPhoneCode = '+966',
    this.image,
    this.shortName,
    this.phoneNumberLimit = 9,
    this.nationalIdLimit,
    this.prefix = const ['5'],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      _$CountryModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        nationality,
        phoneCode,
        showPhoneCode,
        image,
        shortName,
        phoneNumberLimit,
        nationalIdLimit,
        prefix,
      ];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class CityModel extends Equatable {
  final int? id;
  final String? name;

  const CityModel({this.id, this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);

  @override
  List<Object?> get props => [id, name];
}

@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
@BoolOrNullConv()
class UserModel extends Equatable {
  final int? id;
  final String? name;
  final String? image;
  final String? email;
  final CountryModel? country;
  final CityModel? city;
  final String? phoneCode;
  final String? phone;
  final String? gender;
  final String? lang;
  final bool? isAdminActiveUser;
  final String? phoneCompleteForm;
  final int? unreadNotifications;
  final bool? isBan;
  final bool? isVerified;
  final bool? allowNotification;
  final bool? isCompletedData;
  final String? token;
  final String? userType;

  const UserModel({
    this.id,
    this.name,
    this.image,
    this.email,
    this.country,
    this.city,
    this.phoneCode,
    this.phone,
    this.gender,
    this.lang,
    this.isAdminActiveUser,
    this.phoneCompleteForm,
    this.unreadNotifications,
    this.isBan,
    this.isVerified,
    this.allowNotification,
    this.isCompletedData,
    this.token,
    this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        email,
        country,
        city,
        phoneCode,
        phone,
        gender,
        lang,
        isAdminActiveUser,
        phoneCompleteForm,
        unreadNotifications,
        isBan,
        isVerified,
        allowNotification,
        isCompletedData,
        token,
        userType,
      ];
}

/// Body for login / register / otp / password endpoints (toJson only).
@JsonSerializable(createFactory: false)
class AuthRequest extends Equatable {
  final String? phone;
  final String? phoneCode;
  final String? deviceToken;
  final String? deviceType;
  final String? password;
  final String? fullName;
  final String? email;
  final String? passwordConfirmation;
  final String? otp;
  final String? currentPassword;
  final String? image;
  final int? termsAndConditions;

  const AuthRequest({
    this.phone,
    this.phoneCode,
    this.deviceToken,
    this.deviceType,
    this.password,
    this.fullName,
    this.email,
    this.passwordConfirmation,
    this.otp,
    this.currentPassword,
    this.image,
    this.termsAndConditions,
  });

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [
        phone,
        phoneCode,
        deviceToken,
        deviceType,
        password,
        fullName,
        email,
        passwordConfirmation,
        otp,
        currentPassword,
        image,
        termsAndConditions,
      ];
}
