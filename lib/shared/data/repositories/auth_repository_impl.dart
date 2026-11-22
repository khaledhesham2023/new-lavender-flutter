import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/push/device_info.dart';
import '../../../data/models/requests/auth_requests.dart';
import '../../../data/models/responses/user.dart';
import '../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/auth_repository.dart';

/// [AuthRepository] over the Lavender API.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<UserModel>> login(AuthRequest request) =>
      _api.call((s) => s.login(request.toJson()), parse: parseUser);

  @override
  Future<ApiResult<UserModel>> register(AuthRequest request) =>
      _api.call((s) => s.register(request.toJson()), parse: parseUser);

  @override
  Future<ApiResult<UserModel>> verifyPhone(AuthRequest request) =>
      _api.call((s) => s.verify(request.toJson()), parse: parseUser);

  @override
  Future<ApiResult<UserModel?>> resendCode(AuthRequest request) =>
      _api.call((s) => s.resend(request.toJson()), parse: parseUserOrNull);

  @override
  Future<ApiResult<UserModel?>> resetPassword(AuthRequest request) => _api.call(
    (s) => s.passwordReset(request.toJson()),
    parse: parseUserOrNull,
  );

  /// Android also sends the Authorization header here; our client adds it
  /// only when logged in.
  @override
  Future<ApiResult<UserModel?>> verifyForgetPassword(AuthRequest request) =>
      _api.call(
        (s) => s.passwordVerify(request.toJson()),
        parse: parseUserOrNull,
      );

  @override
  Future<ApiResult<void>> changePassword(AuthRequest request) =>
      _api.call((s) => s.passwordChange(request.toJson()), parse: parseVoid);

  @override
  Future<ApiResult<void>> logout(String? deviceToken) => _api.call(
    (s) => s.logout(
      AuthRequest(deviceToken: deviceToken, deviceType: deviceType).toJson(),
    ),
    parse: parseVoid,
  );

  @override
  Future<ApiResult<UserModel?>> verifyChangedPhone(AuthRequest request) =>
      _api.call((s) => s.verifyPhone(request.toJson()), parse: parseUserOrNull);
}
