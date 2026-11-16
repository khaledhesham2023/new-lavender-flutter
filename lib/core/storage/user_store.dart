import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user.dart';

/// Logged-in user snapshot kept in local storage (no token: see [AppPrefs]).
class UserData extends Equatable {
  final int id;
  final String name;
  final String image;
  final String email;
  final String phoneCode;
  final String phone;
  final String gender;
  final String lang;
  final bool isVerified;
  final bool allowNotification;
  final bool isCompletedData;
  final int unreadNotifications;
  final String userType;
  final int countryId;
  final String countryName;
  final String countryImage;
  final String countryPhoneCode;
  final int cityId;
  final String cityName;

  const UserData({
    this.id = 0,
    this.name = '',
    this.image = '',
    this.email = '',
    this.phoneCode = '',
    this.phone = '',
    this.gender = '',
    this.lang = 'ar',
    this.isVerified = false,
    this.allowNotification = true,
    this.isCompletedData = false,
    this.unreadNotifications = 0,
    this.userType = '',
    this.countryId = 0,
    this.countryName = '',
    this.countryImage = '',
    this.countryPhoneCode = '',
    this.cityId = 0,
    this.cityName = '',
  });

  /// Maps like Android `ProtoDataRepositoryImpl.saveUserModel`.
  factory UserData.fromUserModel(UserModel m) => UserData(
        id: m.id ?? 0,
        name: m.name ?? '',
        image: m.image ?? '',
        email: m.email ?? '',
        phoneCode: m.phoneCode ?? '',
        phone: m.phone ?? '',
        gender: m.gender ?? '',
        lang: m.lang ?? 'ar',
        isVerified: m.isVerified ?? false,
        allowNotification: m.allowNotification ?? true,
        isCompletedData: m.isCompletedData ?? false,
        unreadNotifications: m.unreadNotifications ?? 0,
        userType: m.userType ?? '',
        countryId: m.country?.id ?? 0,
        countryName: m.country?.name ?? '',
        countryImage: m.country?.image ?? '',
        countryPhoneCode: m.country?.phoneCode ?? '',
        cityId: m.city?.id ?? 0,
        cityName: m.city?.name ?? '',
      );

  factory UserData.fromJson(Map<String, dynamic> j) => UserData(
        id: j['id'] as int? ?? 0,
        name: j['name'] as String? ?? '',
        image: j['image'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phoneCode: j['phoneCode'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        gender: j['gender'] as String? ?? '',
        lang: j['lang'] as String? ?? 'ar',
        isVerified: j['isVerified'] as bool? ?? false,
        allowNotification: j['allowNotification'] as bool? ?? true,
        isCompletedData: j['isCompletedData'] as bool? ?? false,
        unreadNotifications: j['unreadNotifications'] as int? ?? 0,
        userType: j['userType'] as String? ?? '',
        countryId: j['countryId'] as int? ?? 0,
        countryName: j['countryName'] as String? ?? '',
        countryImage: j['countryImage'] as String? ?? '',
        countryPhoneCode: j['countryPhoneCode'] as String? ?? '',
        cityId: j['cityId'] as int? ?? 0,
        cityName: j['cityName'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'email': email,
        'phoneCode': phoneCode,
        'phone': phone,
        'gender': gender,
        'lang': lang,
        'isVerified': isVerified,
        'allowNotification': allowNotification,
        'isCompletedData': isCompletedData,
        'unreadNotifications': unreadNotifications,
        'userType': userType,
        'countryId': countryId,
        'countryName': countryName,
        'countryImage': countryImage,
        'countryPhoneCode': countryPhoneCode,
        'cityId': cityId,
        'cityName': cityName,
      };

  UserData copyWith({
    String? name,
    String? image,
    String? email,
    String? phoneCode,
    String? phone,
  }) =>
      UserData(
        id: id,
        name: name ?? this.name,
        image: image ?? this.image,
        email: email ?? this.email,
        phoneCode: phoneCode ?? this.phoneCode,
        phone: phone ?? this.phone,
        gender: gender,
        lang: lang,
        isVerified: isVerified,
        allowNotification: allowNotification,
        isCompletedData: isCompletedData,
        unreadNotifications: unreadNotifications,
        userType: userType,
        countryId: countryId,
        countryName: countryName,
        countryImage: countryImage,
        countryPhoneCode: countryPhoneCode,
        cityId: cityId,
        cityName: cityName,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        email,
        phoneCode,
        phone,
        gender,
        lang,
        isVerified,
        allowNotification,
        isCompletedData,
        unreadNotifications,
        userType,
        countryId,
        countryName,
        countryImage,
        countryPhoneCode,
        cityId,
        cityName,
      ];
}

class UserStore {
  UserStore(this._prefs);

  final SharedPreferences _prefs;

  static const keyUserData = 'user_data';

  UserData? read() {
    final raw = _prefs.getString(keyUserData);
    if (raw == null) return null;
    try {
      return UserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(UserData user) =>
      _prefs.setString(keyUserData, jsonEncode(user.toJson()));

  /// Only non-null values change (Android `updateUserFields`).
  Future<void> updateFields({
    String? name,
    String? phone,
    String? phoneCode,
    String? image,
    String? email,
  }) async {
    final current = read();
    if (current == null) return;
    await save(current.copyWith(
      name: name,
      phone: phone,
      phoneCode: phoneCode,
      image: image,
      email: email,
    ));
  }

  Future<void> clear() => _prefs.remove(keyUserData);
}
