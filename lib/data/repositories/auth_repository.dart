import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/requests/auth_requests.dart';
import '../models/responses/user.dart';
import 'repository_parsers.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<UserModel>> login(AuthRequest request) =>
      _api.post(Endpoints.login, body: request.toJson(), parse: parseUser);

  Future<ApiResult<UserModel>> register(AuthRequest request) =>
      _api.post(Endpoints.register, body: request.toJson(), parse: parseUser);

  Future<ApiResult<UserModel>> verifyPhone(AuthRequest request) =>
      _api.post(Endpoints.verify, body: request.toJson(), parse: parseUser);

  Future<ApiResult<UserModel?>> resendCode(AuthRequest request) => _api.post(
    Endpoints.resend,
    body: request.toJson(),
    parse: parseUserOrNull,
  );

  Future<ApiResult<UserModel?>> resetPassword(AuthRequest request) => _api.post(
    Endpoints.passwordReset,
    body: request.toJson(),
    parse: parseUserOrNull,
  );

  /// Android also sends the Authorization header here; our client adds it
  /// only when logged in.
  Future<ApiResult<UserModel?>> verifyForgetPassword(AuthRequest request) =>
      _api.post(
        Endpoints.passwordVerify,
        body: request.toJson(),
        parse: parseUserOrNull,
      );

  Future<ApiResult<void>> changePassword(AuthRequest request) => _api.post(
    Endpoints.passwordChange,
    body: request.toJson(),
    parse: parseVoid,
  );

  Future<ApiResult<void>> logout(String? deviceToken) => _api.post(
    Endpoints.logout,
    body: AuthRequest(deviceToken: deviceToken).toJson(),
    parse: parseVoid,
  );

  Future<ApiResult<UserModel?>> verifyChangedPhone(AuthRequest request) =>
      _api.post(
        Endpoints.verifyPhone,
        body: request.toJson(),
        parse: parseUserOrNull,
      );
}
