import 'dart:io';

import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../json/json_utils.dart';
import '../models/responses/setting.dart';

class GeneralRepository {
  GeneralRepository(this._api);

  final ApiClient _api;

  /// Returns the stored file name/URL, to be sent as `image` on update-profile.
  Future<ApiResult<String>> uploadImage(String filePath) => _api.call(
    (s) => s.uploadAttachment(File(filePath), 'users', 'image'),
    parse: (j) => asString(asMap(j)?['data'])!,
  );

  Future<ApiResult<SettingModel>> getSettings() => _api.call(
    (s) => s.settings(),
    parse: (j) => asObject(asMap(j)?['data'], SettingModel.fromJson)!,
  );
}
