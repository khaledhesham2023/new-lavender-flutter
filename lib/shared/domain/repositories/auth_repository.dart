import '../../../core/network/api_result.dart';
import '../../../data/models/requests/auth_requests.dart';
import '../../../data/models/responses/user.dart';

/// Sign-in, registration and password flows, used by auth and profile.
/// `AuthRepositoryImpl` (shared data layer) implements it.
abstract interface class AuthRepository {
  Future<ApiResult<UserModel>> login(AuthRequest request);

  Future<ApiResult<UserModel>> register(AuthRequest request);

  Future<ApiResult<UserModel>> verifyPhone(AuthRequest request);

  Future<ApiResult<UserModel?>> resendCode(AuthRequest request);

  Future<ApiResult<UserModel?>> resetPassword(AuthRequest request);

  Future<ApiResult<UserModel?>> verifyForgetPassword(AuthRequest request);

  Future<ApiResult<void>> changePassword(AuthRequest request);

  Future<ApiResult<void>> logout(String? deviceToken);

  Future<ApiResult<UserModel?>> verifyChangedPhone(AuthRequest request);
}
