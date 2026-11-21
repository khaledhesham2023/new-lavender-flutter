import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/push/device_info.dart';
import '../models/requests/auth_requests.dart';
import '../models/responses/user.dart';
import 'repository_parsers.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<UserModel>> login(AuthRequest request) =>
      _api.call((s) => s.login(request.toJson()), parse: parseUser);

  Future<ApiResult<UserModel>> register(AuthRequest request) =>
      _api.call((s) => s.register(request.toJson()), parse: parseUser);

  Future<ApiResult<UserModel>> verifyPhone(AuthRequest request) =>
      _api.call((s) => s.verify(request.toJson()), parse: parseUser);

  Future<ApiResult<UserModel?>> resendCode(AuthRequest request) =>
      _api.call((s) => s.resend(request.toJson()), parse: parseUserOrNull);

  Future<ApiResult<UserModel?>> resetPassword(AuthRequest request) => _api.call(
    (s) => s.passwordReset(request.toJson()),
    parse: parseUserOrNull,
  );

  /// Android also sends the Authorization header here; our client adds it
  /// only when logged in.
  Future<ApiResult<UserModel?>> verifyForgetPassword(AuthRequest request) =>
      _api.call(
        (s) => s.passwordVerify(request.toJson()),
        parse: parseUserOrNull,
      );

  Future<ApiResult<void>> changePassword(AuthRequest request) =>
      _api.call((s) => s.passwordChange(request.toJson()), parse: parseVoid);

  Future<ApiResult<void>> logout(String? deviceToken) => _api.call(
    (s) => s.logout(
      AuthRequest(deviceToken: deviceToken, deviceType: deviceType).toJson(),
    ),
    parse: parseVoid,
  );

  Future<ApiResult<UserModel?>> verifyChangedPhone(AuthRequest request) =>
      _api.call((s) => s.verifyPhone(request.toJson()), parse: parseUserOrNull);
}
