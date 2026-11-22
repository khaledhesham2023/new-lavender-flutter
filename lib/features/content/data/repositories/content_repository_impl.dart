import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/lavender_api.dart';
import '../../../../data/json/json_utils.dart';
import '../../../../data/models/responses/about.dart';
import '../../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/content_repository.dart';

/// [ContentRepository] over the Lavender API.
class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<void>> contactUs({
    required String fullName,
    required String title,
    required String content,
  }) => _api.call((s) => s.contact(fullName, title, content), parse: parseVoid);

  @override
  Future<ApiResult<AboutModel>> aboutUs() => _about((s) => s.about());
  @override
  Future<ApiResult<AboutModel>> aboutApp() => _about((s) => s.aboutApp());
  @override
  Future<ApiResult<AboutModel>> terms() => _about((s) => s.terms());
  @override
  Future<ApiResult<AboutModel>> policy() => _about((s) => s.policy());

  Future<ApiResult<AboutModel>> _about(
    Future<HttpResponse<dynamic>> Function(LavenderApi api) request,
  ) => _api.call(
    request,
    parse: (j) => asObject(asMap(j)?['data'], AboutModel.fromJson)!,
  );
}
