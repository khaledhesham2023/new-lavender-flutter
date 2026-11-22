import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/requests/favorite_request.dart';
import '../../../data/models/responses/home.dart';
import '../../../data/repositories/repository_parsers.dart';
import '../../domain/repositories/home_repository.dart';

/// [HomeRepository] over the Lavender API.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ApiResult<HomeData>> getHome() =>
      _api.call((s) => s.home(), parse: parseObject(HomeData.fromJson));

  /// Toggles the favorite state; `doctor_id` is sent as a string.
  @override
  Future<ApiResult<void>> toggleFavorite(int doctorId) => _api.call(
    (s) => s.toggleFavorite(ToggleFavoriteRequest(doctorId).toJson()),
    parse: parseVoid,
  );
}
