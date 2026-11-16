// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryModel _$CountryModelFromJson(Map<String, dynamic> json) => CountryModel(
  id: const IntConv().fromJson(json['id']),
  name: const StrConv().fromJson(json['name']),
  nationality: const StrConv().fromJson(json['nationality']),
  phoneCode: const StrConv().fromJson(json['phone_code']),
  showPhoneCode: json['show_phone_code'] == null
      ? '+966'
      : const StrConv().fromJson(json['show_phone_code']),
  image: const StrConv().fromJson(json['image']),
  shortName: const StrConv().fromJson(json['short_name']),
  phoneNumberLimit: json['phone_number_limit'] == null
      ? 9
      : const IntConv().fromJson(json['phone_number_limit']),
  nationalIdLimit: const IntConv().fromJson(json['national_id_limit']),
  prefix: json['prefix'] == null ? const ['5'] : asPrefixOr5(json['prefix']),
);

CityModel _$CityModelFromJson(Map<String, dynamic> json) => CityModel(
  id: const IntConv().fromJson(json['id']),
  name: const StrConv().fromJson(json['name']),
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: const IntConv().fromJson(json['id']),
  name: const StrConv().fromJson(json['name']),
  image: const StrConv().fromJson(json['image']),
  email: const StrConv().fromJson(json['email']),
  country: json['country'] == null
      ? null
      : CountryModel.fromJson(json['country'] as Map<String, dynamic>),
  city: json['city'] == null
      ? null
      : CityModel.fromJson(json['city'] as Map<String, dynamic>),
  phoneCode: const StrConv().fromJson(json['phone_code']),
  phone: const StrConv().fromJson(json['phone']),
  gender: const StrConv().fromJson(json['gender']),
  lang: const StrConv().fromJson(json['lang']),
  isAdminActiveUser: const BoolOrNullConv().fromJson(
    json['is_admin_active_user'],
  ),
  phoneCompleteForm: const StrConv().fromJson(json['phone_complete_form']),
  unreadNotifications: const IntConv().fromJson(json['unread_notifications']),
  isBan: const BoolOrNullConv().fromJson(json['is_ban']),
  isVerified: const BoolOrNullConv().fromJson(json['is_verified']),
  allowNotification: const BoolOrNullConv().fromJson(
    json['allow_notification'],
  ),
  isCompletedData: const BoolOrNullConv().fromJson(json['is_completed_data']),
  token: const StrConv().fromJson(json['token']),
  userType: const StrConv().fromJson(json['user_type']),
);

Map<String, dynamic> _$AuthRequestToJson(AuthRequest instance) =>
    <String, dynamic>{
      'stringify': ?instance.stringify,
      'phone': ?instance.phone,
      'phone_code': ?instance.phoneCode,
      'device_token': ?instance.deviceToken,
      'device_type': ?instance.deviceType,
      'password': ?instance.password,
      'full_name': ?instance.fullName,
      'email': ?instance.email,
      'password_confirmation': ?instance.passwordConfirmation,
      'otp': ?instance.otp,
      'current_password': ?instance.currentPassword,
      'image': ?instance.image,
      'terms_and_conditions': ?instance.termsAndConditions,
    };
