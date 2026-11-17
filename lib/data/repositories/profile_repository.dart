import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../enums/enums.dart';
import '../json/json_utils.dart';
import '../models/requests/auth_requests.dart';
import '../models/responses/about.dart';
import '../models/responses/report.dart';
import '../models/responses/user.dart';
import 'repository_parsers.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<UserModel>> getProfile() =>
      _api.get(Endpoints.user, parse: parseUser);

  Future<ApiResult<UserModel?>> updateProfile(AuthRequest request) => _api.post(
    Endpoints.updateProfile,
    body: request.toJson(),
    parse: parseUserOrNull,
  );

  Future<ApiResult<void>> updatePhone(String phone, String phoneCode) =>
      _api.post(
        Endpoints.updatePhone,
        body: AuthRequest(phone: phone, phoneCode: phoneCode).toJson(),
        parse: parseVoid,
      );

  Future<ApiResult<void>> changeUserPassword(AuthRequest request) => _api.post(
    Endpoints.changePassword,
    body: request.toJson(),
    parse: parseVoid,
  );

  Future<ApiResult<void>> deleteAccount() =>
      _api.delete(Endpoints.user, parse: parseVoid);

  /// The backend reads these as query parameters; no body is sent.
  Future<ApiResult<void>> contactUs({
    required String fullName,
    required String title,
    required String content,
  }) => _api.post(
    Endpoints.contact,
    query: {'full_name': fullName, 'title': title, 'content': content},
    parse: parseVoid,
  );

  Future<ApiResult<AboutModel>> aboutUs() => _about(Endpoints.about);
  Future<ApiResult<AboutModel>> aboutApp() => _about(Endpoints.aboutApp);
  Future<ApiResult<AboutModel>> terms() => _about(Endpoints.terms);
  Future<ApiResult<AboutModel>> policy() => _about(Endpoints.policy);

  Future<ApiResult<AboutModel>> _about(String path) => _api.get(
    path,
    parse: (j) => asObject(asMap(j)?['data'], AboutModel.fromJson)!,
  );

  Future<ApiResult<void>> changeLang(String lang) =>
      _api.post(Endpoints.changeLang, query: {'lang': lang}, parse: parseVoid);

  /// A missing or empty `data` gives an empty list, not a failure.
  Future<ApiResult<List<DayReportsModel>>> getReports(ReportType type) =>
      _api.get(
        Endpoints.myReports,
        query: {'type': type.value},
        parse: (j) => asList(asMap(j)?['data'], DayReportsModel.fromJson),
      );
}
