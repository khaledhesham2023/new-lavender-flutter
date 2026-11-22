import '../../../../core/network/api_result.dart';
import '../../../../data/models/responses/about.dart';

/// The static pages and the contact form, used by the content feature.
/// `ContentRepositoryImpl` (data layer) implements it.
abstract interface class ContentRepository {
  /// The backend reads these as query parameters; no body is sent.
  Future<ApiResult<void>> contactUs({
    required String fullName,
    required String title,
    required String content,
  });

  Future<ApiResult<AboutModel>> aboutUs();

  Future<ApiResult<AboutModel>> aboutApp();

  Future<ApiResult<AboutModel>> terms();

  Future<ApiResult<AboutModel>> policy();
}
