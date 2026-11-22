import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../data/models/responses/user.dart';
import '../../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/profile_repository.dart';

/// [ProfileRepository] over the Lavender API.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<UserModel>> getProfile() =>
      _api.call((s) => s.getUser(), parse: parseUser);

  @override
  Future<ApiResult<UserModel?>> updateProfile(AuthRequest request) => _api.call(
    (s) => s.updateProfile(request.toJson()),
    parse: parseUserOrNull,
  );

  @override
  Future<ApiResult<void>> updatePhone(String phone, String phoneCode) =>
      _api.call(
        (s) => s.updatePhone(
          AuthRequest(phone: phone, phoneCode: phoneCode).toJson(),
        ),
        parse: parseVoid,
      );

  @override
  Future<ApiResult<void>> changeUserPassword(AuthRequest request) =>
      _api.call((s) => s.changePassword(request.toJson()), parse: parseVoid);

  @override
  Future<ApiResult<void>> deleteAccount() =>
      _api.call((s) => s.deleteUser(), parse: parseVoid);

  @override
  Future<ApiResult<void>> changeLang(String lang) =>
      _api.call((s) => s.changeLang(lang), parse: parseVoid);
}
