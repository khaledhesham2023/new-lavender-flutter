import '../../../core/network/api_result.dart';
import '../../../data/models/responses/setting.dart';

/// App settings and file upload, used by home and profile.
/// `GeneralRepositoryImpl` (shared data layer) implements it.
abstract interface class GeneralRepository {
  /// Returns the stored file name/URL, to be sent as `image` on update-profile.
  Future<ApiResult<String>> uploadImage(String filePath);

  Future<ApiResult<SettingModel>> getSettings();
}
