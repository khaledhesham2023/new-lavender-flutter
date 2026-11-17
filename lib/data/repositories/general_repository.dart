import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../json/json_utils.dart';
import '../models/responses/setting.dart';

class GeneralRepository {
  GeneralRepository(this._api);

  final ApiClient _api;

  /// Returns the stored file name/URL, to be sent as `image` on update-profile.
  Future<ApiResult<String>> uploadImage(String filePath) => _api.upload(
    Endpoints.attachments,
    filePath: filePath,
    field: 'file',
    query: {'model': 'users', 'attachment_type': 'image'},
    parse: (j) => asString(asMap(j)?['data'])!,
  );

  Future<ApiResult<SettingModel>> getSettings() => _api.get(
    Endpoints.settings,
    parse: (j) => asObject(asMap(j)?['data'], SettingModel.fromJson)!,
  );
}
