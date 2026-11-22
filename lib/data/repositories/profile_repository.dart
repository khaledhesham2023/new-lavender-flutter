import 'package:retrofit/retrofit.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/lavender_api.dart';
import '../../core/enums/enums.dart';
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
      _api.call((s) => s.getUser(), parse: parseUser);

  Future<ApiResult<UserModel?>> updateProfile(AuthRequest request) => _api.call(
    (s) => s.updateProfile(request.toJson()),
    parse: parseUserOrNull,
  );

  Future<ApiResult<void>> updatePhone(String phone, String phoneCode) =>
      _api.call(
        (s) => s.updatePhone(
          AuthRequest(phone: phone, phoneCode: phoneCode).toJson(),
        ),
        parse: parseVoid,
      );

  Future<ApiResult<void>> changeUserPassword(AuthRequest request) =>
      _api.call((s) => s.changePassword(request.toJson()), parse: parseVoid);

  Future<ApiResult<void>> deleteAccount() =>
      _api.call((s) => s.deleteUser(), parse: parseVoid);

  /// The backend reads these as query parameters; no body is sent.
  Future<ApiResult<void>> contactUs({
    required String fullName,
    required String title,
    required String content,
  }) => _api.call((s) => s.contact(fullName, title, content), parse: parseVoid);

  Future<ApiResult<AboutModel>> aboutUs() => _about((s) => s.about());
  Future<ApiResult<AboutModel>> aboutApp() => _about((s) => s.aboutApp());
  Future<ApiResult<AboutModel>> terms() => _about((s) => s.terms());
  Future<ApiResult<AboutModel>> policy() => _about((s) => s.policy());

  Future<ApiResult<AboutModel>> _about(
    Future<HttpResponse<dynamic>> Function(LavenderApi api) request,
  ) => _api.call(
    request,
    parse: (j) => asObject(asMap(j)?['data'], AboutModel.fromJson)!,
  );

  Future<ApiResult<void>> changeLang(String lang) =>
      _api.call((s) => s.changeLang(lang), parse: parseVoid);

  /// A missing or empty `data` gives an empty list, not a failure.
  Future<ApiResult<List<DayReportsModel>>> getReports(ReportType type) =>
      _api.call(
        (s) => s.myReports(type.value),
        parse: (j) => asList(asMap(j)?['data'], DayReportsModel.fromJson),
      );
}
