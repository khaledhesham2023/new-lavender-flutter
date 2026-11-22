import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../data/json/json_utils.dart';
import '../../../data/models/responses/setting.dart';
import '../../domain/repositories/general_repository.dart';

/// [GeneralRepository] over the Lavender API.
class GeneralRepositoryImpl implements GeneralRepository {
  GeneralRepositoryImpl(this._api);

  final ApiClient _api;

  /// Returns the stored file name/URL, to be sent as `image` on update-profile.
  @override
  Future<ApiResult<String>> uploadImage(String filePath) => _api.call(
    (s) => s.uploadAttachment(File(filePath), 'users', 'image'),
    parse: (j) => asString(asMap(j)?['data'])!,
  );

  @override
  Future<ApiResult<SettingModel>> getSettings() => _api.call(
    (s) => s.settings(),
    parse: (j) => asObject(asMap(j)?['data'], SettingModel.fromJson)!,
  );
}
