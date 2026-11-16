import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_requests.g.dart';

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
