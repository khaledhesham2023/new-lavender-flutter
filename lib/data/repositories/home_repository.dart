import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../core/network/endpoints.dart';
import '../models/requests/favorite_request.dart';
import '../models/responses/home.dart';
import 'repository_parsers.dart';

class HomeRepository {
  HomeRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<HomeData>> getHome() =>
      _api.get(Endpoints.home, parse: parseObject(HomeData.fromJson));

  /// Toggles the favorite state; `doctor_id` is sent as a string.
  Future<ApiResult<void>> toggleFavorite(int doctorId) => _api.post(
    Endpoints.fav,
    body: ToggleFavoriteRequest(doctorId).toJson(),
    parse: parseVoid,
  );
}
