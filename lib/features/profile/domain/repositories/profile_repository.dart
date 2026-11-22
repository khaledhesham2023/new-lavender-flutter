import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../data/models/responses/user.dart';

/// The user's account, used by the profile feature.
/// `ProfileRepositoryImpl` (data layer) implements it.
abstract interface class ProfileRepository {
  Future<ApiResult<UserModel>> getProfile();

  Future<ApiResult<UserModel?>> updateProfile(AuthRequest request);

  Future<ApiResult<void>> updatePhone(String phone, String phoneCode);

  Future<ApiResult<void>> changeUserPassword(AuthRequest request);

  Future<ApiResult<void>> deleteAccount();

  Future<ApiResult<void>> changeLang(String lang);
}
